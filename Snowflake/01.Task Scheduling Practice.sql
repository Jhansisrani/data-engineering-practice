-- ============================================================
-- Snowflake Task Scheduling Practice
-- ============================================================

-- Use the required role
USE ROLE jhansi;

-- Use database and schema
USE DATABASE ECOMMERCE_DB;
USE SCHEMA ECOMMERCE_LIV;


-- ============================================================
-- 1. Create target table for daily aggregated sales
-- ============================================================

CREATE OR REPLACE TABLE DAILY_AGGREGATED_SUMMARY (
    SUM_QTY NUMBER(24,2),
    TOTAL_BASE_PRICE NUMBER(24,2),
    TOTAL_DISCOUNT_PRICE NUMBER(37,4),
    TOTAL_CHARGE NUMBER(38,6),
    ORDER_COUNT NUMBER(18,0),
    SHIPPED_DATE DATE,
    SHIPPED_MODE VARCHAR(10)
);


-- ============================================================
-- 2. Create second target table
--    This table will receive the final summary
-- ============================================================

CREATE OR REPLACE TABLE ORDERS_BY_SHIPMODE (
    TOTAL_ORDERS NUMBER(30,0),
    TOTAL_DISCOUNT NUMBER(38,0),
    SHIPPED_DATE DATE,
    SHIPPED_MODE VARCHAR(10)
);


-- ============================================================
-- 3. Create a scheduled Task
--    The task automatically runs the aggregation SQL
--    according to the defined schedule.
-- ============================================================

CREATE OR REPLACE TASK DAILY_SALES_TASK1
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON * * * * * UTC' --1min
AS
INSERT INTO DAILY_AGGREGATED_SUMMARY
SELECT
    SUM(L_QUANTITY) AS SUM_QTY,
    SUM(L_EXTENDEDPRICE) AS TOTAL_BASE_PRICE,
    SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT)) AS TOTAL_DISCOUNT_PRICE,
    SUM(L_EXTENDEDPRICE * (1 - L_DISCOUNT) * (1 + L_TAX)) AS TOTAL_CHARGE,
    COUNT(*) AS ORDER_COUNT,
    DATE(L_SHIPDATE) AS SHIPPED_DATE,
    L_SHIPMODE AS SHIPPED_MODE
FROM LINEITEM
WHERE DATE(L_SHIPDATE) = '1992-08-20'
GROUP BY
    DATE(L_SHIPDATE),
    L_SHIPMODE;


-- Check the task definition
SHOW TASKS;


-- ============================================================
-- 4. Suspend the task
--    A suspended task will not execute automatically.
-- ============================================================

ALTER TASK DAILY_SALES_TASK1 SUSPEND;


-- ============================================================
-- 5. Change the task schedule
-- ============================================================

ALTER TASK DAILY_SALES_TASK1
SET SCHEDULE = 'USING CRON * * * * * UTC';


-- Check the updated task definition
SHOW TASKS;


-- ============================================================
-- 6. Resume the task
--    The task can now execute according to its schedule.
-- ============================================================

ALTER TASK DAILY_SALES_TASK1 RESUME;


-- Check the aggregated result
SELECT * FROM DAILY_AGGREGATED_SUMMARY;


-- ============================================================
-- 7. Create a dependent Task
--    This task runs AFTER DAILY_SALES_TASK1 completes.
-- ============================================================

CREATE OR REPLACE TASK ORDERS_SHIPMODE_TASK2
    WAREHOUSE = COMPUTE_WH
    AFTER DAILY_SALES_TASK1
AS
INSERT INTO ORDERS_BY_SHIPMODE
SELECT
    ROUND(SUM(ORDER_COUNT)) AS TOTAL_ORDERS,
    ROUND(SUM(TOTAL_DISCOUNT_PRICE), 0) AS TOTAL_DISCOUNT,
    SHIPPED_DATE,
    SHIPPED_MODE
FROM DAILY_AGGREGATED_SUMMARY
GROUP BY
    SHIPPED_DATE,
    SHIPPED_MODE;


-- ============================================================
-- 8. Resume the dependent task
-- ============================================================

ALTER TASK ORDERS_SHIPMODE_TASK2 RESUME;


-- Check task definitions
SHOW TASKS;


-- Check the final result
SELECT *
FROM ORDERS_BY_SHIPMODE;
