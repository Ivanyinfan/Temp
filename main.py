#!/usr/bin/env python
import config
import PubSub


def pub_addTable(pub, sub, args):
    print('[pub_addTable]tableName='+args[0])
    pub.pub_addTable(args[0])


def sub_addTable(pub, sub, args):
    sub.addTable(args[0])


command = [
    ['pubAddTable', 1, pub_addTable, 'USEAGE: pubAddTable tableName'],
    ['subAddTable', 1, sub_addTable, 'USEAGE: subAddTable tableName']
]


def main():
    pub = None
    sub = None
    pub = PubSub.Publisher()
    # sub = PubSub.Subscriber()
    # PubSub.Publisher()
    cmd = 'pubAddTable test'
    cmd = cmd.split(' ')
    for c in command:
        if c[0] == cmd[0]:
            if len(cmd) != c[1]+1:
                print(c[3])
                exit
            c[2](pub, sub, cmd[1:])
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
