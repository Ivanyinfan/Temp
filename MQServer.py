import pika
import threading

SUBTOPUBQUE = 'SUBSCRIBE'
CORRELATION_ID = str(20190329)


class Sender():
    def __init__(self, pikaPara, callback):
        pikaConPara = pika.ConnectionParameters(**pikaPara)
        exchangePara = {'exchange': 'test', 'exchange_type': 'topic'}
        self.connection = pika.BlockingConnection(pikaConPara)
        self.channel = self.connection.channel()
        self.exchange = self.channel.exchange_declare(**exchangePara)
        self.subscribe = self.channel.queue_declare(SUBTOPUBQUE)
        self.channel.basic_consume(
            queue=self.subscribe.method.queue, consumer_callback=callback)
        self.thread = threading.Thread(target=self.__listenSub)
        # self.thread.start()

    def send(self, routing_key, data):
        print('[_Sender_send]routing_key=%s' % (routing_key))
        pubPara = {
            'exchange': 'test',
            'routing_key': routing_key,
            'body': data
        }
        self.channel.basic_publish(**pubPara)

    def startConsuming(self):
        self.channel.start_consuming()

    def judgeCorID(self, id):
        return id == CORRELATION_ID

    def __listenSub(self):
        print('[_Sender__listenSub]start_consuming')
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

    def subscibe(self, tableName):
        print('[_Receiver_subscibe]tableName='+tableName)
        self.__sendSub(tableName)
        self.__receive(tableName)

    def stopConsuming(self):
        self.channel.stop_consuming()

    def __sendSub(self, tableName):
        properties = pika.BasicProperties(correlation_id=CORRELATION_ID)
        pubPara = {
            'exchange': '',
            'routing_key': SUBTOPUBQUE,
            'properties': properties,
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
