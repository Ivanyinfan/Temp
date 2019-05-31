#!/usr/bin/env python
import os
import sys
import json
import PubSub
import argparse

TYPE = None
CONFIG_FILE = 'config.json'


def addTable(args):
    global TYPE
    print('[addTable]tableName='+args[0])
    if TYPE == 'publisher':
        PubSub.pub_addTable(args[0])
    else:
        PubSub.sub_addTable(args[0])


def deleteTable(args):
    global TYPE
    if TYPE == 'publisher':
        PubSub.pub_deleteTable(args[0])
    else:
        PubSub.sub_deleteTable(args[0])


def exitt(args):
    global TYPE
    if len(args) == 0:
        save = False
    else:
        save = args[0]
        if save != 'save':
            print(command[2][4])
            return
        save = True
    if TYPE == 'publisher':
        PubSub.pub_exit(save)
    else:
        PubSub.sub_exit(save)


command = [
    ['addTable',    1, 2, addTable, 'USEAGE: addTable tableName [serverName]'],
    ['deleteTable', 1, 1, deleteTable, 'USEAGE: deleteTable tableName'],
    ['exit',        0, 1, exitt, 'USEAGE: exit [save]']
]


def parseArgs(argv):
    parser = argparse.ArgumentParser()
    argument = {
        'dest': 'type',
        'choices': ['publisher', 'subscriber'],
        'help': 'indicates the type, publisher or subscriber'
    }
    parser.add_argument(**argument)
    argument = {
        'type': str,
        'help': 'the server name'
    }
    parser.add_argument('-n', '--name', **argument)
    argument = {
        'action': 'store_true',
        'default': False,
        'help': 'load previous status'
    }
    parser.add_argument('-r', '--recover', **argument)
    args = parser.parse_args(argv)
    return args

def loadConfig(fileName):
    try:
        f = open(CONFIG_FILE)
        config = json.load(f)[TYPE]
    except FileNotFoundError as e:
        print('[main]ERROR:%s' % (e))
        exit(0)
    else:
        f.close()
        return config

def main(argc, argv):
    global TYPE
    args = parseArgs(argv[1:])
    args = vars(args)
    TYPE = args.pop('type')
    config = loadConfig(CONFIG_FILE)
    for key, value in args.items():
        if value != None:
            config[key] = value
    if TYPE == 'publisher':
        PubSub.Publisher(**config)
    else:
        PubSub.Subscriber(**config)
    while True:
        cmd = input('>')
        cmd = cmd.split(' ')
        for c in command:
            if c[0] == cmd[0]:
                argc = len(cmd) - 1
                if argc < c[1] or argc > c[2]:
                    print(c[4])
                else:
                    c[3](cmd[1:])
                break
        else:
            print('[main]ERROR: undefined command')


if __name__ == '__main__':
    argv = sys.argv
    main(len(argv), argv)
