--TEST: test with range partition table 

autocommit off;

drop table if exists p_disc;
create table p_disc(
	col1 int auto_increment,
	col2 smallint not null,
	col3 char(20) default 'abc',
	col4 datetime default SYS_DATETIME,
	col5 bit varying
) 
partition by range(col2) (
	partition p1 values less than(10),
	partition p2 values less than(20),
	partition p3 values less than(30),
	partition p4 values less than(100),
	partition p5 values less than(600)
);


insert into p_disc(col2, col3, col4, col5) values(500, 'cubrid', '1990-10-10 11:23:34.123', B'0001');
insert into p_disc(col2, col3, col4, col5) values(500, 'cubrid', '1990-11-10 11:23:34.123', B'0010');
insert into p_disc(col2, col3, col4, col5) values(500, 'mysql', '1990-10-11 11:23:34.123', B'0100');
insert into p_disc(col2, col3, col4, col5) values(500, 'cubrid', '1990-10-10 11:23:34.123', B'1000');
insert into p_disc(col2, col3, col4, col5) values(500, 'cubrid', '1991-10-10 11:23:34.123', B'0011');
insert into p_disc(col2, col3, col4, col5) values(501, 'oracle', '1990-10-10 11:23:34.123', B'0101');
insert into p_disc(col2, col3, col4, col5) values(501, 'cubrid', '1992-10-10 11:23:34.123', B'1001');
insert into p_disc(col2, col3, col4, col5) values(501, 'oracle', '1990-11-10 11:23:34.123', B'0110');
insert into p_disc(col2, col3, col4, col5) values(501, 'mysql', '1990-10-10 11:23:34.123', B'1010');
insert into p_disc(col2, col3, col4, col5) values(501, 'cubrid', '1990-10-10 11:23:34.123', B'1100');
insert into p_disc(col2, col3, col4, col5) values(501, 'mysql', '1991-11-10 11:23:34.123', B'0111');
insert into p_disc(col2, col3, col4, col5) values(502, 'cubrid', '1990-10-10 11:23:34.123', B'1110');
insert into p_disc(col2, col3, col4, col5) values(502, 'mysql', '1990-10-10 11:23:34.123', B'1111');
insert into p_disc(col2, col3, col4, col5) values(502, 'mysql', '1992-10-10 11:23:34.123', B'1010');
insert into p_disc(col2, col3, col4, col5) values(503, 'mysql', '1992-10-10 11:23:34.123', B'0101');
insert into p_disc(col2, col3, col4, col5) values(503, 'cubrid', '1990-10-10 11:23:34.123', B'1110');
insert into p_disc(col2, col3, col4, col5) values(503, 'cubrid', '1990-10-10 11:23:34.123', B'0111');
insert into p_disc(col2, col3, col4, col5) values(503, 'oracle', '1993-11-10 11:23:34.123', B'1101');
insert into p_disc(col2, col3, col4, col5) values(503, 'oracle', '1993-10-10 11:23:34.123', B'0011');
insert into p_disc(col2, col3, col4, col5) values(503, 'cubrid', '1993-11-10 11:23:34.123', B'0001');
insert into p_disc(col2, col3, col4, col5) values(503, 'cubrid', '1992-10-10 11:23:34.123', B'1100');
insert into p_disc(col2, col3, col4, col5) values(504, 'mysql', '1994-10-10 11:23:34.123', B'1011');
insert into p_disc(col2, col3, col4, col5) values(504, 'mysql', '1990-10-10 11:23:34.123', null);
insert into p_disc(col2, col3, col4, col5) values(504, 'cubrid', '1995-11-10 11:23:34.123', B'0110');
insert into p_disc(col2, col3, col4, col5) values(505, 'cubrid', '1991-10-10 11:23:34.123', '');
insert into p_disc(col2, col3, col4, col5) values(505, 'cubrid', '1996-10-10 11:23:34.123', B'1111');
insert into p_disc(col2, col3, col4, col5) values(505, 'mysql', '1990-10-10 11:23:34.123', B'0100');
insert into p_disc(col2, col3, col4, col5) values(505, 'cubrid', '1995-10-10 11:23:34.123', null);
insert into p_disc(col2, col3, col4, col5) values(505, 'cubrid', '1990-10-10 11:23:34.123', B'1111');

commit;

--test: use aggregate function in a subquery 
select (select percentile_disc(0.5) within group(order by col1) p_disc from p_disc) p_disc from p_disc order by 1;
select col1, col2, (select percentile_disc(0.5) within group(order by t2.col1) p_disc from p_disc t1) p_disc from p_disc t2 order by 1, 2, 3;
select col1, col2, (select percentile_disc(0.5) within group(order by t2.col1) p_disc from p_disc t1 group by t2.col2) p_disc from p_disc t2 order by 1, 2, 3;

--test: subquery in select statements
select p_disc from (select col3, percentile_disc(0.2) within group(order by col1+col2) p_disc from p_disc group by col3) order by 1;

select * from p_disc where col1 = (select percentile_disc(1) within group (order by col1) p_disc from p_disc) order by 1;
--test: [er]
select * from p_disc where col1 = (select percentile_disc(0.5) within group (order by col2) p_disc from p_disc group by col5);

select * from p_disc t1 where col4 = (select percentile_disc(0.8) within group (order by t1.col4) p_disc from p_disc) order by 1;
select * from p_disc t1 where col4 = (select percentile_disc(0.8) within group (order by t1.col4) p_disc from p_disc group by col2) order by 1;

select col1, col2, col3 from p_disc t1 where col1 < any(select percentile_disc(0.6) within group(order by col1) from p_disc) order by 1;
select col1, col2, col3 from p_disc t1 where col1 = some(select percentile_disc(0.1) within group(order by col1) from p_disc group by col5) order by 1;
select col1, col2, col3 from p_disc t1 where col1 < all(select percentile_disc(0.7) within group(order by col1) from p_disc t2 where t2.col3=t1.col3) order by 1;
select col1, col2, col3 from p_disc t1 where col1 >= any(select percentile_disc(0.9) within group(order by t1.col1) from p_disc) order by 1;
select col1, col2, col3 from p_disc t1 where col1 < any(select percentile_disc(1) within group(order by t1.col1) from p_disc t2 group by t2.col4) order by 1;

select col1, col2, col4, col5 from p_disc t1 where exists (select percentile_disc(0.5) within group(order by col4) from p_disc) order by 1;
select col1, col2, col4, col5 from p_disc t1 where exists (select col5, percentile_disc(0.5) within group(order by col2) from p_disc group by col4) order by 1;
select col1, col2, col4, col5 from p_disc t1 where exists (select percentile_disc(0) within group(order by t1.col4) from p_disc) order by 1;
select col1, col2, col4, col5 from p_disc t1 where exists (select percentile_disc(0.7) within group(order by t1.col4) from p_disc group by col5, col2) order by 1;


--test: subquery in update statement
update p_disc set col2 = (select percentile_disc(0.8) within group (order by col2) from p_disc);
select * from p_disc order by 1, 2, 3, 4, 5;
rollback;
update p_disc set col2 = (select percentile_disc(0.8) within group (order by col1) from p_disc);
select * from p_disc__p__p3 order by 1, 2, 3, 4, 5;
rollback;
update p_disc set col2 = (select percentile_disc(0.8) within group (order by col1) from p_disc group by col2 order by 1 limit 1);
select * from p_disc__p__p1 order by 1, 2, 3, 4, 5;
rollback;
update p_disc t1 set col2 = (select percentile_disc(0.8) within group (order by t1.col1) from p_disc where col1 < 20);
select * from p_disc__p__p1 order by 1, 2, 3, 4, 5;
select * from p_disc__p__p2 order by 1, 2, 3, 4, 5;
select * from p_disc__p__p3 order by 1, 2, 3, 4, 5;
rollback;
update p_disc t1 set col2 = (select percentile_disc(0.8) within group (order by t1.col1) from p_disc where col1 < 20 group by col2 order by 1 desc limit 1);
select * from p_disc order by 1, 2, 3, 4, 5;
rollback;

--test: subquery in odku statement
alter table p_disc add constraint pk primary key(col1, col2);
--BUG: CUBRIDSUS-16002 (resolved)
insert into p_disc(col1, col2, col3, col4, col5) values(20, 999, 'inserted', '2013-12-12 12:12:12.222', B'1111') on duplicate key update col1=(select percentile_disc(0.5) within group (order by col1) from p_disc);
select * from p_disc order by 1, 2, 3, 4, 5;
rollback;
alter table p_disc add constraint pk primary key(col1, col2);
insert into p_disc(col1, col2, col3, col4, col5) values(20, 503, 'inserted', '2013-12-12 12:12:12.222', B'1111') on duplicate key update col2=(select percentile_disc(0.89) within group (order by col2) from p_disc);
select * from p_disc order by 1, 2, 3, 4, 5;
rollback;

--test: subquery in merge statement
merge into p_disc t
using (select * from p_disc where col1 > 10) s
on (t.col1=s.col1)
when matched then update set t.col4=(select percentile_disc(0.88) within group(order by col4) from p_disc), t.col3='updated'
when not matched then insert(col2, col3) values(100, 'inserted');
select * from p_disc order by 1, 2, 3, 4, 5;
rollback;

alter table p_disc add constraint pk primary key(col1, col2);
merge into p_disc t
using (select * from p_disc where col1 > 10) s
on (t.col1=s.col1)
when matched then update set t.col2=(select percentile_disc(0.88) within group(order by s.col2)), t.col3='updated'
delete where t.col1 > 20
when not matched then insert(col2, col3) values(100, 'inserted');
select * from p_disc order by 1, 2, 3, 4, 5;
rollback;

select * from p_disc order by 1, 2, 3, 4, 5;

drop table p_disc;

commit;

autocommit on;

