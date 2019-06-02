import os
import goto
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
PUBLISHER_MANAGER = None
SUBSCRIBER_MANAGER = None
PUBLISHER_FILE = 'PUBLISHER.json'
PUBLISHER_TEMP_FILE = 'PUBLISHER.bak.json'
SUBSCRIBER_FILE = 'SUBSCRIBER.json'
SUBSCRIBER_TEMP_FILE = 'SUBSCRIBER.bak.json'
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


def loadFile(fileName, tmpFile, recover):
    global tableMap
    if os.path.exists(tmpFile):
        print('[loadFile]WARNING: tmp file found, recover ignored')
        f = open(tmpFile, 'r')
        tableMap = json.load(f)
        f.close()
        return
    if recover == True:
        try:
            f = open(fileName, 'r')
            tableMap = json.load(f)
        except FileNotFoundError:
            print('[loadFile]WARNING: file not exists, recover failed')
        else:
            f.close()


def saveToFile(fileName):
    global tableMap
    f = open(fileName, 'w')
    json.dump(tableMap, f)
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
    global PUBLISHER_MANAGER, PUBLISHER_DATABASE, PUBLISHER_MQ
    global db, sen
    PUBLISHER_DATABASE = {
        'name': dbName,
        'host': dbHost,
        'port': dbPort,
        'user': dbUser,
        'password': dbPassword,
        'database': dbDatabase
    }
    PUBLISHER_MQ = {'host': MQHost, 'port': MQPort}
    db = DatabaseServer.DatabaseServer(**PUBLISHER_DATABASE)
    sen = MQServer.Sender(**PUBLISHER_MQ)
    PUBLISHER_MANAGER = multiprocessing.Process(target=pub_manager, args=(
        PUBLISHER_DATABASE, PUBLISHER_MQ, QUEUE, recover,))
    PUBLISHER_MANAGER.start()
    re = QUEUE.get()
    if re['message'] == 'error':
        print('[Publisher]ERROR: pub_manager fails to start')
        exit(0)


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
    global PUBLISHER_MANAGER
    print('[Publisher][pub_exit]...')
    put = {
        'from': 'father',
        'to': 'manager',
        'operation': 'exit',
        'args': [save]
    }
    QUEUE.put(put)
    PUBLISHER_MANAGER.join()


def pub_manager(DBConfig, MQConfig, queue, recover):
    global PUBLISHER_MANAGER, PUBLISHER_DATABASE, PUBLISHER_MQ
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
    senSubThread = None

    def pub_callback(channel, method, properties, body):
        nonlocal db, senSub, lock
        body = body.decode()
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
        global tableMap
        try:
            fromm = cmd['from']
            op = cmd['operation']
        except:
            print('[processCmd]ERROR: illegal cmd %s' % (cmd))
        print('[processCmd]from=%s,op=%s' % (fromm, op))
        lock.acquire()
        if fromm == 'father':
            if op == 'exit':
                lock.release()
                pub_exit(cmd['args'][0])
            tableName = cmd['tableName']
            if op == 'deleteTable':
                try:
                    table = tableMap.pop(tableName)
                except:
                    print('[pub_manager]ERROR: table not exists')
                else:
                    t = threading.Thread(
                        target=pub_deleteTable, args=(tableName, table))
                    t.start()
            elif op == 'addTable':
                pub_addTable(tableName)
            elif op == 'update':
                return 0
            else:
                print('[pub_manager]ERROR: undefined cmd operation')
        else:
            print('[processCmd]ERROR: undefined resource')
        lock.release()
        return 1

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
            lock.release()
            left = UPDATE_INTERVAL - (time.time() - t1)
            perLeft = max(1, left/len(tableMap.keys()))
            sleep(perLeft)
            lock.acquire()
        if checkTable(tableName) == False:
            return
        tableMap[tableName]['busy'] = True
        threads += 1
        thread = threading.Thread(
            target=pub_sendUpdate, args=(tableName, reply))
        tableMap[tableName]['thread'] = thread
        thread.start()

    def pub_sendUpdate(tableName, reply):
        global tableMap
        nonlocal threads, lock
        db = DatabaseServer.DatabaseServer(**PUBLISHER_DATABASE)
        sen = MQServer.Sender(**PUBLISHER_MQ)

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

    def pub_addTable(tableName):
        global tableMap
        if tableName in tableMap:
            print('[pub_addTable]ERROR: table already exists')
        else:
            tmp = {
                'reply': list(),
                'busy': False,
                'continue': False,
                'update': list(),
                'thread': None,
                'lastUpdate': None
            }
            tableMap[tableName] = tmp
            saveToFile(PUBLISHER_TEMP_FILE)

    def pub_deleteTable(tableName, table):
        nonlocal lock
        try:
            table['thread'].join()
        except:
            pass
        db = DatabaseServer.DatabaseServer(**PUBLISHER_DATABASE)
        db.pub_deleteTable(tableName)
        lock.acquire()
        saveToFile(PUBLISHER_TEMP_FILE)
        lock.release()

    def pub_exit(save):
        global tableMap
        nonlocal senSub
        senSub.stopConsuming()
        senSubThread.join()
        items = tableMap.items()
        for it in items:
            it['continue'] = False
        for it in items:
            try:
                it['thread'].join()
            except:
                pass
        if save == True:
            saveToFile(PUBLISHER_FILE)
        try:
            os.remove(PUBLISHER_TEMP_FILE)
        except:
            pass
        exit(0)

    loadFile(PUBLISHER_FILE, PUBLISHER_TEMP_FILE, recover)
    senSub = MQServer.SenderSub(**PUBLISHER_MQ, callback=pub_callback)
    senSubThread = threading.Thread(target=listenSub)
    senSubThread.start()
    QUEUE.put({
        'from': 'manager',
        'to': 'father',
        'message': 'complete'
    })
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
    global SUBSCRIBER_MANAGER, SUBSCRIBER_DATABASE, SUBSCRIBER_MQ
    global db, rec, lock
    SUBSCRIBER_DATABASE = {
        'name': dbName,
        'host': dbHost,
        'port': dbPort,
        'user': dbUser,
        'password': dbPassword,
        'database': dbDatabase
    }
    SUBSCRIBER_MQ = {
        'name': name,
        'host': MQHost,
        'port': MQPort
    }
    loadFile(SUBSCRIBER_FILE, SUBSCRIBER_TEMP_FILE, recover)
    db = DatabaseServer.DatabaseServer(**SUBSCRIBER_DATABASE)
    lock = threading.Lock()
    SUBSCRIBER_MANAGER = threading.Thread(target=sub_manager, args=(QUEUE,))
    SUBSCRIBER_MANAGER.start()
    while rec == None:
        time.sleep(1)
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
    tmp['thread'] = None
    tableMap[tableName] = tmp
    rec.subscibe(tableName)
    saveToFile(SUBSCRIBER_TEMP_FILE)
    lock.release()
    exit(0)


def sub_deleteTable(tableName):
    lock.acquire()
    try:
        tableMap.pop(tableName)
    except:
        print('[sub_deleteTable]ERROR: table not exists')
    else:
        rec.unSubscibe(tableName)
        saveToFile(SUBSCRIBER_TEMP_FILE)
    finally:
        lock.release()


def sub_checkStatus():
    pass


def sub_exit(save):
    global SUBSCRIBER_MANAGER
    global tableMap, rec
    rec.stopConsuming()
    SUBSCRIBER_MANAGER.join()
    for it in tableMap.items():
        try:
            it['thread'].join
        except:
            pass
    if save == True:
        saveToFile(SUBSCRIBER_FILE)
    try:
        os.remove(SUBSCRIBER_TEMP_FILE)
    except:
        pass


def sub_manager(queue):
    global SUBSCRIBER_DATABASE, SUBSCRIBER_MQ
    global tableMap, lock, addThread, reduceThread, rec, QUEUE
    QUEUE = queue
    threads = 0

    # 调用时有锁，返回时放锁
    def startThread(delivery_tag, tableName, data):
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
            target=sub_parseUpdate, args=(delivery_tag, tableName, data))
        tableMap[tableName]['thread'] = thread
        thread.start()
        lock.release()

    def sub_parseUpdate(delivery_tag, tableName, data):
        global tableMap, rec
        nonlocal threads

        @goto.with_goto
        def parseUpdate(data, minId, maxId, minUpdated, maxUpdated):
            global tableMap
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
                goto .parseUpdateEnd
            if typee == 0:
                goto .parseUpdateEnd
            if firstUpdate == True:
                lock.acquire()
                if tableMap[tableName]['cached'] == True:
                    db.cacheUpdate(tableName, update, column)
                    lock.release()
                    goto .parseUpdateEnd
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
                    goto .parseUpdateEnd
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
            db.updateData(tableName, column, update)
            label .parseUpdateEnd
            if updateMap == True:
                tableMap[tableName]['minId'] = minId
                tableMap[tableName]['maxId'] = maxId
                tableMap[tableName]['minUpdated'] = minUpdated
                tableMap[tableName]['maxUpdated'] = maxUpdated

        tt = tableMap[tableName]
        parseUpdate(data, tt['minId'], tt['maxId'],
                    tt['minUpdated'], tt['maxUpdated'])
        rec.sendAck(delivery_tag)
        while True:
            lock.acquire()
            ca = tt['cached']
            print('[sub_parseUpdate]cached=%s' % (ca))
            if ca == False or tt['maxId'] == -1:
                tt['busy'] = False
                threads -= 1
                lock.release()
                break
            data, next = db.getCacheUpdate(tableName)
            if next == False:
                tt['cached'] = False
            lock.release()
            parseUpdate(data, tt['minId'], tt['maxId'],
                        tt['minUpdated'], tt['maxUpdated'])

    def sub_callback(channel, method, properties, body):
        if not rec.judgeCorID(properties.correlation_id):
            return
        delivery_tag = method.delivery_tag
        body = eval(body.decode())
        tableName = method.routing_key.split('.')[-1]
        if tableName == 'checkStatus':
            return
        lock.acquire()
        print('[sub_callback]busy=%s' % (tableMap[tableName]['busy']))
        if tableMap[tableName]['busy'] == False:
            startThread(delivery_tag, tableName, body)
            adjustThreadsNum()
        else:
            if body['type'] == 0:
                thread = tableMap[tableName]['thread']
                lock.release()
                thread.join()
                lock.acquire()
                startThread(delivery_tag, tableName, body)
            else:
                db.cacheUpdate(tableName, body['data'], body['column'])
                tableMap[tableName]['cached'] = True
                lock.release()
                rec.sendAck(delivery_tag)

    rec = MQServer.Receiver(**SUBSCRIBER_MQ, callback=sub_callback)
    rec.receive()
