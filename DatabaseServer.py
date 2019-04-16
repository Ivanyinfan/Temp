import config
import cx_Oracle
import mysql.connector


def DatabaseServer(name):
    name = str.upper(name)
    if name == 'ORACLE':
        return OracleDatabaseServer(config.oracle)
    if name == 'MYSQL':
        return MySQLDatabaseServer(config.mysql)


class OracleDatabaseServer():
    def __init__(self, dbPara, shaPrefix='R_SD_', seqPrefix='S_'):
        # OracleDatabaseServer.con = cx_Oracle.connect(**dbPara)
        # self.cursor = OracleDatabaseServer.con.cursor()
        self.con = cx_Oracle.connect(**dbPara)
        self.con.autocommit = True
        self.cursor = self.con.cursor()
        self.shaPrefix = shaPrefix
        self.seqPrefix = seqPrefix

    def pub_addTable(self, tableName):
        print('[DatabaseServer][addTable]tableName='+tableName)
        sTableName = self.shaPrefix + tableName
        re = self.__tableExist(sTableName)
        print('[DatabaseServer][addTable]tableExist='+str(re))
        if re == False:
            self.__addShadowTable(tableName)
            self.__addSequence(sTableName)
            self.__addTigger(tableName)

    def sub_addTable(self, tableName):
        print('[Oracle][sub_addTable]tableName='+tableName)
        sTableName = self.shaPrefix + tableName
        data = list()
        if not self.__tableExist(sTableName):
            return data, -1
        self.__lockTable(tableName)
        id = self.__getMaxId(sTableName)
        data = self.__getData(tableName)
        self.__unlockTable(tableName)
        print('[Oracle][sub_addTable]COMPLETE')
        return data, id

    def pub_getUpdate(self, tableName):
        print('[_OracleDatabaseServer_pub_getUpdate]tableName='+tableName)
        sTableName = self.shaPrefix + tableName
        sql = 'select * from ' + sTableName
        self.cursor.execute(sql)
        update = self.cursor.fetchall()
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
        self.__dropTrigger('D_'+tableName)
        self.__dropSequence(seqName)
        self.__dropTable(sTableName)

    def __tableExist(self, tableName):
        sql = 'select count(*) from user_tables where table_name=:tablename'
        self.cursor.execute(sql, tableName=str.upper(tableName))
        re = self.cursor.fetchone()
        return re[0] != 0

    def __addShadowTable(self, tableName):
        sTableName = self.shaPrefix + tableName
        sql = 'create table ' + sTableName + \
            ' as select * from ' + tableName + ' where 1=2'
        self.cursor.execute(sql)
        sql = 'alter table ' + sTableName + ' add (REP_SYNC_ID number)'
        self.cursor.execute(sql)
        sql = 'alter table ' + sTableName + \
            ' add (REP_OPERATIONTYPE CHAR(1 BYTE))'
        self.cursor.execute(sql)

    def __deleteShadowTable(self, tableName, id):
        print('[_OracleDatabaseServer__deleteShadowTable]tableName=%s,id=%d' % (
            tableName, id))
        sTableName = self.shaPrefix + tableName
        sql = 'delete from ' + sTableName + ' '
        sql = sql + 'where REP_SYNC_ID <= :id'
        self.cursor.execute(sql, id=id)
        self.con.commit()
        # print('[Oracle][deleteShadowTable]COMPLETE')

    def __addSequence(self, tableName):
        seqName = self.seqPrefix + tableName
        sql = 'CREATE SEQUENCE ' + seqName + \
            ' MINVALUE 0 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 0 \
            CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL'
        self.cursor.execute(sql)

    def __tiggerOnTableExist(self, tableName):
        sql = 'select count(*) from user_triggers where table_name=:tableName'
        self.cursor.execute(sql, tableName=tableName)
        re = self.cursor.fetchone()
        return re[0] != 0

    def __lockTable(self, tableName):
        print('[Oracle][__lockTable]tableName='+tableName)
        sql = 'lock table ' + tableName + ' in exclusive mode'
        self.cursor.execute(sql)
        self.con.commit()
        print('[Oracle][__lockTable]COMPLETE')

    def __unlockTable(self, tableName):
        self.__commit()

    def __addTigger(self, tableName):
        sTableName = self.shaPrefix + tableName
        seqName = self.seqPrefix + sTableName
        sql = "select COLUMN_NAME from USER_TAB_COLUMNS where TABLE_NAME='" + \
            str.upper(sTableName) + "'"
        self.cursor.execute(sql)
        column = tuple()
        next = self.cursor.fetchone()
        while next != None:
            column = column+next
            next = self.cursor.fetchone()
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
        self.cursor.execute(sql)
        sql = 'CREATE OR REPLACE TRIGGER D_'+tableName+" "
        sql = sql+'AFTER DELETE ON '+tableName+" "
        sql = sql+'REFERENCING NEW AS NEW OLD AS OLDROW FOR EACH ROW '
        sql = sql+'begin insert into '+sTableName
        sql = sql+columnStr+'values'
        sql = sql+oldRowColStr+","
        sql = sql+seqName+".nextVal,'D');end;"
        self.cursor.execute(sql)
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
        self.cursor.execute(sql)

    def __getMaxId(self, sTableName):
        print('[Oracle][__getMaxId]sTableName='+sTableName)
        sql = 'select max(REP_SYNC_ID) from '+sTableName
        self.cursor.execute(sql)
        return self.cursor.fetchone()[0]

    def __getData(self, tableName):
        sql = "select * from "+tableName
        self.cursor.execute(sql)
        return self.cursor.fetchall()

    def __commit(self):
        sql = 'commit'
        self.cursor.execute(sql)
        self.con.commit()

    def __dropTrigger(self, triggerName):
        sql = 'drop trigger '+triggerName
        self.cursor.execute(sql)

    def __dropSequence(self, sequenceName):
        sql = 'drop sequence '+sequenceName
        self.cursor.execute(sql)

    def __dropTable(self, tableName):
        sql = 'drop table '+tableName
        self.cursor.execute(sql)

    def __del__(self):
        self.cursor.close()
        self.con.close()


class MySQLDatabaseServer():
    def __init__(self, dbPara):
        self.con = mysql.connector.connect(**dbPara)
        self.cursor = self.con.cursor()
        self.tableMap = dict()
        self.uncompleted = None

    def getTableMap(self, tableName, force=False):
        if force == True:
            self.__getTableMap(tableName)
        else:
            if not tableName in self.tableMap:
                self.__getTableMap(tableName)

    def __getTableMap(self, tableName):
        print('[_MySQLDatabaseServer__getTableMap]tableName=%s' % (tableName))
        sql = 'select column_name from information_schema.columns where table_name=%s'
        self.cursor.execute(sql, (tableName,))
        column = tuple()
        next = self.cursor.fetchone()
        while next != None:
            column = column+next
            next = self.cursor.fetchone()
        length = len(column)
        values = ('%s',)*length
        col_val = list()
        for c in column:
            col_val.append(c+'=%s')
        colAndVal = ' and '.join(col_val)
        column = str(column).replace("'", "")
        values = str(values).replace("'", "")
        col_val = str(col_val)[1:-1].replace("'", "")
        result = dict()
        result['column'] = column
        result['values'] = values
        result['col_val'] = col_val
        result['colAndVal'] = colAndVal
        self.tableMap[tableName] = result

    def deleteTable(self, tableName):
        sql = 'delete from '+tableName
        self.cursor.execute(sql)

    def getAllData(self, tableName, data):
        print('[_MySQLDatabaseServer_getAllData]tableName=%s' % (tableName))
        column = self.tableMap[tableName]['column']
        values = self.tableMap[tableName]['values']
        sql = "insert into "+tableName
        sql = sql+column+" values "+values
        self.cursor.executemany(sql, data)

    def updateData(self, tableName, data):
        if type(data) != list:
            print('[_MySQLDatabaseServer_updateData]ERROR: expect data to be list')
            return -1
        if self.uncompleted:
            data.insert(0, self.uncompleted)
            self.uncompleted = None
        length = len(data)
        column = self.tableMap[tableName]['column']
        values = self.tableMap[tableName]['values']
        col_val = self.tableMap[tableName]['col_val']
        colAndVal = self.tableMap[tableName]['colAndVal']
        for i in range(length):
            svalue = data[i]
            operation = svalue[-1]
            value = svalue[:-2]
            if operation == 'I':
                # insert into test (id,name) values (0,'a')
                sql = "insert into "+tableName
                sql = sql+column+" values "+values
                self.cursor.execute(sql, value)
            elif operation == 'D':
                # delete from test where id=%s and name=%s
                sql = "delete from "+tableName+" "
                sql = sql+"where "+colAndVal
                self.cursor.execute(sql, value)
            elif operation == 'U':
                if i == length-1:
                    self.uncompleted = data[i]
                else:
                    newSvalue = data[i+1]
                    newOp = newSvalue[-1]
                    if newOp != 'U':
                        print('[_MySQLDatabaseServer_updateData]ERROR')
                        return -2
                    # update test set id=%s, name=%s where id=%s and name=%s
                    newValue = newSvalue[:-2]
                    sql = 'update '+tableName+' '
                    sql = sql+'set '+col_val+' '
                    sql = sql+'where '+colAndVal
                    value = newValue + value
                    self.cursor.execute(sql, value)
            else:
                print(
                    '[_MySQLDatabaseServer_updateData]ERROR: undefined operation type')
                return -3
        return 0

    def __del__(self):
        self.cursor.close()
        self.con.close()
