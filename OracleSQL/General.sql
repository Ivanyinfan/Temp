sqlplus sys/123456 as sysdba
sqlplus C##DEP6/123456@orcl
CONN sys/123456 as sysdba;
CONN C##DEP6/123456@orcl;
SELECT USERNAME FROM DBA_USERS;

--修改系统参数
SHOW PARAMETER sga;
ALTER system SET sga_target=500m SCOPE=spfile;
ALTER system SET sga_max_size=512m SCOPE=spfile;

startup pfile=E:\Oracle\Home\database\SPFILEORCL.ORA
CREATE PFILE='E:\Oracle\Home\database\SPFILEORCL01.ORA' FROM SPFILE;

--执行SQL文件
@D:\下载\DatabaseSynchronization\Publisher\SQL\Tablespace.sql
@D:\下载\DatabaseSynchronization\Publisher\SQL\User.sql
exp user1/pwd@server1 file=c:\file.dmp tables=(table1, table2)
--执行dmp文件
impdp C##DEP6/123456@orcl dumpfile=dep6_meta.dmp directory=Dmp remap_schema=DEP6:C##DEP6
impdp C##DEP6/123456@orcl dumpfile=item.dmp directory=Dmp remap_schema=DEP6:C##DEP6
--查看当前容器
show con_name;
--查看CDB中PDB信息
select con_id, dbid, guid, name , open_mode from v$pdbs;
select name, open_mode from v$pdbs;
--切换到PDB
alter session set container=ORCLL;
alter session set container=CDB$ROOT;
alter pluggable database open;
startup;
shutdown;
drop tablespace name including contents and datafiles cascade constraint;
show parameter processes;
select count(*) from v$process;
select value from v$parameter where name = 'processes';
--取得数据库目前的会话数
select count(*) from v$session;
--取得会话数的上限
select value from v$parameter where name = 'sessions';
--查看dispatchers使用率
select name,(busy/(busy+idle))*100 "busy rate%" from v$dispatcher;
select * from v$logfile;
select name,pdb from v$services;
select count(*) from dba_data_files;
select name,value from v$parameter where name = 'db_files';
alter system set db_files = 400 scope = spfile;
show parameter spfile;
create spfile from pfile;
select table_name from user_tables;
select count(*) from user_tables where table_name='R_SD_I_ITM_STOREITEM';
select count(*) from user_tables where table_name='TEST';
select count(*) from user_tables where table_name='R_SD_TEST';
select count(*) from all_tables where table_name='R_SD_TEST';
select count(*) from dba_tables where table_name='R_SD_TEST';
select owner from dba_tables where table_name='R_SD_TEST';
select count(*) from user_views where view_name='R_SD_TEST';
col TRIGGER_NAME for a12
col TRIGGERING_EVENT for a16
col TABLE_OWNER for a11
col TABLE_NAME for a10
col DESCRIPTION for a11
select * from user_triggers where trigger_name='I_TEST';
select TRIGGER_NAME, TABLE_NAME, STATUS from user_triggers where trigger_name='I_TEST';
select count(*) from user_sequences where sequence_name='S_R_SD_TEST';
select * from all_triggers where table_name='I_ITM_STOREITEM';
select userenv('language') from dual;
select dbms_metadata.get_ddl('TABLE','R_SD_TEST') from dual;
select dbms_metadata.get_ddl('TABLE','USER_TAB_COLUMNS') from dual;
select dbms_metadata.get_ddl('TRIGGER','HBL_BALANCE_CHARGE_T') from dual;
--修改字符集
alter system enable restricted session;
alter DATABASE CHARACTER set ZHS16GBK;
alter DATABASE CHARACTER set INTERNAL_USE ZHS16GBK;
create table C##DEP6.R_SD_test as select * from test where 1=2;
alter table R_SD_test add (REP_SYNC_ID number);
alter table R_SD_test add (REP_OPERATIONTYPE CHAR(1 BYTE));
alter trigger HBL_BALANCE_CHARGE_T disable;
--锁定表
lock table R_SD_test in exclusive mode;
--杀死进程解锁表
col ORACLE_USERNAME for a15
col OS_USER_NAME for a12
select * from v$locked_object;
select ORACLE_USERNAME, LOCKED_MODE from v$locked_object;
col OWNER for a5
col OBJECT_NAME for a11
select b.owner,b.object_name,a.session_id,a.locked_mode
from v$locked_object a,dba_objects b
where b.object_id = a.object_id;
select a.object_name,b.session_id,c.serial#,c.program,c.username,c.command,c.machine,c.lockwait
from all_objects a,v$locked_object b,v$session c
where a.object_id=b.object_id and c.sid=b.session_id and a.object_name='R_SD_TEST';
alter system kill session '21,51638';
select * from USER_TAB_COLUMNS where rownum<=10;
select COLUMN_NAME from USER_TAB_COLUMNS where TABLE_NAME='R_SD_TEST';
select max(REP_SYNC_ID) from R_SD_TEST;

show long
set long 300
show line
set line 100
col ORACLE_USERNAME for a10
show error

spool test.txt;
spool off;
lsnrctl status

--重要文件位置
E:\Oracle\Home\database\oradim.log
E:\ORACLE\HOME\DATABASE\SPFILEORCL.ORA
E:\Oracle\Base\diag\tnslsnr\BF-201708291113\listener\trace\listener.log
E:\Oracle\Base\diag\tnslsnr\BF-201708291113\listener\alert\log.xml