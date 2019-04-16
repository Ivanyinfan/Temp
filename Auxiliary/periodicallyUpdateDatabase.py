#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright Ivan_yin 2019.4.15
# All rights reserved
import sys
import time
import cx_Oracle
sys.path.append('../')
import config


def main():
    table = input('>')
    periodicallyUpdateDatabase(table)


def periodicallyUpdateDatabase(tableName):
    con = cx_Oracle.connect(**config.oracle)
    con.autocommit = True
    cursor = con.cursor()
    for i in range(1000):
        print('[periodicallyUpdateDatabase]i=%d' % (i))
        sql = 'insert into ' + tableName
        sql = sql + '(id, name) values (:id, :name)'
        cursor.execute(sql, id=i, name='a')
        con.commit()
        time.sleep(3)


if __name__ == "__main__":
    main()
