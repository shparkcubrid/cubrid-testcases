-- create class using primary key on nchar data type

create class aoo ( a nchar(10) primary key, b int, c int );

select attr_name, is_nullable from db_attribute where class_name = 'aoo' order by 1,2;

select * from db_index where class_name = 'aoo';

select * from aoo;

drop aoo;