import os
import json
import math
import time
import threading
import multiprocessing

import config
import MQServer
import DatabaseServer

PUBLISHER_DATABASE = None
PUBLISHER_MQ = None
SUBSCRIBER_DATABASE = None
SUBSCRIBER_MQ = None
PUBLISHER_FILE = 'PUBLISHER.json'
SUBSCRIBER_FILE = 'SUBSCRIBER.json'
PUBLISHER_NAME = 'PUBLISHER.'
SUBSCRIBER_NAME = 'SUBSCRIBER'
UPDATE_INTERVAL = 3
CACHE_SIZE_MAXIMUM = 50000
THREADS_MAXIMUM = 20
THREADS_MIN_THRESHOLD = 5
THREADS_MAX_THRESHOLD = 30

QUEUE = multiprocessing.Queue()
addThread = 0
reduceThread = 0
tableMap = dict()
db = None
sen = None
rec = None
lock = None


def loadFile(fileName):
    global tableMap
    if not os.path.exists(fileName):
        print('[loadFile]WARNING: file not exists')
        return
    f = open(fileName, 'r')
    tableMap = json.load(f)
    f.close()


def adjustThreadsNum():
    global addThread, reduceThread, THREADS_MAXIMUM, THREADS_MAX_THRESHOLD, THREADS_MIN_THRESHOLD
    if addThread > 2:
        THREADS_MAXIMUM = min(THREADS_MAXIMUM+1, THREADS_MAX_THRESHOLD)
        addThread = 0
    elif reduceThread > 2:
        THREADS_MAXIMUM = max(THREADS_MAXIMUM-1, THREADS_MIN_THRESHOLD)
        reduceThread = 0


def Publisher(name, dbName, dbHost, dbPort, dbUser, dbPassword, dbDatabase, MQHost, MQPort, recover):
    global PUBLISHER_DATABASE
    global db, sen
    PUBLISHER_DATABASE = {
        'name': dbName,
        'host': dbHost,
        'port': dbPort,
        'user': dbUser,
        'password': dbPassword,
        'database': dbDatabase
    }
    db = DatabaseServer.DatabaseServer(**PUBLISHER_DATABASE)
    sen = MQServer.Sender(config.pika)
    process = multiprocessing.Process(target=pub_manager, args=(
        PUBLISHER_DATABASE, PUBLISHER_MQ, QUEUE, recover,))
    process.start()
    return True


def pub_addTable(tableName):
    print('[Publisher][pub_addTable]tableName'+tableName)
    db.pub_addTable(tableName)
    put = {
        'from': 'father',
        'to': 'manager',
        'operation': 'addTable',
        'tableName': tableName
    }
    QUEUE.put(put)


def pub_deleteTable(tableName):
    print('[Publisher][pub_addTable]tableName'+tableName)
    put = {
        'from': 'father',
        'to': 'manager',
        'operation': 'deleteTable',
        'tableName': tableName
    }
    QUEUE.put(put)


def pub_checkStatus():
    print('[Publisher][checkStatus]...')
    put = {
        'from': 'father',
        'to': 'manager',
        'operation': 'checkStatus'
    }
    QUEUE.put(put)
    while True:
        try:
            re = QUEUE.get(True, 30)
        except:
            print('[Publisher][checkStatus]time out')
            return
        else:
            if re['to'] != 'father':
                QUEUE.put(re)
                time.sleep(3)
            else:
                break
    print(tableMap)


def pub_exit(save):
    pass


def pub_manager(DBConfig, MQConfig, queue, recover):
    global PUBLISHER_DATABASE, PUBLISHER_MQ
    global QUEUE, tableMap
    PUBLISHER_DATABASE = DBConfig
    PUBLISHER_MQ = MQConfig
    QUEUE = queue
    threads = 0
    lock = threading.Lock()
    t1 = t2 = float()
    addThread = reduceThread = 0
    db = DatabaseServer.DatabaseServer(**PUBLISHER_DATABASE)
    senSub = None

    def pub_callback(channel, method, properties, body):
        nonlocal db, senSub, lock
        body = body.decode()
        print("[pub_callback]body=%s" % (body))
        if not senSub.judgeCorID(properties.correlation_id):
            return

        def checkStatus():
            lock.acquire()
            re = str(tableMap)
            lock.release()
            rk = reply+'.checkStatus'
            senSub.send(rk, re)

        def addTable():
            global tableMap
            nonlocal reply
            if 'tableName' not in cmd:
                return
            tableName = cmd['tableName']
            print('[pub_callback]tableName='+tableName)
            lock.acquire()
            if tableName not in tableMap:
                lock.release()
                send = {
                    'type': 0,
                    'data': None,
                    'minId': -1,
                    'maxId': -1,
                    'column': None
                }
                rk = reply+'.'+tableName
                senSub.send(rk, str(send))
                return
            lock.release()
            put = {
                'from': 'listenSub',
                'operation': 'addTable',
                'tableName': tableName,
                'reply': reply
            }
            QUEUE.put(put)

        def deleteTable():
            nonlocal reply
            if 'tableName' not in cmd:
                return
            tableName = cmd['tableName']
            put = {
                'from': 'listenSub',
                'operation': 'deleteTable',
                'tableName': tableName,
                'reply': reply
            }
            QUEUE.put(put)

        cmd = eval(body)
        try:
            op = cmd['operation']
            reply = cmd['reply']
        except:
            return
        if op == 'checkStatus':
            checkStatus()
        elif op == 'addTable':
            addTable()
        elif op == 'deleteTable':
            deleteTable()

    def listenSub():
        print('[listenSub]...')
        senSub.listenSub()

    def checkTable(tableName):
        try:
            re = tableMap[tableName]['reply']
            up = tableMap[tableName]['update']
        except:
            return False
        if len(re) > 0:
            return True
        if len(up) > 0:
            return True
        return False

    def sleep(left):
        t = time.time()
        while left > 0:
            try:
                cmd = QUEUE.get(True, left)
            except:
                return
            else:
                processCmd(cmd)
                left -= time.time() - t

    def processCmd(cmd):
        try:
            fromm = cmd['from']
            op = cmd['operation']
        except:
            print('[processCmd]ERROR: illegal cmd %s' % (cmd))
        print('[processCmd]from=%s,op=%s' % (fromm, op))
        lock.acquire()
        if fromm == 'father':
            if op == 'EXIT':
                for tableName in tableMap:
                    tableMap[tableName]['continue'] = False
                for tableName in tableMap:
                    while tableMap[tableName]['busy'] == True:
                        lock.release()
                        time.sleep(3)
                        lock.acquire()
                if cmd['save'] == True:
                    f = open(PUBLISHER_FILE, 'w')
                    json.dump(tableMap, f)
                    f.close()
                exit(0)
            tableName = cmd['tableName']
            if op == 'deleteTable':
                if tableName not in tableMap:
                    print('[pub_manager]ERROR: table not exists')
                else:
                    tableMap.pop(tableName)
                    t = threading.Thread(
                        target=pub_deleteTable, args=(tableName,))
                    t.start()
            elif op == 'addTable':
                if tableName in tableMap:
                    print('[pub_manager]ERROR: table already exists')
                else:
                    tmp = {
                        'reply': list(),
                        'busy': False,
                        'continue': False,
                        'update': list()
                    }
                    tableMap[tableName] = tmp
            elif op == 'update':
                return 0
            else:
                print('[pub_manager]ERROR: undefined cmd operation')
        elif fromm == 'listenSub':
            if op == 'addTable':
                tableName = cmd['tableName']
                reply = cmd['reply']
                update = {'operation': 'addTable', 'serverName': reply}
                tableMap[tableName]['update'].append(update)
            elif op == 'deleteTable':
                tableName = cmd['tableName']
                reply = cmd['reply']
                update = {'operation': 'deleteTable', 'serverName': reply}
                tableMap[tableName]['update'].append(update)
            else:
                print('[processCmd]ERROR: undefined cmd operation')
        else:
            print('[processCmd]ERROR: undefined resource')
        lock.release()
        return 1

    def processCmdBetween(cmd):
        print('[processCmdBetween]...')
        return 3

    def sub_addTable(tableName, reply):
        nonlocal db, senSub
        print('[sub_addTable]tableName=' + tableName)
        first = True
        while True:
            data, minId, maxId, column = db.sub_addTable(
                tableName, first)
            if first == True:
                first = False
            send = {
                'type': 0,
                'data': data,
                'minId': minId,
                'maxId': maxId,
                'column': column
            }
            rk = reply+'.'+tableName
            senSub.send(rk, str(send))
            if maxId != -1:
                break

    # 调用时有锁，返回时不放锁
    def startThread(tableName):
        global tableMap
        nonlocal threads, lock, t1
        if threads >= THREADS_MAXIMUM:
            while True:
                lock.release()
                cmd = QUEUE.get()
                if processCmdBetween(cmd) == 3:
                    lock.acquire()
                    break
        if checkTable(tableName) == False:
            return
        tableMap[tableName]['busy'] = True
        threads += 1
        thread = threading.Thread(
            target=pub_sendUpdate, args=(tableName, reply))
        thread.start()

    def pub_sendUpdate(tableName, reply):
        global tableMap
        nonlocal threads, lock
        db = DatabaseServer.DatabaseServer(**PUBLISHER_DATABASE)
        sen = MQServer.Sender(config.pika)

        def sendUpdate(tableName):
            nonlocal db, sen, reply
            # print('[pub_sendUpdate]tableName=' + tableName)
            update, column = db.pub_getUpdate(tableName)
            if len(update) == 0:
                return
            data = {
                'type': 1,
                'tableName': tableName,
                'data': update,
                'column': column
            }
            for r in reply:
                rk = r+'.'+tableName
                sen.send(rk, str(data))

        while True:
            sendUpdate(tableName)
            while True:
                lock.acquire()
                if checkTable(tableName) == False:
                    return
                up = tableMap[tableName]['update'].copy()
                if len(up) == 0:
                    break
                tableMap[tableName]['update'].clear()
                lock.release()
                for u in up:
                    try:
                        op = u['operation']
                        se = u['serverName']
                    except:
                        print('[pub_sendUpdate]ERROR: illegal update %s' %
                              (str(u)))
                    if op == 'addTable':
                        try:
                            tableMap[tableName]['reply'].index(se)
                        except:
                            tableMap[tableName]['reply'].append(se)
                            sub_addTable(tableName, se)
                        else:
                            print('[pub_sendUpdate]ERROR: server already exists')
                    elif op == 'deleteTable':
                        try:
                            tableMap[tableName]['reply'].remove(se)
                        except:
                            print('[pub_sendUpdate]ERROR: server not exists')
                    else:
                        print(
                            '[pub_sendUpdate]ERROR: undefined update operation %s' % (str(op)))
            if tableMap[tableName]['continue'] == False:
                tableMap[tableName]['busy'] = False
                threads -= 1
                lock.release()
                break
            tableMap[tableName]['busy'] = True
            tableMap[tableName]['continue'] = False
            reply = tableMap[tableName]['reply']
            lock.release()

    def pub_deleteTable(tableName):
        db = DatabaseServer.DatabaseServer(**PUBLISHER_DATABASE)
        db.pub_deleteTable(tableName)

    def pub_exit(save=True):
        pass

    if recover == True:
        loadFile(PUBLISHER_FILE)
    senSub = MQServer.SenderSub(config.pika, pub_callback)
    listenThread = threading.Thread(target=listenSub)
    listenThread.start()
    while True:
        print('[pub_manager]...')
        t1 = time.time()
        lock.acquire()
        if not QUEUE.empty():
            cmd = QUEUE.get_nowait()
            processCmd(cmd)
        for k in tableMap:
            reply = tableMap[k]['reply']
            if checkTable(k) == False:
                continue
            if tableMap[k]['busy'] == False:
                startThread(k)
            else:
                tableMap[k]['continue'] = True
        lock.release()
        t2 = time.time()
        spend = t2 - t1
        if spend > UPDATE_INTERVAL:
            addThread += 1
            reduceThread = 0
        else:
            addThread = 0
            reduceThread += 1
        left = UPDATE_INTERVAL - spend
        sleep(left)


def Subscriber(name, dbName, dbHost, dbPort, dbUser, dbPassword, dbDatabase, MQHost, MQPort, recover):
    global SUBSCRIBER_DATABASE
    global db, rec, lock
    SUBSCRIBER_DATABASE = {
        'name': dbName,
        'host': dbHost,
        'port': dbPort,
        'user': dbUser,
        'password': dbPassword,
        'database': dbDatabase
    }
    if recover == True:
        loadFile(SUBSCRIBER_FILE)
    db = DatabaseServer.DatabaseServer(**SUBSCRIBER_DATABASE)
    lock = threading.Lock()
    thread = threading.Thread(target=sub_manager, args=(QUEUE,))
    thread.start()
    return True


def sub_addTable(tableName):
    lock.acquire()
    if tableName in tableMap:
        print('[sub_addTable]ERROR: table already exists')
        lock.release()
        return
    tmp = dict()
    tmp['busy'] = False
    tmp['cached'] = False
    tmp['minId'] = -1
    tmp['maxId'] = -1
    tmp['minUpdated'] = False
    tmp['maxUpdated'] = False
    tableMap[tableName] = tmp
    rec.subscibe(tableName)
    lock.release()


def sub_deleteTable(tableName):
    lock.acquire()
    try:
        tableMap.pop(tableName)
    except:
        print('[sub_deleteTable]ERROR: table not exists')
    else:
        rec.unSubscibe(tableName)
    finally:
        lock.release()


def sub_checkStatus():
    pass


def sub_exit(save):
    pass


def sub_manager(queue):
    global SUBSCRIBER_DATABASE
    global tableMap, lock, addThread, reduceThread, rec, QUEUE
    QUEUE = queue
    threads = 0

    def startThread(tableName, data):
        print('body='+str(type(data)))
        global addThread, reduceThread
        nonlocal threads
        if threads >= THREADS_MAXIMUM:
            lock.release()
            addThread += 1
            time.sleep(3)
        else:
            reduceThread += 1
        tableMap[tableName]['busy'] = True
        threads += 1
        thread = threading.Thread(
            target=sub_parseUpdate, args=(tableName, data))
        thread.start()
        lock.release()

    def sub_parseUpdate(tableName, data):
        global tableMap
        nonlocal threads
        print('sub_parseUpdatebody='+str(type(data)))

        def parseUpdate(data, minId, maxId, minUpdated, maxUpdated):
            print('parseUpdatebody='+str(type(data)))
            nonlocal tableName
            db = DatabaseServer.DatabaseServer(**SUBSCRIBER_DATABASE)
            updateMap = False
            firstAll = False
            firstUpdate = False
            typee = data['type']
            print('[parseUpdate]tableName=%s,type=%d' %
                  (tableName, typee))
            print('[parseUpdate]minId=%d,maxId=%d' %
                  (minId, maxId))
            print('[parseUpdate]minUpdated=%d,maxUpdated=%d' %
                  (minUpdated, maxUpdated))
            update = data['data']
            column = data['column']
            # print('[Subscriber][sub_callback]update=%s' % (update))
            if update == None and column == None:
                print('[parseUpdate]ERROR: table %s not exists' % (tableName))
                return
            if maxId == -1:
                if typee == 0:
                    if data['minId'] != -1:
                        minId = data['minId']
                        updateMap = True
                        firstAll = True
                    if data['maxId'] != -1:
                        maxId = data['maxId']
                        updateMap = True
                        firstUpdate = True
                    db.getAllData(tableName, column, update, firstAll)
                else:
                    lock.acquire()
                    db.cacheUpdate(tableName, update, column)
                    tableMap[tableName]['cached'] = True
                    lock.release()
                typee = 1
                update.clear()
            if maxId == -1:
                return
            if typee == 0:
                return
            if firstUpdate == True:
                lock.acquire()
                if tableMap[tableName]['cached'] == True:
                    db.cacheUpdate(tableName, update, column)
                    lock.release()
                    return
                lock.release()
            if minUpdated == False:
                length = len(update)
                for i in range(length):
                    if update[i][-2] > minId:
                        minUpdated = True
                        updateMap = True
                        update = update[i:]
                        break
                else:
                    return
            updateBet = list()
            if maxUpdated == False:
                length = len(update)
                for i in range(length):
                    if update[i][-2] > maxId:
                        maxUpdated = True
                        updateMap = True
                        updateBet = update[:i]
                        update = update[i:]
                        break
                else:
                    updateBet = update
                    update = []
            # print('[Subscriber][sub_callback]updateBet=%s' % (updateBet))
            # print('[Subscriber][sub_callback]update=%s' % (update))
            if len(updateBet) != 0:
                db.updateBetData(tableName, updateBet)
            db.updateData(tableName, update)
            if updateMap == True:
                tableMap[tableName]['minId'] = minId
                tableMap[tableName]['maxId'] = maxId
                tableMap[tableName]['minUpdated'] = minUpdated
                tableMap[tableName]['maxUpdated'] = maxUpdated

        while True:
            parseUpdate(data, tableMap[tableName]['minId'], tableMap[tableName]['maxId'],
                        tableMap[tableName]['minUpdated'], tableMap[tableName]['maxUpdated'])
            lock.acquire()
            ca = tableMap[tableName]['cached']
            print('[sub_parseUpdate]cached=%s' % (ca))
            if ca == False or tableMap[tableName]['maxId'] == -1:
                tableMap[tableName]['busy'] = False
                threads -= 1
                lock.release()
                break
            data, next = db.getCacheUpdate(tableName)
            if next == False:
                tableMap[tableName]['cached'] = False
            lock.release()

    def sub_callback(channel, method, properties, body):
        if not rec.judgeCorID(properties.correlation_id):
            return
        body = eval(body.decode())
        print('body='+str(type(body)))
        typee = method.routing_key.split('.')[-1]
        print('[sub_callback]type='+typee)
        if typee == 'checkStatus':
            return
        tableName = typee
        lock.acquire()
        if tableMap[tableName]['busy'] == False:
            startThread(tableName, body)
            adjustThreadsNum()
        else:
            db.cacheUpdate(tableName, body['update'], body['column'])
            tableMap[tableName]['cached'] = True
            lock.release()

    rec = MQServer.Receiver(config.pika, sub_callback)
    rec.receive()
