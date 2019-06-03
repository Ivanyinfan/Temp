import pika
import threading

SUBTOPUBQUE = 'SUBSCRIBE'
CORRELATION_ID = str(20190329)
EXCHANGE_NAME = 'TEST'


class Server():
    def __init__(self, host, port):
        self._host = host
        self._port = port
        self._connect()
        self._exchange = None
        self._properties = pika.BasicProperties(
            delivery_mode=2, correlation_id=CORRELATION_ID)

    def send(self, routing_key, data):
        # print('[Server][send]routing_key=%s' % (routing_key))
        pubPara = {
            'exchange': EXCHANGE_NAME,
            'routing_key': routing_key,
            'properties': self._properties,
            'body': data
        }
        self._channel.basic_publish(**pubPara)

    def startConsuming(self):
        print('[Server][startConsuming]...')
        self._channel.start_consuming()

    def stopConsuming(self):
        self._channel.stop_consuming()

    def judgeCorID(self, id):
        return id == CORRELATION_ID

    def sendAck(self, delivery_tag):
        self._channel.basic_ack(delivery_tag=delivery_tag)

    def _connect(self):
        pikaConPara = pika.ConnectionParameters(
            host=self._host, port=self._port)
        self._connection = pika.BlockingConnection(pikaConPara)
        self._channel = self._connection.channel()


class Sender(Server):
    def __init__(self, host, port):
        Server.__init__(self, host, port)
        exchangePara = {'exchange': EXCHANGE_NAME, 'exchange_type': 'topic'}
        self._exchange = self._channel.exchange_declare(**exchangePara)


class SenderSub(Sender):
    def __init__(self, host, port, callback):
        Sender.__init__(self, host, port)
        self.subscribe = self._channel.queue_declare(
            SUBTOPUBQUE, exclusive=True)
        self._channel.basic_consume(
            queue=self.subscribe.method.queue, no_ack=True, consumer_callback=callback)

    def listenSub(self):
        Sender.startConsuming(self)


class Receiver(Server):
    def __init__(self, name, host, port, callback=None):
        Server.__init__(self, host, port)
        self._checkSender()
        exchangePara = {'exchange': EXCHANGE_NAME, 'exchange_type': 'topic'}
        self._exchange = self._channel.exchange_declare(**exchangePara)
        queuePara = {
            'queue': name,
            'exclusive': True,
            'durable': True,
            'auto_delete': True,
        }
        self.queue = self._channel.queue_declare(**queuePara)
        self.queueName = self.queue.method.queue
        if callback == None:
            callback = self._call_back
        self._channel.basic_consume(
            callback, queue=self.queueName, no_ack=False)

    def _checkSender(self):
        try:
            self._channel.queue_declare(SUBTOPUBQUE, exclusive=True)
        except pika.exceptions.ChannelClosed:
            self._connect()
            return True
        else:
            print('[Receiver]WARNING: publisher not exists')
            self._channel.queue_delete(SUBTOPUBQUE)
            return False

    def subscibe(self, tableName):
        print('[Receiver][subscibe]tableName='+tableName)
        self._sendSub('addTable', tableName)

    def unSubscibe(self, tableName):
        print('[Receiver][unSubscibe]tableName='+tableName)
        self._sendSub('deleteTable', tableName)

    def _sendSub(self, operation, tableName=None):
        body = {
            'reply': self.queueName,
            'operation': operation,
            'tableName': tableName
        }
        pubPara = {
            'exchange': '',
            'routing_key': SUBTOPUBQUE,
            'properties': self._properties,
            'body': str(body)
        }
        self._channel.basic_publish(**pubPara)

    def receive(self):
        print('[Receiver][receive]...')
        routing_key = [self.queueName+'.*', 'ALL.*']
        for rk in routing_key:
            self._channel.queue_bind(exchange=EXCHANGE_NAME,
                                     queue=self.queueName, routing_key=rk)
        self._channel.start_consuming()

    def _call_back(self, channel, method, properties, body):
        pass
