# Auto Loader – Schema Evolution

## Objective

Practice how Databricks Auto Loader handles changes in the source data schema and unexpected data types during streaming ingestion.

## Architecture

```text
JSON Files
    ↓
Databricks Auto Loader
    ↓
Delta Bronze Table
    ↓
Schema Evolution
    ↓
Rescued Data
```

## Environment

* Catalog: `retail`
* Schema: `sales`
* Volume: `autoloader_demo`
* Landing path: `/Volumes/retail/sales/autoloader_demo/schema_evolution/landing`
* Schema location: `/Volumes/retail/sales/autoloader_demo/schema_evolution/_schema`
* Checkpoint location: `/Volumes/retail/sales/autoloader_demo/schema_evolution/_checkpoint`
* Target table: `retail.sales.orders_schema_evolution`

## 1. Initial Source Schema

The first JSON file contained:

```text
order_id
customer
amount
```

Example:

```json
{"order_id": 1, "customer": "Aditi", "amount": 250}
{"order_id": 2, "customer": "Rahul", "amount": 120}
```

Auto Loader inferred the source schema and loaded the records into the Delta table.

## 2. Schema Evolution

A new JSON file was added with an additional `channel` column:

```json
{"order_id": 3, "customer": "Meera", "amount": 890, "channel": "Online"}
```

The source schema changed from:

```text
order_id
customer
amount
```

to:

```text
order_id
customer
amount
channel
```

With schema evolution enabled, the new column was added to the Delta table.

Existing records did not contain the new field, so their `channel` value was `NULL`.

## 3. Unexpected Data Type

A third file contained an unexpected value for `amount`:

```json
{
  "order_id": 4,
  "customer": "Sanjay",
  "amount": "NOT_A_NUMBER",
  "channel": "Store"
}
```

The `amount` column was expected to contain numeric values.

Auto Loader therefore produced:

```text
amount = NULL
```

and preserved the unexpected source value in:

```text
_rescued_data
```

Example result:

```text
amount | customer | order_id | _rescued_data
-------|----------|----------|-------------------------------
NULL   | Sanjay   | 4        | {"amount":"NOT_A_NUMBER", ...}
890    | Meera    | 3        | NULL
250    | Aditi    | 1        | NULL
120    | Rahul    | 2        | NULL
```

## 4. Concepts Practiced

* Databricks Auto Loader
* Spark Structured Streaming
* JSON ingestion
* Schema inference
* Schema location
* Checkpoint location
* Schema evolution
* Delta Lake `mergeSchema`
* Handling unexpected data types
* `_rescued_data`

## Key Learning

Schema evolution and data-quality handling are important when the structure or values of incoming source data can change over time.

Auto Loader can detect new source columns and, with the appropriate configuration, evolve the target Delta table. Unexpected values that do not fit the expected schema can be captured in `_rescued_data` instead of simply being lost.

## Practice Outcome

This exercise demonstrated two common source-data changes:

1. **New column added** → `channel`
2. **Unexpected data type** → `"NOT_A_NUMBER"` captured in `_rescued_data`

This was a separate practice exercise from the earlier Auto Loader incremental file-ingestion demo.
