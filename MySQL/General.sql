mysql -u root -p test
create database test;
show databases;
show tables;
use test;
desc test;
show columns from test;
show columns from information_schema.columns;
select * from information_schema.columns where table_name='test';
select column_name, data_type from information_schema.columns where table_name='test';