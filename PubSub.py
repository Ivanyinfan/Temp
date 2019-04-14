import time
import threading
import multiprocessing

import config
import MQServer
import DatabaseServer

PUBLISHER_DATABASE = "Oracle"
UPDATE_INTERVAL = 3


class Publisher():
    def __init__(self, dbName='Oracle'):
        self.dbName = dbName
        self.db = DatabaseServer.DatabaseServer(dbName)
        self.sen = MQServer.Sender(config.pika)
        self.thread = threading.Thread(target=self.__listenSub)
        self.thread.start()

    def pub_addTable(self, tableName):
        print('[_Publisher_pub_addTable]tableName'+tableName)
        process = multiprocessing.Process(
            target=pub_addTable, args=(tableName,))
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

    def __listenSub(self):
        print('[_Publisher__listenSub]...')
        senSub = None

        def pub_callback(channel, method, properties, body):
            print("[_Publisher_pub_callback] %s:%s" %
                  (method.routing_key, body))
            if not senSub.judgeCorID(properties.correlation_id):
                return
            tableName = body.decode()
            data, id = db.sub_addTable(tableName)
            data = {'tableName': tableName, 'type': 0, 'data': data, 'id': id}
            data = str(data)
            senSub.send(tableName, data)

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
        data, id = db.sub_addTable(tableName)
        data = {'tableName': tableName, 'type': 0, 'data': data, 'id': id}
        data = str(data)
        senSub.send(tableName, data)

    db = DatabaseServer.DatabaseServer(dbName)
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
        if busy == True:
            lock.release()
            return
        print('[pub_sendUpdate]tableName='+tableName)
        busy = True
        lock.release()
        update = db.pub_getUpdate(tableName)
        if len(update) != 0:
            update = str(update)
            sen.send(tableName, update)
        if waiting == False:
            lock.acquire()
            busy == False
            lock.release()
        else:
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
        self.id = -1
        self.updated = False

    def addTable(self, tableName):
        print('[_Subscriber_addTable]tableName='+tableName)
        thread = threading.Thread(
            target=self.__subTable, args=(tableName,))
        thread.start()

    def __subTable(self, tableName):
        db = DatabaseServer.DatabaseServer(self.dbName)
        db.getTableMap(tableName)
        rec = None
        maxId = -1
        updated = False

        def sub_callback(channel, method, properties, body):
            nonlocal db, rec, maxId, updated
            tableName = method.routing_key
            data = eval(body.decode())
            typee = data['type']
            print('[_Subscriber_sub_callback]tableName=%s,type=%d,maxId=%d,updated=%s' % (
                tableName, typee, maxId, updated))
            if maxId == -1:
                if typee == 0:
                    id = data['id']
                    if id == -1:
                        print('ERROR')
                        rec.stopConsuming()
                    else:
                        maxId = id
                        db.getAllData(tableName, data['data'])
            else:
                data = data['data']
                if updated == False:
                    length = len(data)
                    for i in range(length):
                        if data[i][-2] > id:
                            updated = True
                            data = data[i:]
                            break
                    else:
                        return
                re = db.updateData(tableName, data)
                if re:
                    rec.stopConsuming()

        rec = MQServer.Receiver(config.pika, sub_callback)
        rec.subscibe(tableName)

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


def sub_subTable(dbName, tableName):
    maxId = -1
    updated = False
    db = None
    rec = None

    def sub_callback(channel, method, properties, body):
        nonlocal maxId, updated
        tableName = method.routing_key
        data = eval(body.decode())
        typee = data['type']
        print('[_Subscriber_sub_callback]tableName=%s,type=%d,maxId=%d,updated=%s' % (
            tableName, typee, maxId, updated))
        if maxId == -1:
            if typee == 0:
                id = data['id']
                if id == -1:
                    print('ERROR')
                    rec.stopConsuming()
                else:
                    maxId = id
                    db.getAllData(tableName, data['data'])
        else:
            data = data['data']
            if updated == False:
                length = len(data)
                for i in range(length):
                    if data[i][-2] > id:
                        updated = True
                        data = data[i:]
                        break
                else:
                    return
            db.updateData(tableName, data)

    db = DatabaseServer.DatabaseServer(dbName)
    rec = MQServer.Receiver(config.pika, sub_callback)
    rec.subscibe(tableName)
