# Clip 5 — Incremental File Processing with `availableNow`

This exercise demonstrates how Spark Structured Streaming with Auto Loader processes newly arrived files incrementally using the `availableNow` trigger.

## What I Practiced

- Using `readStream` with Auto Loader
- Processing JSON files from a source folder
- Using `writeStream` with Delta
- Using the `availableNow` trigger
- Reusing the same checkpoint across streaming runs
- Processing newly arrived files incrementally
- Verifying individual file data and cumulative Delta results
- Understanding `append` output mode

## Test Flow

1. Created `orders_001.json` → first streaming run → 5 rows
2. Created `orders_002.json` → second streaming run → 5 additional rows
3. Created `orders_003.json` → third streaming run → 5 additional rows
4. Verified the Delta table contained 15 rows in total

## Key Concept

`availableNow` processes the data currently available when the streaming query starts and then stops. When new files arrive later, the query can be started again using the same checkpoint to process only the newly available files.

**Source → Auto Loader → `writeStream` → Delta Table**
