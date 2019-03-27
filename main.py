#!/usr/bin/env python
# Copyright Ivan_yin 2019.3.13
# All rights reserved
import re
import time
import params
import urllib
import requests
import outputFormat
from bs4 import BeautifulSoup

# 清除字符串无效字符
def pureStr(s):
    s = s.replace(' ', '').replace('\n', '')
    return s.replace('\u3000', '')

# 处理当事人信息
def processParty(text):
    text = text.replace('当事人：', '')
    index = max(text.rfind('住所'), text.rfind('住址'))
    party = text[0:index-1]
    add = text[index+3:-1]
    index = add.find('，')
    if(index > 0):
        address = add[0:index]
    else:
        address = add
    return party, address

# 查找公司
def findCompany(text):
    company = list()
    while True:
        index = text.find('有限公司')
        # f.write('index='+str(index)+'\n')
        if index == -1:
            break
        first = text[0:index+4]
        second = text[index+4:]
        # f.write('first='+first+'\nsecond='+second+'\n')
        punc = first.find('，')
        if punc == -1 or punc > index:
            punc = first.find('。')
        if punc != -1 and punc < index:
            first = first[punc:]
        for c in params.CITY:
            begin = first.find(c)
            if begin != -1:
                # f.write('c='+c+"\n")
                # f.write('company='+first[begin:]+"\n")
                company.append(first[begin:])
                break
        else:
            end = second.find('以下简称')
            # f.write('end='+str(end)+"\n")
            if end != -1:
                second = second[end:]
                com = re.search('以下简称(.+)[）\)]', second)
                com = com.group(1)
                begin = first.find(com)
                if begin != -1:
                    company.append(first[begin:])
        text = second
    return company

# 处理一个网页的内容
def processPage(url):
    result = dict(网址=url)
    response = requests.get(url)
    if response.status_code != requests.codes.ok:
        print('[processPage]ERROR:response.status_code =', response.status_code)
    soup = BeautifulSoup(response.content.decode('utf-8'), 'lxml')

    # 处理头部信息
    headContainer = soup.find(id='headContainer')
    td = headContainer.find_all('td')
    # 第0行，索引号和分类
    tmp = td[0].find('td').get_text().split(':')
    result[pureStr(tmp[0])] = pureStr(tmp[1])
    # 第3行，发文日期
    tmp = td[3].find_all('td')[1].get_text().split(':')
    result[pureStr(tmp[0])] = pureStr(tmp[1])
    # 第6行，处罚对象
    tmp = td[6].get_text().split(':')
    title = pureStr(tmp[1])
    subOfPunishment = re.search('中国证监会行政处罚决定书[（\()](.+)[）\)]', title)
    if subOfPunishment == None:
        subOfPunishment = re.search('中国证监会市场禁入决定书[（\()](.+)[）\)]', title)
        if subOfPunishment == None:
            subOfPunishment = re.search(
                '中国证监会，财政部行政处罚决定书[（\()](.+)[）\)]', title)
    subOfPunishment = subOfPunishment.group(1)
    result['名称中的处罚对象'] = pureStr(subOfPunishment)
    # 第8行，文号
    tmp = td[8].get_text().split(':')
    result[pureStr(tmp[0])] = pureStr(tmp[1])
    # 第9行，主题词
    tmp = td[9].get_text().split(':')
    result[pureStr(tmp[0])] = pureStr(tmp[1])

    # 处理内容
    mainContainer = soup.find('div', class_='Section0')
    if mainContainer == None:
        mainContainer = soup.find('div', class_='content')
    phrase = 0
    party = list()
    address = list()
    illegalTime = list()
    h3 = mainContainer.find('h3')
    if h3 != None:
        h3 = h3.get_text()
        par, add = processParty(h3)
        party.append(par)
        address.append(add)
        phrase = 1
    ps = mainContainer.find_all('p')
    for p in ps:
        p = p.get_text()
        if(phrase == 0):
            if '当事人：' in p or '男，' in p:
                phrase = phrase+1
            else:
                continue
        if phrase == 1:
            if '依据《'in p or '《中华人民共和国证券法》' in p:
                phrase = phrase+1
            else:
                par, add = processParty(p)
                party.append(par)
                address.append(add)
        if phrase == 2:
            if '经查' in p or '存在以下违法事实' in p or '本案现已调查、审理终结' in p:
                phrase = phrase+1
                continue
        elif phrase == 3:
            ilTime = re.findall('\d\d\d\d年\d\d?月\d\d?日', p)
            if(ilTime != None):
                illegalTime = illegalTime+ilTime
    if len(illegalTime) == 0:
        if phrase != 3:
            print("[processPage]ERROR")
            exit
    else:
        illegalTime.pop()

    # 查找公司
    company = list()
    for p in ps:
        p = p.get_text()
        company = company+findCompany(p)
    result['涉及公司'] = company

    typee = list()
    accountingFirm = list()
    mainContainer = mainContainer.get_text()
    for t in params.TYPE:
        if t in mainContainer:
            typee.append(t)
    for af in params.ACCOUNTINGFIRM:
        if af in mainContainer:
            accountingFirm.append(af)

    result['当事人'] = party
    result['住址'] = address
    result['违法行为/违法事实时间序列（年/月/日）'] = illegalTime
    result['处罚类型序列'] = typee
    result['涉及会计师事务所'] = accountingFirm
    #print(result)
    return result

# 处理主界面列表
def processIndex(url):
    if type(url) != str:
        print('[processIndex]ERROR')
        exit
    response = requests.get(url)
    if response.status_code != requests.codes.ok:
        print('[processIndex]ERROR')
        exit
    soup = BeautifulSoup(response.content.decode('utf-8'), 'lxml')
    documentContainer = soup.find(id='documentContainer')
    row = documentContainer.find_all('div', class_='row')
    result = list()
    for r in row:
        fbrq = r.find('li', class_='fbrq')
        articleDate = fbrq.get_text()
        year = int(articleDate[0:4])
        if year < 2010:
            return result
        a = r.find('a')
        pageUrl = a.get('href')
        pageUrl = urllib.parse.urljoin(url, pageUrl)
        result.append(processPage(pageUrl))
    return result

def main():
    start = time.time()
    print('START:'+time.ctime(start))
    i = 0
    base = 'http://www.csrc.gov.cn/pub/zjhpublic/3300/3313/index_7401'
    end = '.htm'
    while True:
        if i == 0:
            re = processIndex(base+end)
        else:
            re = processIndex(base+'_'+str(i)+end)
        if len(re) == 0:
            break
        filename = '证监会行政处罚决定摘录_'+str(i)+'.xls'
        outputFormat.outputFormat(filename, re)
        i = i+1
    end = time.time()
    print('PROCESSED:%.2fs' % (end-start))
    print('END:'+time.ctime(end))

def test():
    url = 'http://www.csrc.gov.cn/pub/zjhpublic/G00306212/201901/t20190118_349953.htm'
    processPage(url)

if __name__ == '__main__':
    main()
    # test()
