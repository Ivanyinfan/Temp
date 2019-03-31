import config
import cx_Oracle


class DatabaseServer():
    def __init__(self, dbPara, shaPrefix='R_SD_', seqPrefix='S_'):
        self.shaPrefix = shaPrefix
        self.seqPrefix = seqPrefix
        self.con = cx_Oracle.connect(**dbPara)
        self.cursor = self.con.cursor()

    def addTable(self, tableName):
        print('[DatabaseServer][addTable]tableName='+tableName)
        sTableName = self.shaPrefix + tableName
        re = self.__tableExist__(sTableName)
        print('[DatabaseServer][addTable]tableExist='+str(re))
        if re == False:
            self.__addShadowTable__(tableName)
            self.__addSequence__(sTableName)

    def sub_addTable(self, tableName):
        sTableName = self.shaPrefix + tableName
        if not self.__tiggerOnTableExist__(sTableName):
            self.__lockTable__(tableName)
            self.__addTigger__(tableName)

    def __tableExist__(self, tableName):
        sql = 'select count(*) from user_tables where table_name=:tablename'
        self.cursor.execute(sql, tableName=str.upper(tableName))
        re = self.cursor.fetchone()
        return re[0] != 0

    def __addShadowTable__(self, tableName):
        sTableName = self.shaPrefix + tableName
        sql = 'create table ' + sTableName + \
            ' as select * from ' + tableName + ' where 1=2'
        self.cursor.execute(sql)
        sql = 'alter table ' + sTableName + ' add (REP_SYNC_ID number)'
        self.cursor.execute(sql)
        sql = 'alter table ' + sTableName + \
            ' add (REP_OPERATIONTYPE CHAR(1 BYTE))'
        self.cursor.execute(sql)

    def __addSequence__(self, tableName):
        seqName = self.seqPrefix + tableName
        sql = 'CREATE SEQUENCE ' + seqName + \
            ' MINVALUE 0 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 0 \
            CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL'
        self.cursor.execute(sql)

    def __tiggerOnTableExist__(self, tableName):
        sql = 'select count(*) from user_triggers where table_name=:tableName'
        self.cursor.execute(sql, tableName=tableName)
        re = self.cursor.fetchone
        return re[0] != 0

    def __lockTable__(self, tableName):
        sql='lock table ' + tableName + ' in exclusive mode'
        self.cursor.execute(sql)

    def __addTigger__(self, tableName):
        sTableName = self.shaPrefix + tableName
        sql="select COLUMN_NAME from USER_TAB_COLUMNS where TABLE_NAME='R_SD_TEST'"
