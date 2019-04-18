#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright Ivan_yin 2019.4.17
# All rights reserved
import os
import sys
import time
import cx_Oracle
sys.path.append('../')
import config
import DatabaseServer


class Oracle(DatabaseServer.Server):
    def __init__(self):
        self.con = cx_Oracle.connect(**config.oracle)
        self.cursor = self.con.cursor()
        self.column = '(id, name)'
        self.values = '(:1, :2)'
        self.col_val = 'id=:1, name=:2'

    def insert(self, tableName, value):
        self._insertOperation(tableName, value)
        self.con.commit()

    def delete(self, tableName, value):
        self.colAndVal = 'id=:1 and name=:2'
        self._deleteOperation(tableName, value)
        self.con.commit()

    def update(self, tableName, oldValue, newValue):
        self.colAndVal = 'id=:3 and name=:4'
        self._updateOperation(tableName, oldValue, newValue)
        self.con.commit()


def main():
    filename = 'update.txt'
    if not os.path.exists(filename):
        filename = input('>')
        while not os.path.exists(filename):
            filename = input('>')
    f = open(filename)
    lines = f.readlines()
    length = len(lines)
    db = Oracle()
    i = 0
    while i < length:
        print('[main]i=%d' % (i))
        line = lines[i]
        line = eval(line)
        table = line[0]
        opera = line[1]
        value = line[2:-1]
        inter = line[-1]
        if opera == 'I':
            db.insert(table, value)
        elif opera == 'D':
            db.delete(table, value)
        else:
            newval = eval(lines[i+1])[2:-1]
            db.update(table, value, newval)
            i = i + 1
        i = i + 1
        time.sleep(inter)


if __name__ == "__main__":
    main()
