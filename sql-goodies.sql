-------------------------------------------------------------------------------
-- SQL Goodies
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Object Queries (taken from TOAD)

-- Tables
SELECT  O.OWNER, O.OBJECT_TYPE, O.OBJECT_NAME, O.STATUS, O.LAST_DDL_TIME, null info
from   sys.DBA_OBJECTS o
where  o.object_type = 'TABLE'
AND    O.OWNER = :own
and    not exists (select 1
                   from   ALL_SNAPSHOTS s
                   where  o.owner = s.owner
                   and    o.OBJECT_NAME = s.NAME)
and exists (select 1
            from V$OBJLST l
            where l.object_name = o.object_name
            and l.object_type = o.object_type
            and l.owner is not null)
order by 1,2,3;

-- Views
Select o.owner, o.object_type object_type,
       o.object_name, o.status, o.last_ddl_time, null info
from   DBA_OBJECTS o
where o.owner = :own
and o.object_type = 'VIEW'
and exists (select 1
from V$OBJLST l
where l.object_name = o.object_name
and l.object_type = o.object_type
and l.owner is not null)
order by 1,2,3;

-- Functions
Select o.owner, o.object_type object_type,
       o.object_name, o.status, o.last_ddl_time, null info
from   DBA_OBJECTS o
where o.owner = :own
and o.object_type = 'FUNCTION'
and exists (select 1
from V$OBJLST l
where l.object_name = o.object_name
and l.object_type = o.object_type
and l.owner is not null)
order by 1,2,3;

-- Procedures
select o.owner, o.object_type object_type,
       o.object_name, o.status, o.last_ddl_time, null info
from   DBA_OBJECTS o
where o.owner = :own
and o.object_type = 'PROCEDURE'
and exists (select 1
from V$OBJLST l
where l.object_name = o.object_name
and l.object_type = o.object_type
and l.owner is not null)
order by 1,2,3;

-- Packages
select o.owner, o.object_type object_type,
       o.object_name, o.status, o.last_ddl_time, null info
from   DBA_OBJECTS o
where o.owner = :own
and o.object_type = 'PACKAGE'
and exists (select 1
from V$OBJLST l
where l.object_name = o.object_name
and l.object_type = o.object_type
and l.owner is not null)
order by 1,2,3;

-- Package Bodies
select o.owner, o.object_type object_type,
       o.object_name, o.status, o.last_ddl_time, null info
from   DBA_OBJECTS o
where o.owner = :own
and o.object_type = 'PACKAGE BODY'
and exists (select 1
from V$OBJLST l
where l.object_name = o.object_name
and l.object_type = 'PACKAGE' -- we don't have package bodies in view, but packages
and l.owner is not null)
order by 1,2,3;

-- Triggers (are exported with tables)
select o.owner, o.object_type object_type,
       o.object_name, o.status, o.last_ddl_time, null info
from   DBA_OBJECTS o
where o.owner = :own
and o.object_type = 'TRIGGER'
and 1=0 --are exported with tables
order by 1,2,3;

-- Indexes
select o.owner, o.object_type object_type,
       o.object_name, o.status, o.last_ddl_time, null info
from   DBA_OBJECTS o
where o.owner = :own
and o.object_type = 'INDEX'
and exists (select 1
from V$OBJLST l
where l.object_name = o.object_name
and l.object_type = o.object_type
and l.owner is not null)
order by 1,2,3;

-- Constraints
select owner, 'CONSTRAINT' OBJECT_TYPE, CONSTRAINT_NAME OBJECT_NAME, STATUS, LAST_CHANGE LAST_DDL_TIME, null info
from   ALL_CONSTRAINTS
where   OWNER = :own
and 1=0 --are exported with tables
order by 1,2,3;

-- Sequences
select o.owner, o.object_type object_type,
       o.object_name, o.status, o.last_ddl_time, null info
from   DBA_OBJECTS o
where o.owner = :own
and o.object_type = 'SEQUENCE'
and exists (select 1
from V$OBJLST l
where l.object_name = o.object_name
and l.object_type = o.object_type
and l.owner is not null)
order by 1,2,3;

-- Types
select o.owner, o.object_type object_type,
       o.object_name, o.status, o.last_ddl_time, null info
from   DBA_OBJECTS o
where o.owner = :own
and o.object_type = 'TYPE'
and exists (select 1
from V$OBJLST l
where l.object_name = o.object_name
and l.object_type = o.object_type
and l.owner is not null)
order by 1,2,3;

-- Materialized View
SELECT  distinct o.owner, 'MATERIALIZED VIEW' OBJECT_TYPE, O.OBJECT_NAME, O.STATUS, O.LAST_DDL_TIME, null info
from   ALL_MVIEWS S, DBA_OBJECTS O
WHERE  O.OWNER = S.OWNER
AND    O.OBJECT_NAME = S.MVIEW_NAME
AND    O.OBJECT_TYPE = 'MATERIALIZED VIEW'
AND    O.OWNER = :own
AND exists (select 1
            from V$OBJLST l
            where l.object_name = o.object_name
            and l.object_type = 'MATERIALIZED'
            and l.owner is not null)
order by 1,2,3



-------------------------------------------------------------------------------
-- Constraints
-------------------------------------------------------------------------------
-- find all foreign key references from table 
SELECT a.table_name, a.column_name, a.constraint_name, c.owner, 
       -- referenced pk
       c.r_owner, c_pk.table_name r_table_name, c_pk.constraint_name r_pk
  FROM all_cons_columns a
  JOIN all_constraints c ON a.owner = c.owner
                        AND a.constraint_name = c.constraint_name
  JOIN all_constraints c_pk ON c.r_owner = c_pk.owner
                           AND c.r_constraint_name = c_pk.constraint_name
 WHERE c.constraint_type = 'R'
   AND a.table_name = :TableName
   AND a.owner = :Owner;

-- find all foreign key references to table
SELECT AC.TABLE_NAME,
       AC.R_CONSTRAINT_NAME,
       ACC.TABLE_NAME,
       ACC.COLUMN_NAME
FROM ALL_CONSTRAINTS  AC,
     ALL_CONS_COLUMNS ACC
WHERE AC.R_CONSTRAINT_NAME = ACC.CONSTRAINT_NAME
      AND AC.CONSTRAINT_TYPE = 'R'
    AND ACC.TABLE_NAME = :TableName
    AND ACC.OWNER = :Owner;

-------------------------------------------------------------------------------
-- Performance
-------------------------------------------------------------------------------
-- found on: https://stackoverflow.com/questions/316812/top-5-time-consuming-sql-queries-in-oracle

-------------------------------------------------------------------------------
-- Slow SQL

-- found this SQL statement to be a useful place to start (sorry I can't attribute this to the original author;
-- I found it somewhere on the internet):
SELECT * FROM
(SELECT
    sql_fulltext,
    sql_id,
    elapsed_time,
    child_number,
    disk_reads,
    executions,
    first_load_time,
    last_load_time
FROM    v$sql
ORDER BY elapsed_time DESC)
WHERE ROWNUM < 10
/

-- This finds the top SQL statements that are currently stored in the SQL cache ordered by elapsed time.
-- Statements will disappear from the cache over time, so it might be no good trying to diagnose
-- last night's batch job when you roll into work at midday.

-- You can also try ordering by disk_reads and executions. Executions is useful because some poor applications
-- send the same SQL statement way too many times. This SQL assumes you use bind variables correctly.
-- Then, you can take the sql_id and child_number of a statement and feed them into this baby:

SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', &child));
This shows the actual plan from the SQL cache and the full text of the SQL.

-- You should add elapsed_time in the select otherwise it's pretty confusing.
-- Add this WHERE Clause in the inner query to only include reacent slow queries:
-- WHERE LAST_LOAD_TIME > '2020-04-10' When running APEX these two fields are also useful: module, action,

-------------------------------------------------------------------------------
-- You could find disk intensive full table scans with something like this:
SELECT Disk_Reads DiskReads, Executions, SQL_ID, SQL_Text SQLText,
   SQL_FullText SQLFullText
FROM
(
   SELECT Disk_Reads, Executions, SQL_ID, LTRIM(SQL_Text) SQL_Text,
      SQL_FullText, Operation, Options,
      Row_Number() OVER
         (Partition By sql_text ORDER BY Disk_Reads * Executions DESC)
         KeepHighSQL
   FROM
   (
       SELECT Avg(Disk_Reads) OVER (Partition By sql_text) Disk_Reads,
          Max(Executions) OVER (Partition By sql_text) Executions,
          t.SQL_ID, sql_text, sql_fulltext, p.operation,p.options
       FROM v$sql t, v$sql_plan p
       WHERE t.hash_value=p.hash_value AND p.operation='TABLE ACCESS'
       AND p.options='FULL' AND p.object_owner NOT IN ('SYS','SYSTEM')
       AND t.Executions > 1
   )
   ORDER BY DISK_READS * EXECUTIONS DESC
)
WHERE KeepHighSQL = 1
AND rownum <=5;

-- Isn't DISK_READS the total number of disk reads, so you don't need to multiply by executions?

-------------------------------------------------------------------------------
-- You could take the average buffer gets per execution during a period of activity of the instance:
SELECT username,
       buffer_gets,
       disk_reads,
       executions,
       buffer_get_per_exec,
       parse_calls,
       sorts,
       rows_processed,
       hit_ratio,
       module,
       sql_text
       -- elapsed_time, cpu_time, user_io_wait_time, ,
  FROM (SELECT sql_text,
               b.username,
               a.disk_reads,
               a.buffer_gets,
               trunc(a.buffer_gets / a.executions) buffer_get_per_exec,
               a.parse_calls,
               a.sorts,
               a.executions,
               a.rows_processed,
               100 - ROUND (100 * a.disk_reads / a.buffer_gets, 2) hit_ratio,
               module
               -- cpu_time, elapsed_time, user_io_wait_time
          FROM v$sqlarea a, dba_users b
         WHERE a.parsing_user_id = b.user_id
           AND b.username NOT IN ('SYS', 'SYSTEM', 'RMAN','SYSMAN')
           AND a.buffer_gets > 10000
         ORDER BY buffer_get_per_exec DESC)
 WHERE ROWNUM <= 20;


-- It depends which version of oracle you have, for 9i and below Statspack is what you are after,
-- 10g and above, you want awr , both these tools will give you the top sql's and lots of other stuff.

-------------------------------------------------------------------------------
-- There are a number of possible ways to do this, but have a google for tkprof
-- There's no GUI... it's entirely command line and possibly a touch intimidating for Oracle beginners;
-- but it's very powerful. This link looks like a good start:

-- http://www.oracleutilities.com/OSUtil/tkprof.html

-- Is there any way to get the data with a sql query? Does Oracle maintains relevant data in some system tables?
-- It does not maintain as much data in the system tables as you get with tkprof.
-- See my answer for a quick and dirty way to look for bad statements. tkprof is better but you need to specifically setup a test and run it.

--the complete information one that I got from askTom-Oracle. I hope it helps you
select *
from v$sql
where buffer_gets > 1000000
or disk_reads > 100000
or executions > 50000;

-------------------------------------------------------------------------------
-- The following query returns SQL statements that perform large numbers of disk reads
-- (also includes the offending user and the number of times the query has been run):
SELECT t2.username, t1.disk_reads, t1.executions,
    t1.disk_reads / DECODE(t1.executions, 0, 1, t1.executions) as exec_ratio,
    t1.command_type, t1.sql_text
  FROM v$sqlarea t1, dba_users t2
  WHERE t1.parsing_user_id = t2.user_id
    AND t1.disk_reads > 100000
  ORDER BY t1.disk_reads DESC;

-- Run the query as SYS and adjust the number of disk reads depending on what you deem to be excessive (100,000 works for me).
-- I have used this query very recently to track down users who refuse to take advantage of Explain Plans before executing their statements.
-- I found this query in an old Oracle SQL tuning book (which I unfortunately no longer have), so apologies, but no attribution.

-------------------------------------------------------------------------------
-- LONGOPS
-- While searching I got the following query which does the job with one assumption(query execution time >6 seconds)
SELECT username, sql_text, sofar, totalwork, units
FROM v$sql,v$session_longops
WHERE sql_address = address AND sql_hash_value = hash_value
ORDER BY address, hash_value, child_number;

-- I think above query will list the details for current user.
