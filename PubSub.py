import config
import threading
import MQServer
import DatabaseServer


class Publisher():
    def __init__(self, dbName='Oracle'):
        self.dbName = dbName
        self.db = DatabaseServer.DatabaseServer(dbName)
        self.sen = MQServer.Sender(config.pika, self.pub_callback)
        self.thread = threading.Thread(
            target=pubListenSub, args=(self.dbName,))
        self.thread.start()

    def pub_addTable(self, tableName):
        self.db.pub_addTable(tableName)

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
        self.sen.startConsuming()

    def __publishUpdate(self, tableName):
        pass


def pubListenSub(dbName):
    print('[pubListenSub]dbName=%s' % (dbName))
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
            target=sub_subTable, args=(self.dbName, tableName))
        thread.start()

    def __subTable(self, tableName):
        print('[_Subscriber__subTable]tableName='+tableName)
        self.rec.subscibe(tableName)

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

    def sub_callback(channel, method, properties, body):
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
                    id = id
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
