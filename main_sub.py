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


def main():
    subsciber = Subsciber(config.PIKACONFIG, 'test.*')
    # subsciber.receive()
    dbserver = DatabaseServer(config.mysql)
    dbserver.receive('')


if __name__ == "__main__":
    main()
