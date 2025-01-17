-- SET WITH DEDUPLICATE OPTION TO SHOW
set system parameters 'print_index_detail=y';
set system parameters 'deduplicate_key_level=-1';

DROP TABLE IF EXISTS t_child;
CREATE TABLE t_child (
id INTEGER NOT NULL PRIMARY KEY,
pid INTEGER NOT NULL,
val CHARACTER VARYING(1) DEFAULT 'N'
);

set system parameters 'deduplicate_key_level=9';
ALTER TABLE t_child ADD INDEX ix_val_pid_de09 (val, pid);
/* Error pk can not with deduplicate */
CREATE INDEX ix_cannot_make ON t_child(id) WITH DEDUPLICATE=9;
CREATE UNIQUE INDEX ux_pid ON t_child(pid); 
CREATE INDEX ix_ign_dedupc ON t_child(pid,val) WITH DEDUPLICATE=9; 
SELECT index_of.index_name, key_attr_name, key_order, asc_desc
FROM _db_index_key 
WHERE index_of.class_of.class_name = 't_child'
ORDER BY index_of.class_of.class_name, key_order;
SHOW CREATE TABLE t_child;
DROP TABLE IF EXISTS t_child;

CREATE TABLE t_child (
id INTEGER NOT NULL PRIMARY KEY,
pid INTEGER NOT NULL,
val CHARACTER VARYING(1) DEFAULT 'N'
);

set system parameters 'deduplicate_key_level=10';
CREATE INDEX ix_val_pid_de10 ON t_child (val DESC, pid) WITH DEDUPLICATE=10;
SELECT index_of.index_name, key_attr_name, key_order, asc_desc 
FROM _db_index_key 
WHERE index_of.index_name like 'ix_val_pid_de%'
ORDER BY index_of.class_of.class_name, key_order;
SHOW CREATE TABLE t_child;
DROP INDEX ix_val_pid_de10 ON t_child;

set system parameters 'deduplicate_key_level=11';
CREATE INDEX ix_val_pid_de11 ON t_child (val, pid DESC);
SELECT index_of.index_name, key_attr_name, key_order, asc_desc 
FROM _db_index_key 
WHERE index_of.index_name = 'ix_val_pid_de11'
ORDER BY index_of.class_of.class_name, key_order;
SHOW CREATE TABLE t_child;
DROP INDEX ix_val_pid_de11 ON t_child;

set system parameters 'deduplicate_key_level=12';
CREATE INDEX ix_val_pid_de12 ON t_child (val DESC, pid DESC);
SELECT index_of.index_name, key_attr_name, key_order, asc_desc 
FROM _db_index_key 
WHERE index_of.index_name = 'ix_val_pid_de12'
ORDER BY index_of.class_of.class_name, key_order;
SHOW CREATE TABLE t_child;
DROP INDEX ix_val_pid_de12 ON t_child;

-- SET WITH DEDUPLICATE OPTION TO HIDE
set system parameters 'print_index_detail=n';
set system parameters 'deduplicate_key_level=13';
CREATE INDEX ix_val_pid_de13 ON t_child (NVL(val,''), pid DESC);
ALTER INDEX ix_val_pid_de13 ON t_child REBUILD;
SELECT index_of.index_name, key_attr_name, key_order, asc_desc, func 
FROM _db_index_key 
WHERE index_of.index_name = 'ix_val_pid_de13' 
ORDER BY index_of.class_of.class_name, key_order;
SHOW CREATE TABLE t_child;
DROP INDEX ix_val_pid_de13 ON t_child;

set system parameters 'deduplicate_key_level=14';
CREATE INDEX ix_val_pid_de14 ON t_child (val, pid) WHERE val = 'N';
ALTER INDEX ix_val_pid_de14 ON t_child REBUILD;
SELECT index_of.index_name, key_attr_name, key_order, asc_desc, func, index_of.filter_expression 
FROM _db_index_key 
WHERE index_of.index_name = 'ix_val_pid_de14' 
ORDER BY index_of.class_of.class_name, key_order;
SHOW CREATE TABLE t_child;

DROP TABLE IF EXISTS t_child;
set system parameters 'print_index_detail=n';
set system parameters 'deduplicate_key_level=-1';
