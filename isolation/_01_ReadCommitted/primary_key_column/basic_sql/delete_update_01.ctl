/*
Test Case: delete & update
Priority: 1
Reference case:
Author: Ray

Test Plan: 
Test DELETE/UPDATE locks (X_LOCK on instance) if the instances of the transactions are not overlapped (with pk schema)

Test Scenario:
C1 delete, C2 update, the affected rows are not overlapped
C1, C2 where clause are all on pk (i.e. index scan)
C1 commit, C2 commit
Metrics: schema = single table with pk, data size = small, where clause = simple

Test Point:
1) C1 and C2 will not be waiting 
2) C1 instances should be updated, C2 instances should be deleted

NUM_CLIENTS = 3
C1: delete from table t1;
C2: update table t1;  
C3: select on table t1; C3 is used to check the updated result
*/

MC: setup NUM_CLIENTS = 3;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS t1;
C1: CREATE TABLE t1(id INT PRIMARY KEY, col VARCHAR(10), tag VARCHAR(2));
C1: INSERT INTO t1 VALUES(1,'abc','A'),(2,'def','B'),(3,'ghi','C'),(4,'jkl','D'),(5,'mno','E'),(6,'pqr','F'),(7,'abc','G');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE id >= 2 and id <= 4; 
MC: wait until C1 ready;
C2: UPDATE t1 SET col = 'abcd' WHERE id >= 4 and col != 'jkl';
/* expect: no transactions need to wait */
MC: wait until C2 ready;
/* expect: C1 select - id = 2,3,4 are deleted */
C1: SELECT * FROM t1 order by 1,2;
MC: wait until C1 ready;
/* expect: C2 select - id = 5,6,7 are updated */
C2: SELECT * FROM t1 order by 1,2;
MC: wait until C2 ready;
C1: commit;
MC: wait until C1 ready;
C2: commit;
MC: wait until C2 ready;
/* expect: the instances of id = 2,3,4 are deleted & id = 5,6,7 are updated */
C3: select * from t1 order by 1,2;

C1: quit;
C2: quit;
C3: quit;
