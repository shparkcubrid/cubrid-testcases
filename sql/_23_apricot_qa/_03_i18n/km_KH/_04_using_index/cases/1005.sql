--+ holdcas on;
set names utf8;
--mixdey ; index created after data is inserted
create class test_kh (i integer,s char(5) collate utf8_km_exp,j integer,t varchar(5) collate utf8_km_exp,x char(4) collate utf8_km_exp );
insert into test_kh values(101, 'ឯឡ៏ខឯ', 100001, '៩៝ខ០ត', '៩នកឯ');
insert into test_kh values(102, 'ឯឡ៏ខត', 100002, 'ឦ៝ខ០ា', 'ឦនកឯ');
insert into test_kh values(103, 'ឯឡ៏ខះ', 100003, '៘៝ខ០៘', 'នកឯ');
insert into test_kh values(104, 'ឯឡ៏ខក', 100004, 'ា៝ខ០ឦ', 'នកឯ');
insert into test_kh values(105, 'ឯឡក៣៰', 100005, 'ត៴ឰ០៩', 'នកឯ');
create unique index foo_udx on test_kh (i, s, j, t);
create index int_idx on test_kh (i, j);

select * from test_kh where i = 101 and j = 100001 order by i;

select * from test_kh where i = 101 and j = 100001 using index foo_udx order by j;


select * from test_kh where s = 'ឯឡ៏ខត' and x = 'ឦនកឯ' order by s;

select * from test_kh where s = 'ឯឡ៏ខត' and x = 'ឦនកឯ' using index foo_udx order by x;

select * from test_kh where s = 'ឯឡ៏ខត' and t = 'ឦ៝ខ០ា' order by x;

select * from test_kh where t = 'ា៝ខ០ឦ' or x = 'នកឯ' order by s;

select * from test_kh where t = 'ា៝ខ០ឦ' or x = 'នកឯ' using index foo_udx(+) order by t;

select * from test_kh where i = 101 or t = 'ា៝ខ០ឦ' using index int_idx, foo_udx  order by i;

select * from test_kh where i = 101 or t = 'ា៝ខ០ឦ' using index int_idx(+), foo_udx(+)  order by x;

select * from test_kh where i = 101 or t = 'ា៝ខ០ឦ' using index none  order by t;

drop class test_kh;
set names iso88591;
commit;
--+ holdcas off;

