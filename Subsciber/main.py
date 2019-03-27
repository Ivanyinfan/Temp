#!/usr/bin/env python
import pika
import config
import mysql.connector


class DatabaseServer():
    def __init__(self, dbPara):
        self.cnx = mysql.connector.connect(**dbPara)
        self.cursor = self.cnx.cursor()

    def __parseData__(self, data):
        return data

    def receive(self, data):
        data = self.__parseData__(data)
        self.cursor.execute('SELECT * FROM device')
        rows = self.cursor.fetchall()
        print(rows)


class Subsciber():
    def __init__(self, pikaPara, routKeys):
        if type(routKeys) == str:
            tmp = list()
            tmp.append(routKeys)
            routKeys = tmp
        if type(routKeys) != list:
            exit
        pikaConPara = pika.ConnectionParameters(**pikaPara)
        exchangePara = {'exchange': 'test', 'exchange_type': 'topic'}
        self.connection = pika.BlockingConnection(pikaConPara)
        self.channel = self.connection.channel()
        self.exchange = self.channel.exchange_declare(**exchangePara)
        self.queue = self.channel.queue_declare(exclusive=True)
        self.queueName = self.queue.method.queue
        for rk in routKeys:
            self.channel.queue_bind(
                exchange='test', queue=self.queueName, routing_key=rk)

    def __callback__(self, ch, method, properties, body):
        print(" [x] %r:%r" % (method.routing_key, body))

    def receive(self):
        self.channel.basic_consume(
            self.__callback__, queue=self.queueName, no_ack=True)
        self.channel.start_consuming()


def main():
    subsciber = Subsciber(config.PIKACONFIG, 'test.*')
    # subsciber.receive()
    dbserver = DatabaseServer(config.DATABASECONFIG)
    dbserver.receive('')


if __name__ == "__main__":
    main()
