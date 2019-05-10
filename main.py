#!/usr/bin/env python
import sys
import config
import PubSub


def pub_addTable(pub, sub, args):
    print('[pub_addTable]tableName='+args[0])
    pub.pub_addTable(args[0])


def sub_addTable(pub, sub, args):
    print('[sub_addTable]tableName='+args[0])
    sub.addTable(args[0])


def addTable(pub, sub, args):
    if pub == None:
        sub_addTable(pub, sub, args)
    else:
        pub_addTable(pub, sub, args)


def deleteTable(pub, sub, args):
    if pub == None:
        sub.deleteTable(args[0])
    else:
        pub.deleteTable(args[0])


command = [
    ['addTable', 1, addTable, 'USEAGE: addTable tableName'],
    ['deleteTable', 1, deleteTable, 'USEAGE: deleteTable tableName']
]


def main(argc, argv):
    if argc < 2:
        return
    if argv[1] == 'pub':
        sub = None
        pub = PubSub.Publisher()
    elif argv[1] == 'sub':
        pub = None
        sub = PubSub.Subscriber()
    else:
        return
    while True:
        cmd = input('> ')
        cmd = cmd.split(' ')
        for c in command:
            if c[0] == cmd[0]:
                if len(cmd) != c[1]+1:
                    print(c[3])
                    exit
                c[2](pub, sub, cmd[1:])
                break
        else:
            print('undefined command')


if __name__ == '__main__':
    argv = sys.argv
    main(len(argv), argv)
