--combination with join statements



create table stddev_int1(id1 int not null, col1 char(20));
insert into stddev_int1 values(1, 'aaa'), (2, 'bbb'), (3, 'ccc'), (4, 'ddd'), (5, 'eee'), (6, 'fff');
insert into stddev_int1 values(1, 'fff'), (2, 'eee'), (3, 'ddd'), (4, 'ccc'), (5, 'bbb'), (6, 'aaa');


create table stddev_int2(id2 int not null, col1 short);
insert into stddev_int2 values(2, 5), (4, 10), (6, 10), (2, 5), (1, 5), (4, 10);



--TEST: without table aliases + over()
select stddev_int1.id1, stddev_int1.col1, stddev_int2.col1, stddev(all stddev_int2.id2) over() stddev from stddev_int1, stddev_int2 where stddev_int1.id1=stddev_int2.id2 and stddev_int2.col1 < 10 order by 1, 2, 3;
--TEST: without table aliases + over(partition by ..)
select stddev_int2.id2, stddev_int1.col1, stddev_int2.col1, stddev(stddev_int2.id2) over(partition by stddev_int1.id1) stddev from stddev_int1, stddev_int2 where stddev_int1.id1=stddev_int2.id2 and stddev_int2.col1 < 10 order by 1, 2, 3;


--TEST: inner join + over(order by ...)
select m1.id1, m1.col1, m2.col1, stddev(m2.col1) over(order by m1.col1) stddev from stddev_int1 as m1 inner join stddev_int2 as m2 on m1.id1=m2.id2 order by 1, 2, 3;
--TEST: inner join + over(partition by ... order by ...)
select m2.id2, m1.col1, m2.col1, stddev(distinct m2.col1) over(partition by m1.id1 order by m2.col1) stddev from stddev_int1 as m1 inner join stddev_int2 as m2 on m1.id1=m2.id2 order by 1, 2, 3;


--TEST: left outer join + over()
select m2.id2, m1.col1, stddev(unique m1.id1) over() stddev from stddev_int1 m1 left outer join stddev_int2 m2 on m1.id1=m2.id2 where m1.id1 > (select stddev(id1) from stddev_int1) order by 1, 2, 3;
--TEST: left outer join + over(partition by ...)
select m1.id1, m1.col1, m2.id2, m2.col1, stddev(all m1.id1) over(partition by m2.col1) stddev from stddev_int1 m1 left outer join stddev_int2 m2 on m1.id1=m2.id2 where m1.id1 > (select stddev(id2) from stddev_int2) order by 1, 2, 3;


--TEST: right outer join + over(order by ...)
select m1.id1, m2.col1, m1.col1, stddev(distinct m2.id2) over(order by m1.col1, m2.col1) stddev from stddev_int1 m1 right outer join stddev_int2 m2 on m1.id1=m2.id2 where m1.id1 < (select stddev(id2) from stddev_int2) order by 1, 2, 3;
--TEST: right outer join + over(partition by ... order by ...)
select m1.id1, m2.col1, m1.col1, stddev(all m2.col1) over(partition by m2.col1 order by m1.id1, m1.col1) stddev from stddev_int1 m1 right outer join stddev_int2 m2 on m1.id1=m2.id2 order by m1.id1 order by 1, 2, 3;



drop table stddev_int1, stddev_int2;






