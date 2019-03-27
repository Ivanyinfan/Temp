#!/usr/bin/env python
# Copyright Ivan_yin 2019.3.13
# All rights reserved


def loadParams(filename):
    if type(filename) != str:
        print('[loadParams]ERROR')
        exit
    result = list()
    f = open(filename)
    for l in f:
        result.append(l.replace('\n', ''))
    f.close()
    return result


# 处罚类型
TYPE = loadParams('Type.txt')

# 涉及会计师事务所
ACCOUNTINGFIRM = loadParams('AccountingFirm.txt')

# 城市
CITY = loadParams('City.txt')