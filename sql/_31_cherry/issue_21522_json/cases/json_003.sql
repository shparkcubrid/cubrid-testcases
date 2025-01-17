select json_array('a',123,'123','"abc"','{"K":"1","j":"2"}');
select json_array('a',123,'123',"abc",'{"K":1,"j":2}');
select json_array('a',123,'123',"abc");
select json_contains( json_object('f', json_object('a', 123.2, 'b', json_array('x', 'y', 'z'))),'"x"');
select json_contains( json_object('f', json_object('a', 123.2, 'b', json_array('x', 'y', 'z'))),'"x"','/f/b');
select json_contains( json_object('f', json_object('a', 123.2, 'b', json_array('x', 'y', 'z'))),'"x"','/f');
select json_contains( json_object('f', json_object('a', 123.2, 'b', json_array('x', 'y', 'z'))),'"x"','/f/b/0');
select json_contains( json_object('f', json_object('a', 123.2, 'b', json_array('x', 'y', 'z'))),'"x"','/f/b/1');
select json_contains( json_object('f', json_object('a', 123.2, 'b', json_array('x', 'y', 'z'))),'"x"','/f/b/4');
select json_contains( json_object('f', json_object('a', 123.2, 'b', json_array('x', 'y', 'z'))),'{"a":"b"}','/f');
select json_contains( json_object('f', json_object('a', 123.2, 'b', json_array('x', 'y', 'z'))),'{"a":"b"}','/f/b');
select json_contains( json_object('f', json_object('a', 123.2, 'b', json_array('x', 'y', 'z'))),'{"a":123.2}','/f/b');   
select json_contains( json_object('f', json_object('a', 123.2, 'b', json_array('x', 'y', 'z'))),'{"a":123.2}','/f');

drop table if exists t;
create table t ( a json);
insert into t values (json_object('f', json_object('a', 123.2, 'b', json_array('x', 'y', 'z'))));
select json_contains( a,'"x"') from t;
select json_contains( a,'"x"','/f/b') from t;
select json_contains( a,'"x"','/f') from t;
select json_contains( a,'"x"','/f/b/0') from t;
select json_contains( a,'"x"','/f/b/1') from t;
select json_contains( a,'"x"','/f/b/4') from t;
select json_contains( a,'{"a":"b"}','/f') from t;
select json_contains( a,'{"a":"b"}','/f/b') from t;
select json_contains( a,'{"a":123.2}','/f/b') from t;
select json_contains( a,'{"a":123.2}','/f') from t;
drop table if exists t;
