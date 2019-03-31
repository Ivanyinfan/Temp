import pika

SUBTOPUBQUE = 'SUBSCRIBE'
CORRELATION_ID = 20190329


class Sender():
    def __init__(self, pikaPara, callback):
        pikaConPara = pika.ConnectionParameters(**pikaPara)
        exchangePara = {'exchange': 'test', 'exchange_type': 'topic'}
        self.connection = pika.BlockingConnection(pikaConPara)
        self.channel = self.connection.channel()
        self.exchange = self.channel.exchange_declare(**exchangePara)
        self.subscribe = self.channel.queue_declare(
            SUBTOPUBQUE, exclusive=True)
        self.channel.basic_consume(
            queue=self.subscribe.method.queue, consumer_callback=callback)

    def send(self, data):
        pubPara = {
            'exchange': 'test',
            'routing_key': 'test.test',
            'body': data
        }
        self.channel.basic_publish(**pubPara)

    def judgeCorID(self, id):
        return id == CORRELATION_ID


class Receiver():
    def __init__(self, pikaPara):
        pikaConPara = pika.ConnectionParameters(**pikaPara)
        exchangePara = {'exchange': 'test', 'exchange_type': 'topic'}
        self.connection = pika.BlockingConnection(pikaConPara)
        self.channel = self.connection.channel()
        self.exchange = self.channel.exchange_declare(**exchangePara)
        self.queue = self.channel.queue_declare(exclusive=True)
        self.queueName = self.queue.method.queue

    def subscibe(self, tableName):
        self.__sendSub__(tableName)
        self.__receive__()

    def __sendSub__(self, tableName):
        properties = pika.BasicProperties(correlation_id=CORRELATION_ID)
        pubPara = {
            'exchange': '',
            'routing_key': SUBTOPUBQUE,
            'properties': properties,
            'body': tableName
        }
        self.channel.basic_publish(**pubPara)

    def __receive__(self):
        self.channel.basic_consume(
            self.__callback__, queue=self.queueName, no_ack=True)
        self.channel.start_consuming()

    def __callback__(self, channel, method, properties, body):
        print(" [x] %r:%r" % (method.routing_key, body))
