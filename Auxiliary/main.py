#!/usr/bin/env python
# Copyright Ivan_yin 2019.3.26
# All rights reserved
import re


def findTablespaceName():
    f = open('D:\下载\DatabaseSynchronization\Publisher\SQL\Tablespace.sql')
    c = f.read()
    tablespaceName = re.findall('CREATE TABLESPACE (.*) DATAFILE', c)
    f.close()
    return tablespaceName


def dropAllTablespace(name):
    if type(name) == str:
        tmp = list()
        tmp.append(name)
        name = tmp
    if type(name) != list:
        print('[dropAllTablespace]\t[ERROR]')
        return
    if len(name) == 0:
        print('[dropAllTablespace]\t[WARNING]')
        return
    f = open('D:\下载\DatabaseSynchronization\Auxiliary\dropAllTablespace.sql', 'w')
    for n in name:
        f.write('drop tablespace ' + n +
                ' including contents and datafiles cascade constraint;\n')
    f.close()


if __name__ == "__main__":
    dropAllTablespace(findTablespaceName())
