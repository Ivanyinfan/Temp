import math
import time
import config
import decimal
import cx_Oracle
import mysql.connector


def DatabaseServer(name):
    name = str.upper(name)
    if name == 'ORACLE':
        return Oracle(config.oracle)
    if name == 'MYSQL':
        return MySQL(config.mysql)


class Server():
    def __init__(self):
        self._con = None
        self._cursor = None
        self._pageSize = 10000
        self._tableName = None
        self._column = None
        self._columnName = None
        self._values = None
        self._col_val = None
        self._colAndVal = None
        self._first = True
        self._next = True
        # pub
        self.shaPrefix = None
        self.seqPrefix = None
        self._column = None
        self._count = 0
        self._pages = 0
        self._pageNum = 0

    def getAllDataByPage(self, tableName):
        data = list()
        print('[Server][getAllDataByPage]first=%s' % (self._first))
        if self._first == True:
            self._first = False
            self._count = self._getCount(tableName)
            print('[Server][getAllDataByPage]count=%d' % (self._count))
            self._pages = math.ceil(self._count/self._pageSize)
            self._pageNum = 0
            data = self._getDataByPage(tableName, self._column, self._pageNum)
        else:
            self._pageNum += 1
            print('[Server][getAllDataByPage]pageNum=%d' % (self._pageNum))
            data = self._getDataByPage(tableName, self._column, self._pageNum)
        if (self._pageNum+1)*self._pageSize >= self._count:
            self._next = False
            self._first = True
        else:
            self._next = True
        return data, self._next

    def sub_addTable(self, tableName, first):
        print('[Server][sub_addTable]tableName='+tableName)
        sTableName = self.shaPrefix + tableName
        seqName = self.seqPrefix + sTableName
        if not self._tableExist(sTableName):
            return None, -1, -1, None
        minId = maxId = -1
        column = None
        if first == True:
            column = self._column = self._getColumnName(tableName)
            self._count = self._getCount(tableName)
            self._pages = math.ceil(self._count/self._pageSize)
            self._pageNum = 0
            minId = self._getNextRepSyncID(seqName)
            data = self._getDataByPage(tableName, self._column, self._pageNum)
        else:
            self._pageNum += 1
            data = self._getDataByPage(tableName, self._column, self._pageNum)
        if (self._pageNum+1)*self._pageSize >= self._count:
            maxId = self._getNextRepSyncID(seqName)
        print('[Server][sub_addTable]COMPLETE')
        return data, minId, maxId, column

    def _insertOperation(self, tableName, value):
        # insert into test (id,name) values (0,'a')
        sql = "insert into " + tableName
        sql = sql + self._column + " values " + self._values
        self._cursor.execute(sql, value)

    def _deleteOperation(self, tableName, value):
        # delete from test where id=%s and name=%s
        sql = "delete from " + tableName + " "
        sql = sql + "where " + self._colAndVal
        self._cursor.execute(sql, value)

    def _updateOperation(self, tableName, oldValue, newValue):
        # update test set id=%s, name=%s where id=%s and name=%s
        sql = 'update ' + tableName + ' '
        sql = sql + 'set ' + self._col_val + ' '
        sql = sql + 'where ' + self._colAndVal
        value = newValue + oldValue
        self._cursor.execute(sql, value)

    def _tableExist(self, tableName):
        return bool

    def _getColumnName(self, tableName):
        return tuple

    def _getCount(self, tableName):
        sql = 'select count(*) from ' + tableName
        self._cursor.execute(sql)
        return self._cursor.fetchone()[0]

    def _getDataByPage(self, tableName, column, pageNum):
        return list

    def _getNextRepSyncID(self, seqName):
        return int


class Oracle(Server):
    def __init__(self, dbPara, shaPrefix='R_SD_', seqPrefix='S_'):
        # OracleDatabaseServer.con = cx_Oracle.connect(**dbPara)
        # self._cursor = OracleDatabaseServer.con.cursor()
        super().__init__()
        self._con = cx_Oracle.connect(**dbPara)
        self._con.autocommit = True
        self._cursor = self._con.cursor()
        self.shaPrefix = shaPrefix
        self.seqPrefix = seqPrefix
        self._column = None
        self._count = 0
        self._pages = 0
        self._pageNum = 0

    def pub_addTable(self, tableName):
        print('[DatabaseServer][addTable]tableName='+tableName)
        sTableName = self.shaPrefix + tableName
        re = self._tableExist(sTableName)
        print('[DatabaseServer][addTable]tableExist='+str(re))
        if re == False:
            self.__addShadowTable(tableName)
            self.__addSequence(sTableName)
            self.__addTigger(tableName)

    def sub_addTable(self, tableName, first):
        print('[Oracle][sub_addTable]tableName='+tableName)
        print('[Oracle][sub_addTable]first='+str(first))
        sTableName = self.shaPrefix + tableName
        seqName = self.seqPrefix + sTableName
        if not self._tableExist(sTableName):
            return None, -1, -1, None
        minId = maxId = -1
        column = None
        if first == True:
            column = self._column = self._getColumnName(tableName)
            self._count = self._getCount(tableName)
            self._pages = math.ceil(self._count/self._pageSize)
            self._pageNum = 0
            minId = self._getSequenceNextValue(seqName)
            data = self._getDataByPage(tableName, self._column, self._pageNum)
        else:
            self._pageNum += 1
            data = self._getDataByPage(tableName, self._column, self._pageNum)
        if (self._pageNum+1)*self._pageSize >= self._count:
            maxId = self._getSequenceNextValue(seqName)
        print('[Oracle][sub_addTable]COMPLETE')
        return data, minId, maxId, column

    def pub_getUpdate(self, tableName):
        print('[_OracleDatabaseServer_pub_getUpdate]tableName='+tableName)
        sTableName = self.shaPrefix + tableName
        self._column = self._getColumnName(tableName)
        column = self._column + ('REP_SYNC_ID','REP_OPERATIONTYPE')
        update = self._getData(column, sTableName)
        update.sort(key=lambda u: u[-2])
        print('[_OracleDatabaseServer_pub_getUpdate]update='+str(update))
        if len(update) != 0:
            self.__deleteShadowTable(tableName, update[-1][-2])
        return update

    def pub_deleteTable(self, tableName):
        print('[Oracle][pub_deleteTable]tableName='+tableName)
        sTableName = self.shaPrefix + tableName
        seqName = self.seqPrefix + sTableName
        self.__dropTrigger('I_'+tableName)
        self.__dropTrigger('D_'+tableName)
        self.__dropTrigger('U_'+tableName)
        self.__dropSequence(seqName)
        self.__dropTable(sTableName)

    def getAllDataByPage(self, tableName):
        if self._first == True:
            self._column = self._getColumnName(tableName)
        return super().getAllDataByPage(tableName)

    def _tableExist(self, tableName):
        sql = 'select count(*) from user_tables where table_name=:tablename'
        self._cursor.execute(sql, tableName=str.upper(tableName))
        re = self._cursor.fetchone()
        return re[0] != 0

    def __addShadowTable(self, tableName):
        sTableName = self.shaPrefix + tableName
        sql = 'create table ' + sTableName + \
            ' as select * from ' + tableName + ' where 1=2'
        self._cursor.execute(sql)
        sql = 'alter table ' + sTableName + ' add (REP_SYNC_ID number)'
        self._cursor.execute(sql)
        sql = 'alter table ' + sTableName + \
            ' add (REP_OPERATIONTYPE CHAR(1 BYTE))'
        self._cursor.execute(sql)

    def __deleteShadowTable(self, tableName, id):
        print('[_OracleDatabaseServer__deleteShadowTable]tableName=%s,id=%d' % (
            tableName, id))
        sTableName = self.shaPrefix + tableName
        sql = 'delete from ' + sTableName + ' '
        sql = sql + 'where REP_SYNC_ID <= :id'
        self._cursor.execute(sql, id=id)
        self._con.commit()
        print('[Oracle][deleteShadowTable]COMPLETE')

    def __addSequence(self, tableName):
        seqName = self.seqPrefix + tableName
        sql = 'CREATE SEQUENCE ' + seqName + \
            ' MINVALUE 0 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 0 \
            CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL'
        self._cursor.execute(sql)

    def _getSequenceNextValue(self, seqName):
        sql = 'select ' + seqName + '.nextval from dual'
        self._cursor.execute(sql)
        return self._cursor.fetchone()[0]

    def __tiggerOnTableExist(self, tableName):
        sql = 'select count(*) from user_triggers where table_name=:tableName'
        self._cursor.execute(sql, tableName=tableName)
        re = self._cursor.fetchone()
        return re[0] != 0

    def __lockTable(self, tableName):
        print('[Oracle][__lockTable]tableName='+tableName)
        sql = 'lock table ' + tableName + ' in exclusive mode'
        self._cursor.execute(sql)
        self._con.commit()
        print('[Oracle][__lockTable]COMPLETE')

    def __unlockTable(self, tableName):
        self.__commit()

    def __addTigger(self, tableName):
        sTableName = self.shaPrefix + tableName
        seqName = self.seqPrefix + sTableName
        sql = "select COLUMN_NAME from USER_TAB_COLUMNS where TABLE_NAME='" + \
            str.upper(sTableName) + "'"
        self._cursor.execute(sql)
        column = tuple()
        next = self._cursor.fetchone()
        while next != None:
            column = column+next
            next = self._cursor.fetchone()
        newRowCol = list()
        for c in column:
            newRowCol.append(":newRow."+c)
        oldRowCol = list()
        for c in column:
            oldRowCol.append(":oldRow."+c)
        newRowCol = tuple(newRowCol)[:-2]
        oldRowCol = tuple(oldRowCol)[:-2]
        columnStr = str(column).replace("'", "")
        newRowColStr = str(newRowCol).replace("'", "")[:-1]
        oldRowColStr = str(oldRowCol).replace("'", "")[:-1]
        sql = 'CREATE OR REPLACE TRIGGER I_'+tableName+" "
        sql = sql+'AFTER INSERT ON '+tableName+" "
        sql = sql+'REFERENCING NEW AS NEWROW OLD AS OLD FOR EACH ROW '
        sql = sql+'begin insert into '+sTableName
        sql = sql+columnStr+'values'
        sql = sql+newRowColStr+","
        sql = sql+seqName+".nextVal,'I');end;"
        self._cursor.execute(sql)
        sql = 'CREATE OR REPLACE TRIGGER D_'+tableName+" "
        sql = sql+'AFTER DELETE ON '+tableName+" "
        sql = sql+'REFERENCING NEW AS NEW OLD AS OLDROW FOR EACH ROW '
        sql = sql+'begin insert into '+sTableName
        sql = sql+columnStr+'values'
        sql = sql+oldRowColStr+","
        sql = sql+seqName+".nextVal,'D');end;"
        self._cursor.execute(sql)
        sql = 'CREATE OR REPLACE TRIGGER U_'+tableName+" "
        sql = sql+'AFTER UPDATE ON '+tableName+" "
        sql = sql+'REFERENCING NEW AS NEWROW OLD AS OLDROW FOR EACH ROW '
        sql = sql+'begin insert into '+sTableName
        sql = sql+columnStr+'values'
        sql = sql+oldRowColStr+","
        sql = sql+seqName+".nextVal,'U');"
        sql = sql+'insert into '+sTableName
        sql = sql+columnStr+'values'
        sql = sql+newRowColStr+","
        sql = sql+seqName+".nextVal,'U');end;"
        self._cursor.execute(sql)

    def __getMaxId(self, sTableName):
        print('[Oracle][__getMaxId]sTableName='+sTableName)
        sql = 'select max(REP_SYNC_ID) from '+sTableName
        self._cursor.execute(sql)
        return self._cursor.fetchone()[0]

    def _getData(self, column, tableName):
        column = str(column)[1:-1].replace("'", "")
        sql = "select " + column + ' from ' + tableName
        self._cursor.execute(sql)
        return self._cursor.fetchall()

    def _getDataByPage(self, tableName, column, pageNum):
        min = pageNum * self._pageSize
        max = min + self._pageSize
        column = str(column)[1:-1].replace("'", '')
        ssquery = 'select * from ' + tableName
        subquery = 'select a.*, rownum rn '
        subquery += 'from (' + ssquery + ') a '
        subquery += 'where rownum <=:max'
        sql = 'select ' + column + ' from (' + subquery + ')'
        sql += 'where rn>:min'
        args = {'min': min, 'max': max}
        self._cursor.execute(sql, args)
        return self._cursor.fetchall()

    def __commit(self):
        sql = 'commit'
        self._cursor.execute(sql)
        self._con.commit()

    def __dropTrigger(self, triggerName):
        sql = 'drop trigger '+triggerName
        self._cursor.execute(sql)

    def __dropSequence(self, sequenceName):
        sql = 'drop sequence '+sequenceName
        self._cursor.execute(sql)

    def __dropTable(self, tableName):
        sql = 'drop table '+tableName
        self._cursor.execute(sql)

    def _getColumnName(self, tableName):
        sql = "select COLUMN_NAME from user_tab_columns where table_name='"
        sql = sql + str.upper(tableName) + "'"
        self._cursor.execute(sql)
        column = tuple()
        next = self._cursor.fetchone()
        while next != None:
            column = column + next
            next = self._cursor.fetchone()
        return column

    def _getCount(self, tableName):
        sql = 'select count(*) from ' + tableName
        self._cursor.execute(sql)
        return self._cursor.fetchone()[0]

    def __del__(self):
        self._cursor.close()
        self._con.close()


class MySQL(Server):
    def __init__(self, dbPara):
        super().__init__()
        self._con = mysql.connector.connect(**dbPara)
        self._cursor = self._con.cursor()
        self._tableMap = dict()
        self.uncompleted = None

    def getTableMap(self, tableName):
        if tableName in self._tableMap:
            return
        print('[_MySQLDatabaseServer__getTableMap]tableName=%s' % (tableName))
        sql = 'select column_name from information_schema.columns where table_name=%s'
        self._cursor.execute(sql, (tableName,))
        column = tuple()
        next = self._cursor.fetchone()
        while next != None:
            column = column+next
            next = self._cursor.fetchone()
        self._getTabMapFromCol(tableName, column)

    def _getTabMapFromCol(self, tableName, column):
        length = len(column)
        values = ('%s',)*length
        col_val = list()
        for c in column:
            col_val.append(c+'=%s')
        self._column = column
        self._colAndVal = ' and '.join(col_val)
        self._columnName = str(column).replace("'", "")
        self._values = str(values).replace("'", "")
        self._col_val = str(col_val)[1:-1].replace("'", "")
        result = dict()
        result['column'] = self._column
        result['columnName'] = self._columnName
        result['values'] = self._values
        result['col_val'] = self._col_val
        result['colAndVal'] = self._colAndVal
        self._tableMap[tableName] = result

    def deleteTable(self, tableName):
        sql = 'delete from '+tableName
        self._cursor.execute(sql)

    def getAllData(self, tableName, column, data):
        print('[_MySQLDatabaseServer_getAllData]tableName=%s' % (tableName))
        self._getTabMapFromCol(tableName, column)
        columName = self._tableMap[tableName]['columnName']
        values = self._tableMap[tableName]['values']
        sql = "insert into " + tableName
        sql = sql + columName + " values " + values
        self._cursor.executemany(sql, data)

    def updateData(self, tableName, data):
        if type(data) != list:
            print('[_MySQLDatabaseServer_updateData]ERROR: expect data to be list')
            return -1
        if self.uncompleted:
            data.insert(0, self.uncompleted)
            self.uncompleted = None
        length = len(data)
        i = 0
        while i < length:
            svalue = data[i]
            operation = svalue[-1]
            value = svalue[:-2]
            if operation == 'I':
                self.__insertOperation(tableName, value)
            elif operation == 'D':
                self.__deleteOperation(tableName, value)
            elif operation == 'U':
                if i == length-1:
                    self.uncompleted = data[i]
                else:
                    newSvalue = data[i+1]
                    newOp = newSvalue[-1]
                    if newOp != 'U':
                        print('[_MySQLDatabaseServer_updateData]ERROR')
                        return -2
                    newValue = newSvalue[:-2]
                    self.__updateOperation(tableName, value, newValue)
                    i = i + 1
            else:
                print(
                    '[_MySQLDatabaseServer_updateData]ERROR: undefined operation type')
                return -3
            i = i + 1
        return 0

    def updateBetData(self, tableName, data):
        if type(data) != list:
            print('[MySQL][updateBetData]ERROR: expect data to be list')
            return -1
        print('[MySQL][updateBetData]tableName=%s' % (tableName))
        if self.uncompleted:
            data.insert(0, self.uncompleted)
            self.uncompleted = None
        length = len(data)
        i = 0
        while i < length:
            svalue = data[i]
            operation = svalue[-1]
            value = svalue[:-2]
            if operation == 'I':
                if not self._dataInTable(tableName, value):
                    self.__insertOperation(tableName, value)
            elif operation == 'D':
                if self._dataInTable(tableName, value):
                    self.__deleteOperation(tableName, value)
            elif operation == 'U':
                if i == length-1:
                    self.uncompleted = data[i]
                else:
                    if self._dataInTable(tableName, value):
                        newSvalue = data[i+1]
                        newOp = newSvalue[-1]
                        if newOp != 'U':
                            print('[MySQL][updateBetData]ERROR')
                            return -2
                        newValue = newSvalue[:-2]
                        self.__updateOperation(tableName, value, newValue)
                    i = i + 1
            else:
                print(
                    '[MySQL][updateBetData]ERROR: undefined operation type')
                return -3
            i = i + 1
        return 0

    def _checkTableName(self, tableName):
        if self._tableName == tableName:
            return
        self._tableName = tableName
        self._column = self._tableMap[tableName]['column']
        self._columnName = self._tableMap[tableName]['columnName']
        self._values = self._tableMap[tableName]['values']
        self._col_val = self._tableMap[tableName]['col_val']
        self._colAndVal = self._tableMap[tableName]['colAndVal']

    def _dataInTable(self, tableName, data):
        self._checkTableName(tableName)
        sql = 'select count(*) from ' + tableName + ' '
        sql = sql + 'where ' + self._colAndVal
        sql, data = self._handleNull(sql, data)
        self._cursor.execute(sql, data)
        return self._cursor.fetchone()[0] != 0

    def __insertOperation(self, tableName, value):
        # insert into test (id,name) values (0,'a')
        sql = "insert into " + tableName
        sql = sql + self._columnName + " values " + self._values
        print(sql, value)
        self._cursor.execute(sql, value)

    def __deleteOperation(self, tableName, value):
        # delete from test where id=%s and name=%s
        sql = "delete from " + tableName + " "
        sql = sql + "where " + self._colAndVal
        self._cursor.execute(sql, value)

    def __updateOperation(self, tableName, oldValue, newValue):
        # update test set id=%s, name=%s where id=%s and name=%s
        sql = 'update ' + tableName + ' '
        sql = sql + 'set ' + self._col_val + ' '
        sql = sql + 'where ' + self._colAndVal
        value = newValue + oldValue
        self._cursor.execute(sql, value)

    def _getDataByPage(self, tableName, column, pageNum):
        sql = 'select * from ' + tableName + ' '
        sql += 'limit %s,%s'
        args = (self._pageNum*self._pageSize, self._pageSize)
        self._cursor.execute(sql, args)
        return self._cursor.fetchall()

    def _handleNull(self, sql, data, column=None):
        if column == None:
            column = self._column
        lend = len(data)
        reData = list()
        for i in range(lend):
            d = data[i]
            if d == None:
                colName = column[i]
                sql = sql.replace(colName + '=%s', colName + ' is null')
            else:
                reData.append(d)
        return sql, tuple(reData)

    def __del__(self):
        self._cursor.close()
        self._con.close()
