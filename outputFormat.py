#!/usr/bin/env python
# Copyright Ivan_yin 2019.3.14
# All rights reserved
import os
import xlwt


def outputFormat(filename, result):
    if type(result) == dict:
        tmp = list()
        tmp.append(result)
        result = tmp
    if type(result) != list:
        print('[outputFormat]ERROR')
        exit
    row = len(result)
    if row == 0:
        print('[outputFormat]WARNING')
        exit
    if os.path.exists(filename):
        os.remove(filename)
    w = xlwt.Workbook()
    ws = w.add_sheet('Sheet1')
    keys = list(result[0].keys())
    column = len(keys)
    for i in range(column):
        ws.write(0, i, keys[i])
    for i in range(row):
        for j in range(column):
            ws.write(i+1, j, result[i][keys[j]])
    w.save(filename)


if __name__ == '__main__':
    filename = "test.xlsx"
    result = dict(test='test')
    outputFormat(filename, result)
    os.remove(filename)
