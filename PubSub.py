import time
import threading
import multiprocessing

import config
import MQServer
import DatabaseServer

PUBLISHER_DATABASE = "Oracle"
UPDATE_INTERVAL = 10


class Publisher():
    def __init__(self, dbName='Oracle'):
        self.dbName = dbName
        self.db = DatabaseServer.DatabaseServer(dbName)
        self.sen = MQServer.Sender(config.pika)
        self.tableMap = dict()
        self.thread = threading.Thread(target=self.__listenSub)
        self.thread.start()

    def pub_addTable(self, tableName):
        print('[_Publisher_pub_addTable]tableName'+tableName)
        process = multiprocessing.Process(
            target=pub_addTable, args=(tableName,))
        self.tableMap[tableName] = process
        process.start()

    def pub_callback(self, channel, method, properties, body):
        print("[_Publisher_pub_callback] %s:%s" % (method.routing_key, body))
        if not self.sen.judgeCorID(properties.correlation_id):
            return
        tableName = body.decode()
        data, id = self.db.sub_addTable(tableName)
        data = {'tableName': tableName, 'type': 0, 'data': data, 'id': id}
        data = str(data)
        self.sen.send(tableName, data)

    def deleteTable(self, tableName):
        process = self.tableMap[tableName]
        process.terminate()
        process.join()
        self.db.pub_deleteTable(tableName)

    def __listenSub(self):
        print('[_Publisher__listenSub]...')
        db = DatabaseServer.DatabaseServer(self.dbName)
        senSub = None

        def pub_callback(channel, method, properties, body):
            nonlocal db, senSub
            print("[_Publisher_pub_callback] %s:%s" %
                  (method.routing_key, body))
            if not senSub.judgeCorID(properties.correlation_id):
                return
            tableName = body.decode()
            print('[pub_callback]tableName='+tableName)
            data, minId, maxId, column = db.sub_addTable(tableName, True)
            send = {
                'tableName': tableName,
                'type': 0,
                'data': data,
                'minId': minId,
                'maxId': maxId,
                'column': column
            }
            send = str(send)
            senSub.send(tableName, send)
            if data == None and minId == -1 and maxId == -1 and column == None:
                return
            while maxId == -1:
                data, minId, maxId, column = db.sub_addTable(tableName, False)
                send = {
                    'tableName': tableName,
                    'type': 0,
                    'data': data,
                    'minId': minId,
                    'maxId': maxId,
                }
                senSub.send(tableName, str(send))

        db = DatabaseServer.DatabaseServer(self.dbName)
        senSub = MQServer.SenderSub(config.pika, pub_callback)
        senSub.listenSub()

    def __publishUpdate(self, tableName):
        pass


def pub_listenSub(dbName):
    print('[pub_listenSub]dbName=%s' % (dbName))
    senSub = None

    def pub_callback(channel, method, properties, body):
        print("[_Publisher_pub_callback] %s:%s" % (method.routing_key, body))
        if not senSub.judgeCorID(properties.correlation_id):
            return
        tableName = body.decode()
        print('[pub_callback]tableName='+tableName)
        data, id = db.sub_addTable(tableName)
        data = {'tableName': tableName, 'type': 0, 'data': data, 'id': id}
        data = str(data)
        print('[pub_callback]data='+data)
        senSub.send(tableName, data)

    senSub = MQServer.SenderSub(config.pika, pub_callback)
    senSub.listenSub()


def pub_addTable(tableName):
    print('[pub_addTable]tableName=%s' % (tableName))
    db = DatabaseServer.DatabaseServer(PUBLISHER_DATABASE)
    sen = MQServer.Sender(config.pika)
    db.pub_addTable(tableName)
    busy = False
    waiting = False
    lock = threading.Lock()

    def pub_sendUpdate(tableName):
        print('[pub_sendUpdate]tableName='+tableName)
        nonlocal busy, waiting, lock
        lock.acquire()
        print('[pub_sendUpdate]busy='+str(busy))
        if busy == True:
            lock.release()
            return
        busy = True
        lock.release()
        update = db.pub_getUpdate(tableName)
        if len(update) != 0:
            data = {'tableName': tableName, 'type': 1, 'data': update}
            sen.send(tableName, str(data))
        lock.acquire()
        busy = False
        lock.release()
        if waiting == True:
            waiting = False
            thread = threading.Thread(target=pub_sendUpdate, args=(tableName,))
            thread.start()

    while True:
        thread = threading.Thread(target=pub_sendUpdate, args=(tableName,))
        thread.start()
        time.sleep(UPDATE_INTERVAL)


class Subscriber():
    def __init__(self, dbName='MySQL'):
        self.dbName = dbName
        self.db = DatabaseServer.DatabaseServer(dbName)
        self.rec = MQServer.Receiver(config.pika, self.sub_callback)
        self.tableMap = dict()
        self.id = -1
        self.updated = False

    def addTable(self, tableName):
        print('[_Subscriber_addTable]tableName='+tableName)
        process = multiprocessing.Process(
            target=sub_addTable, args=(self.dbName, tableName))
        self.tableMap[tableName] = process
        process.start()

    def __addTable(self, tableName):
        db = DatabaseServer.DatabaseServer(self.dbName)
        db.getTableMap(tableName)
        db.deleteTable(tableName)
        rec = None
        minId = -1
        maxId = -1
        minUpdated = False
        maxUpdated = False
        cache = list()

        def sub_callback(channel, method, properties, body):
            nonlocal db, rec, minId, maxId, minUpdated, maxUpdated, cache
            tableName = method.routing_key
            data = eval(body.decode())
            typee = data['type']
            print('[Subscriber][sub_callback]tableName=%s,type=%d' %
                  (tableName, typee))
            print('[Subscriber][sub_callback]minId=%d,maxId=%d' %
                  (minId, maxId))
            print('[Subscriber][sub_callback]minUpdated=%d,maxUpdated=%d' %
                  (minUpdated, maxUpdated))
            update = data['data']
            print('[Subscriber][sub_callback]update=%s' % (update))
            if maxId == -1:
                if typee == 0:
                    minId = data['minId']
                    if minId == -1:
                        print('ERROR')
                        rec.stopConsuming()
                    else:
                        maxId = data['maxId']
                        db.getAllData(tableName, update)
                else:
                    cache = cache + update
            else:
                if minUpdated == False:
                    if len(cache) != 0:
                        update = cache + update
                        cache.clear()
                    length = len(update)
                    for i in range(length):
                        if update[i][-2] > minId:
                            minUpdated = True
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
                            updateBet = update[:i]
                            update = update[i:]
                            break
                    else:
                        updateBet = update
                        update = []
                print('[Subscriber][sub_callback]updateBet=%s' % (updateBet))
                print('[Subscriber][sub_callback]update=%s' % (update))
                if len(updateBet) != 0:
                    db.updateBetData(tableName, updateBet)
                re = db.updateData(tableName, update)
                if re:
                    rec.stopConsuming()

        rec = MQServer.Receiver(config.pika, sub_callback)
        rec.subscibe(tableName)

    def deleteTable(self, tableName):
        process = self.tableMap[tableName]
        process.terminate()
        process.join()

    def sub_callback(self, channel, method, properties, body):
        tableName = method.routing_key
        data = eval(body.decode())
        typee = data['type']
        print('[_Subscriber_sub_callback]tableName=%s,type=%d,self.id=%d,self.updated=%s' % (
            tableName, typee, self.id, self.updated))
        if self.id == -1:
            if typee == 0:
                id = data['id']
                if id == -1:
                    print('ERROR')
                    self.rec.stopConsuming()
                else:
                    self.id = id
                    self.__getAllData(tableName, data['data'])
        else:
            self.__updateData(tableName, data['data'])

    def __getAllData(self, tableName, data):
        self.db.getAllData(tableName, data)

    def __updateData(self, tableName, data):
        if self.updated == False:
            length = len(data)
            for i in range(length):
                if data[i][-2] > self.id:
                    self.updated = True
                    data = data[i:]
                    break
            else:
                return
        self.db.updateData(tableName, data)


def sub_addTable(dbName, tableName):
    db = DatabaseServer.DatabaseServer(dbName)
    db.getTableMap(tableName)
    db.deleteTable(tableName)
    rec = None
    minId = -1
    maxId = -1
    column = None
    minUpdated = False
    maxUpdated = False
    cache = list()

    def sub_callback(channel, method, properties, body):
        nonlocal db, rec, minId, maxId, column, minUpdated, maxUpdated, cache
        tableName = method.routing_key
        data = eval(body.decode())
        typee = data['type']
        print('[Subscriber][sub_callback]tableName=%s,type=%d' %
              (tableName, typee))
        print('[Subscriber][sub_callback]minId=%d,maxId=%d' %
              (minId, maxId))
        print('[Subscriber][sub_callback]minUpdated=%d,maxUpdated=%d' %
              (minUpdated, maxUpdated))
        update = data['data']
        # print('[Subscriber][sub_callback]update=%s' % (update))
        if maxId == -1:
            if typee == 0:
                maxId = data['maxId']
                if 'column' in data:
                    column = data['column']
                    if column == None:
                        print('ERROR')
                        rec.stopConsuming()
                        return
                    else:
                        minId = data['minId']
                db.getAllData(tableName, column, update)
            else:
                cache = cache + update
            typee = 1
            update.clear()
        if maxId == -1:
            return
        if typee == 0:
            return
        if minUpdated == False:
            if len(cache) != 0:
                update = cache + update
                cache.clear()
            length = len(update)
            for i in range(length):
                if update[i][-2] > minId:
                    minUpdated = True
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
        re = db.updateData(tableName, update)
        if re:
            rec.stopConsuming()

    rec = MQServer.Receiver(config.pika, sub_callback)
    rec.subscibe(tableName)
