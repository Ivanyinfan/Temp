#!/usr/bin/env python
import pika
import config
import cx_Oracle

PREFIX = 'R_SD_'


class DatabaseServer():
    def __init__(self, dbPara):
        self.prefix = PREFIX
        self.con = cx_Oracle.connect(**dbPara)
        self.cursor = self.con.cursor()

    def __addShadowTable__(self, tableName):
        stn = self.prefix + tableName
        sql = 'CREATE TABLE ' + stn + \
              '( \
                    Rep_sync_id NUMBER \
               )'
        self.cursor.execute(sql)

    def __addTigger__(self, tableName):
        pass

    def addTable(self, tableName):
        print('[DatabaseServer][addTable]tableName='+tableName)
        self.__addShadowTable__(tableName)
        self.__addTigger__(tableName)


class Publiser():
    def __init__(self, pikaPara):
        pikaConPara = pika.ConnectionParameters(**pikaPara)
        exchangePara = {'exchange': 'test', 'exchange_type': 'topic'}
        self.connection = pika.BlockingConnection(pikaConPara)
        self.channel = self.connection.channel()
        self.exchange = self.channel.exchange_declare(**exchangePara)

    def send(self, data):
        pubPara = {
            'exchange': 'test',
            'routing_key': 'test.test',
            'body': data
        }
        self.channel.basic_publish(**pubPara)


def addTable(db, pub, tableName):
    db.addTable(tableName[0])


command = [
    ['addtable', 1, addTable, 'USEAGE: addtable tableName']
]


def main():
    db = DatabaseServer(config.database)
    pub = Publiser(config.pika)
    while True:
        cmd = input('> ')
        cmd = cmd.split(' ')
        for c in command:
            if c[0] == cmd[0]:
                if len(cmd) != c[1]+1:
                    print(c[3])
                    exit
                c[2](db, pub, cmd[1:])
                break


if __name__ == '__main__':
    main()
