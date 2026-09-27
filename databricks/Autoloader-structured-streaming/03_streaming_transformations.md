
# Streaming Transformations with Auto Loader

## Objective

Practice applying transformations to data while it is being ingested through Databricks Auto Loader.

This is a separate practice from the earlier incremental file-ingestion and schema-evolution exercises.

## Architecture

```text
JSON Files
    ↓
Auto Loader
    ↓
Streaming DataFrame
    ↓
Transformations
    ↓
Delta Table
```

## Environment

* Catalog: `retail`
* Schema: `sales`
* Volume: `autoloader_demo`
* Landing path: `/Volumes/retail/sales/autoloader_demo/streaming_transformations/landing`
* Schema location: `/Volumes/retail/sales/autoloader_demo/streaming_transformations/_schema`
* Checkpoint location: `/Volumes/retail/sales/autoloader_demo/streaming_transformations/_checkpoint`
* Target table: `retail.sales.orders_transformed`

## Transformations Practiced

### 1. Rename columns

The incoming columns:

```text
order_id
customer
amount
```

were renamed to:

```text
sales_order_id
customer_name
order_amount
```

### 2. Create a derived column

A new `order_category` column was created based on the order amount.

```text
order_amount >= 500
        ↓
   High Value

order_amount < 500
        ↓
    Regular
```

## Example

Input:

```text
order_id | customer | amount
---------|----------|-------
1        | Jhansi   | 250
2        | Sathish  | 120
3        | Jhashvin | 890
```

Output:

```text
sales_order_id | customer_name | order_amount | order_category
---------------|---------------|--------------|---------------
1              | Jhansi        | 250          | Regular
2              | Sathish       | 120          | Regular
3              | Jhashvin      | 890          | High Value
```

## Incremental Processing

A second JSON file was added after the initial stream.

The new records were processed using Auto Loader without rebuilding the source dataset manually.

This demonstrated how streaming transformations can be applied to newly arriving files.

## Concepts Practiced

* Spark Structured Streaming
* Databricks Auto Loader
* Streaming DataFrames
* `readStream`
* `writeStream`
* Column renaming
* Derived columns
* Conditional transformations using `when`
* Checkpointing
* Incremental file processing
* Writing streaming results to Delta tables

## Key Learning

Transformations can be applied directly to a streaming DataFrame before writing the results to a Delta table.

The same transformation logic can therefore be applied consistently to both the initial files and newly arriving files.

## Practice Outcome

This exercise demonstrated a simple streaming transformation pipeline:

```text
Incoming JSON
    ↓
Auto Loader
    ↓
Streaming DataFrame
    ↓
Rename columns
    ↓
Create business column
    ↓
Delta table
```

This pattern will later be used in the real Sales Order project when transforming Bronze data into Silver data.
