import pika
import threading

SUBTOPUBQUE = 'SUBSCRIBE'
CORRELATION_ID = str(20190329)


class Sender():
    def __init__(self, pikaPara):
        pikaConPara = pika.ConnectionParameters(**pikaPara)
        exchangePara = {'exchange': 'test', 'exchange_type': 'topic'}
        self.connection = pika.BlockingConnection(pikaConPara)
        self.channel = self.connection.channel()
        self.exchange = self.channel.exchange_declare(**exchangePara)
        self.properties = pika.BasicProperties(delivery_mode=2)

    def send(self, routing_key, data):
        print('[_Sender_send]routing_key=%s' % (routing_key))
        pubPara = {
            'exchange': 'test',
            'routing_key': routing_key,
            'properties': self.properties,
            'body': data
        }
        self.channel.basic_publish(**pubPara)

    def startConsuming(self):
        print('[_Sender_startConsuming]...')
        self.channel.start_consuming()

    def judgeCorID(self, id):
        return id == CORRELATION_ID


class SenderSub(Sender):
    def __init__(self, pikaPara, callback):
        Sender.__init__(self, pikaPara)
        self.subscribe = self.channel.queue_declare(SUBTOPUBQUE)
        self.channel.basic_consume(
            queue=self.subscribe.method.queue, no_ack=True, consumer_callback=callback)

    def listenSub(self):
        print('[_Sender_listenSub]...')
        self.channel.start_consuming()


class Receiver():
    def __init__(self, pikaPara, callback):
        pikaConPara = pika.ConnectionParameters(**pikaPara)
        self.connection = pika.BlockingConnection(pikaConPara)
        self.channel = self.connection.channel()
        self.exchangeName = 'test'
        exchangePara = {'exchange': self.exchangeName,
                        'exchange_type': 'topic'}
        self.exchange = self.channel.exchange_declare(**exchangePara)
        self.queue = self.channel.queue_declare(exclusive=True)
        self.queueName = self.queue.method.queue
        self.channel.basic_consume(callback, queue=self.queueName, no_ack=True)
        self.properties = pika.BasicProperties(
            delivery_mode=2, correlation_id=CORRELATION_ID)

    def subscibe(self, tableName):
        print('[_Receiver_subscibe]tableName='+tableName)
        self.__sendSub(tableName)
        self.__receive(tableName)

    def stopConsuming(self):
        self.channel.stop_consuming()

    def __sendSub(self, tableName):
        pubPara = {
            'exchange': '',
            'routing_key': SUBTOPUBQUE,
            'properties': self.properties,
            'body': tableName
        }
        self.channel.basic_publish(**pubPara)

    def __receive(self, tableName):
        print('[_Receiver__receive]tableName='+tableName)
        self.channel.queue_bind(exchange=self.exchangeName,
                                queue=self.queueName, routing_key=tableName)
        self.channel.start_consuming()

    def __callback(self, channel, method, properties, body):
        print(" [x] %r:%r" % (method.routing_key, body))
