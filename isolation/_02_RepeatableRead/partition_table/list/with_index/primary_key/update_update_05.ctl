/*
Test Case: update & update
Priority: 1
Reference case:
Author: Mandy

Test Point:
When two transaction update the same record, the second updater can proceed only if the first transaction rollbacks.
If the first transaction commits, the second transaction must be aborted.

In this case, 3 transations update overlapped data. 
Currently, the partitions are scanned in the order they are specified even if they share the same index. In this case, t1_p0 is scanned first, then t1_p1. Transaction C1 successfully acquire locks on 1, 2, 3. Transaction C2 is blocked, waiting for lock on 3 not 2 since t1_p0 is scanned before t1_p1. Transaction C3 is blocked, waiting for lock on 3, as expected. So, C2 and C3 are waiting on the same object.

NUM_CLIENTS = 4 
C1: update on table t1  
C2: update on table t1 
C3: update on table t1 
C4: C4 select on table t1, this client is used to check the update result 
*/


MC: setup NUM_CLIENTS = 4;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level repeatable read;

C4: set transaction lock timeout INFINITE;
C4: set transaction isolation level repeatable read;

/* preparation */
C1: drop table if exists t1;
C1: create table t1(id int primary key, col varchar(10)) partition by list (id) (partition p0 values in (1,3,5,7), partition p1 values in (2,4,6,8));
C1: insert into t1 values(1,'abc');insert into t1 values(2,'def');insert into t1 values(3,'abc');insert into t1 values(4,'ijk');insert into t1 values(5,'abc');
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: update t1 set col='aa' where id<4;
MC: wait until C1 ready;
C2: update t1 set col='bb' where id>1 and id<5;
MC: wait until C2 blocked;
C3: update t1 set col='cc' where id>2; 
MC: wait until C3 blocked;
C1: commit;
MC: wait until C2 ready;
MC: wait until C3 ready;
C2: select * from t1 order by 1,2;
MC: wait until C2 ready;
C2: commit;
MC: wait until C2 ready;
C3: select * from t1 order by 1,2;
C3: commit;
MC: wait until C3 ready;
/* C2 C3 abort, so we cannot see their update results */
C4: select * from t1 order by 1,2;

C4: commit;
C1: quit;
C2: quit;
C3: quit;
C4: quit;

