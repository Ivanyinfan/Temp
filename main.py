#!/usr/bin/env python
import pika
import config
import cx_Oracle


class DatabaseServer():
    def __init__(self, dbPara, prefix='R_SD_'):
        self.prefix = prefix
        self.con = cx_Oracle.connect(**dbPara)
        self.cursor = self.con.cursor()

    def addTable(self, tableName):
        print('[DatabaseServer][addTable]tableName='+tableName)
        sTableName = self.prefix + tableName
        re = self.__tableExist__(sTableName)
        print('[DatabaseServer][addTable]tableExist='+str(re))
        if re == False:
            self.__addShadowTable__(tableName)

    def __tableExist__(self, tableName):
        sql = 'select count(*) from user_tables where table_name=:tablename'
        self.cursor.execute(sql, tableName=str.upper(tableName))
        re = self.cursor.fetchone()
        return re[0] != 0

    def __addShadowTable__(self, tableName):
        sTableName = self.prefix + tableName
        sql = 'create table ' + sTableName + \
            ' as select * from ' + tableName + ' where 1=2'
        self.cursor.execute(sql)
        sql = 'alter table ' + sTableName + ' add (REP_SYNC_ID number)'
        self.cursor.execute(sql)
        sql = 'alter table ' + sTableName + \
            ' add (REP_OPERATIONTYPE CHAR(1 BYTE))'
        self.cursor.execute(sql)

    def __addTigger__(self, tableName):
        pass


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
    db = DatabaseServer(config.oracle)
    #pub = Publiser(config.pika)
    pub = None
    cmd = 'addtable test'
    cmd = cmd.split(' ')
    for c in command:
        if c[0] == cmd[0]:
            if len(cmd) != c[1]+1:
                print(c[3])
                exit
            c[2](db, pub, cmd[1:])
            break
    # while True:
    #     cmd = input('> ')
    #     cmd = cmd.split(' ')
    #     for c in command:
    #         if c[0] == cmd[0]:
    #             if len(cmd) != c[1]+1:
    #                 print(c[3])
    #                 exit
    #             c[2](db, pub, cmd[1:])
    #             break


if __name__ == '__main__':
    main()
