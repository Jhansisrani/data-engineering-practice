-- Module 3: Using MERGE for Upserts

-- 1. Baseline row count
SELECT COUNT(*) AS customer_count
FROM retail.sales.customers;

-- 2. Find a Silver customer
SELECT customer_id, full_name, loyalty_tier
FROM retail.sales.customers
WHERE loyalty_tier = 'Silver'
LIMIT 5;

-- 3. Inspect staging source
SELECT *
FROM retail.sales.customers_staged;

-- 4. MERGE customers_staged into customers
MERGE INTO retail.sales.customers AS target
USING retail.sales.customers_staged AS source
ON target.customer_id = source.customer_id

WHEN MATCHED THEN
  UPDATE SET
    target.loyalty_tier = source.loyalty_tier,
    target.last_updated = source.last_updated

WHEN NOT MATCHED THEN
  INSERT (customer_id, loyalty_tier, last_updated)
  VALUES (source.customer_id, source.loyalty_tier, source.last_updated);

-- 5. Verify result
SELECT COUNT(*) AS customer_count_after
FROM retail.sales.customers;

SELECT customer_id, full_name, loyalty_tier, last_updated
FROM retail.sales.customers
WHERE customer_id = 'C0002';
