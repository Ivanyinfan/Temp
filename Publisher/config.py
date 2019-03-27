#!/usr/bin/env python
import cx_Oracle

# cx_Oracle.connect(user=None, password=None, dsn=None, mode=None, handle=None,
#                   pool=None, threaded=False, events=False, cclass=None, purity=None,
#                   newpassword=None, encoding=None, nencoding=None, edition=None,
#                   appcontext=[], tag=None, matchanytag=None, shardingkey=[], supershardingkey=[])
dsn = {
    'host': 'localhost',
    'port': 1521,
    'sid': 'orcl'
}
dsn = cx_Oracle.makedsn(**dsn)
database = {
    'user': 'C##DEP6',
    'password': '123456',
    'dsn': dsn
}
pika = {
    'host': 'localhost'
}
