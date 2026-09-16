-- ============================================================
-- APPEND-ONLY STREAM CDC PRACTICE
-- ============================================================

-- Use SYSADMIN role
USE ROLE SYSADMIN;

-- Select the database
USE DATABASE JHANSI_STORE;

-- Create a separate schema for Stream practice
CREATE OR REPLACE SCHEMA STREAMS_TEST;

USE SCHEMA STREAMS_TEST;


-- ============================================================
-- 1. Create the staging/source table
-- ============================================================

-- This table acts as the source table.
CREATE OR REPLACE TABLE STAGING_TABLE (
    ID NUMBER(8) NOT NULL,
    NAME VARCHAR(255) DEFAULT NULL,
    FEE NUMBER(3) NULL
);


-- ============================================================
-- 2. Create the production/target table
-- ============================================================

-- This table will consume the data from the Stream.
CREATE OR REPLACE TABLE PROD_TABLE (
    ID NUMBER(8) NOT NULL,
    NAME VARCHAR(255) DEFAULT NULL,
    FEE NUMBER(3) NULL
);


-- ============================================================
-- 3. Create an Append-Only Stream
-- ============================================================

-- APPEND_ONLY = TRUE means the Stream captures
-- only INSERT changes from the staging table.
--
-- UPDATE and DELETE changes are not captured
-- by this append-only Stream.

CREATE OR REPLACE STREAM STAGING_APPEND_STREAM
ON TABLE STAGING_TABLE
APPEND_ONLY = TRUE;


-- Check the Stream before inserting any data
SELECT * FROM STAGING_APPEND_STREAM;


-- ============================================================
-- 4. Check the Stream offset
-- ============================================================

-- Check the Stream position in the source table's
-- change history.

SELECT SYSTEM$STREAM_GET_TABLE_TIMESTAMP(
    'STAGING_APPEND_STREAM'
) AS MEMBERS_TABLE_ST_OFFSET;

================
--MEMBERS_TABLE_ST_OFFSET
--175783000000000000
================
-- Convert the offset value into a readable timestamp
SELECT TO_TIMESTAMP(
    SYSTEM$STREAM_GET_TABLE_TIMESTAMP('STAGING_APPEND_STREAM')
) AS MEMBERS_TABLE_ST_OFFSET;

=======================
--MEMBERS_TABLE_ST_OFFSET
--2026-09-14 09:30:00.000
============================
-- ============================================================
-- 5. Insert initial data into the staging table
-- ============================================================

INSERT INTO STAGING_TABLE (ID, NAME, FEE)
VALUES
    (1, 'Snowflake', 0),
    (2, 'AWS', 0),
    (3, 'Python', 0),
    (4, 'SQL', 0),
    (5, 'DE', 0);


-- ============================================================
-- 6. Check the Stream after INSERT
-- ============================================================

-- The INSERT changes should now be visible in the Stream.

SELECT * FROM STAGING_APPEND_STREAM;


-- Check the Stream offset again
SELECT SYSTEM$STREAM_GET_TABLE_TIMESTAMP(
    'STAGING_APPEND_STREAM'
) AS MEMBERS_TABLE_ST_OFFSET;


-- ============================================================
-- 7. Query the Stream data
-- ============================================================

-- METADATA$ACTION shows the type of change.
-- For an append-only Stream, we expect INSERT records.

SELECT
    ID,
    NAME,
    FEE
FROM STAGING_APPEND_STREAM
WHERE METADATA$ACTION = 'INSERT';


-- ============================================================
-- 8. Consume the Stream data
-- ============================================================

-- Reading the Stream alone does NOT consume it.
--
-- This DML operation reads the Stream and inserts
-- the captured records into the production table.

INSERT INTO PROD_TABLE (ID, NAME, FEE)
SELECT
    ID,
    NAME,
    FEE
FROM STAGING_APPEND_STREAM
WHERE METADATA$ACTION = 'INSERT';


-- Check the production table
SELECT * FROM PROD_TABLE;


-- Check the Stream offset after consumption
SELECT TO_TIMESTAMP(
    SYSTEM$STREAM_GET_TABLE_TIMESTAMP('STAGING_APPEND_STREAM')
) AS MEMBERS_TABLE_ST_OFFSET;


-- ============================================================
-- 9. Insert more data into the staging table
-- ============================================================

-- Insert two new IDs.
-- ID 6 is intentionally inserted twice to practice
-- how an append-only Stream captures INSERT events.

INSERT INTO STAGING_TABLE (ID, NAME, FEE)
VALUES
    (6, 'Power BI', 0),
    (7, 'Alteryx', 0),
    (6, 'Power BI', 0);


-- Check the Stream
SELECT * FROM STAGING_APPEND_STREAM;


-- ============================================================
-- 10. Update a record in the staging table
-- ============================================================

-- Update ID 7.
--
-- Important:
-- This is an UPDATE operation.
-- An APPEND-ONLY Stream does not capture UPDATE changes.

UPDATE STAGING_TABLE SET FEE = 10 WHERE ID = 7;


-- Check the Stream again
SELECT * FROM STAGING_APPEND_STREAM;


-- ============================================================
-- 11. Consume the newly captured INSERT records
-- ============================================================

-- Only INSERT changes are selected from the Stream.
-- The UPDATE to ID 7 is not captured by this
-- append-only Stream.

INSERT INTO PROD_TABLE (ID, NAME, FEE)
SELECT
    ID,
    NAME,
    FEE
FROM STAGING_APPEND_STREAM
WHERE METADATA$ACTION = 'INSERT';


-- Check the production table
SELECT * FROM PROD_TABLE;


-- Check the current staging/source data
SELECT * FROM STAGING_TABLE;


-- ============================================================
-- 12. Update the staging table again
-- ============================================================

-- Change ID 7 from fee = 10 to fee = 20.
--
-- Again, this UPDATE is not captured by the
-- append-only Stream.

UPDATE STAGING_TABLE SET FEE = 20 WHERE ID = 7;


-- Check the Stream
SELECT * FROM STAGING_APPEND_STREAM;
