import config
import cx_Oracle
import mysql.connector


class OracleDatabaseServer():
    def __init__(self, dbPara, shaPrefix='R_SD_', seqPrefix='S_'):
        self.shaPrefix = shaPrefix
        self.seqPrefix = seqPrefix
        self.con = cx_Oracle.connect(**dbPara)
        self.cursor = self.con.cursor()

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
        sTableName = self.shaPrefix + tableName
        data = list()
        if not self.__tableExist(sTableName):
            return data, -1
        self.__lockTable(tableName)
        id = self.__getMaxId(sTableName)
        data = self.__getData(tableName)
        self.__unlockTable(tableName)
        return data, id

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

    def __addSequence(self, tableName):
        seqName = self.seqPrefix + tableName
        sql = 'CREATE SEQUENCE ' + seqName + \
            ' MINVALUE 0 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 0 \
            CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL'
        self.cursor.execute(sql)

    def __tiggerOnTableExist(self, tableName):
        sql = 'select count(*) from user_triggers where table_name=:tableName'
        self.cursor.execute(sql, tableName=tableName)
        re = self.cursor.fetchone
        return re[0] != 0

    def __lockTable(self, tableName):
        sql = 'lock table ' + tableName + ' in exclusive mode'
        self.cursor.execute(sql)

    def __unlockTable(self, tableName):
        sql = 'commit'
        self.cursor.execute(sql)

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
        print(sql)
        self.cursor.execute(sql)
        sql = 'CREATE OR REPLACE TRIGGER D_'+tableName+" "
        sql = sql+'AFTER DELETE ON '+tableName+" "
        sql = sql+'REFERENCING NEW AS NEW OLD AS OLDROW FOR EACH ROW '
        sql = sql+'begin insert into '+sTableName
        sql = sql+columnStr+'values'
        sql = sql+oldRowColStr+","
        sql = sql+seqName+".nextVal,'D');end;"
        print(sql)
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
        print(sql)
        self.cursor.execute(sql)

    def __getMaxId(self, sTableName):
        sql = 'select max(REP_SYNC_ID) from '+sTableName
        self.cursor.execute(sql)
        return self.cursor.fetchone()[0]

    def __getData(self, tableName):
        sql = "select * from "+tableName
        self.cursor.execute(sql)
        return self.cursor.fetchall()


class MySQLDatabaseServer():
    def __init__(self, dbPara):
        self.con = mysql.connector.connect(**dbPara)
        self.cursor = self.con.cursor()

    def getAllData(self, tableName, data):
        print('[_MySQLDatabaseServer_getAllData]tableName=%s' % (tableName))
        sql = 'select column_name from information_schema.columns where table_name=%s'
        self.cursor.execute(sql, (tableName,))
        column = tuple()
        next = self.cursor.fetchone()
        while next != None:
            column = column+next
            next = self.cursor.fetchone()
        length = len(column)
        values = ('%s',)*length
        column = str(column).replace("'", "")
        values = str(values).replace("'", "")
        sql = "insert into test "+column+" values "+values
        print('[_MySQLDatabaseServer_getAllData]sql=%s' % (sql))
        self.cursor.executemany(sql, data)

    def updateData(self, tableName, data):
        pass
