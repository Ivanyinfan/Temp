#!/usr/bin/env python
import pika
import config
import MQServer
import DatabaseServer


class Publisher():
    def __init__(self):
        self.db = DatabaseServer.DatabaseServer(config.oracle)
        self.sen = MQServer.Sender(config.pika, self.pub_callback)

    def pub_addTable(self, tableName):
        self.db.addTable(tableName)

    def sub_addTable(self, tableName):
        pass

    def pub_callback(self, channel, method, properties, body):
        print(" [x] %r:%r" % (method.routing_key, body))
        if not self.sen.judgeCorID(properties.correlation_id):
            return
        self.db.sub_addTable(body)


def pub_addTable(pub, args):
    pub.pub_addTable(args[0])


command = [
    ['addtable', 1, pub_addTable, 'USEAGE: addtable tableName']
]


def main():
    pub = Publisher()
    cmd = 'addtable test'
    cmd = cmd.split(' ')
    for c in command:
        if c[0] == cmd[0]:
            if len(cmd) != c[1]+1:
                print(c[3])
                exit
            c[2](pub, cmd[1:])
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
