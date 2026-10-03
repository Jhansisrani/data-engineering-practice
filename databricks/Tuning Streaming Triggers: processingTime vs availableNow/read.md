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


## `processingTime` vs `availableNow`

The original example uses:

```python
q = (
    orders.writeStream
    .format("delta")
    .outputMode("append")
    .option("checkpointLocation", f"{CKPT}/bronze")
    .trigger(processingTime="10 seconds")
    .toTable(TABLE)
)
```

### How `processingTime` works

With `processingTime="10 seconds"`, the streaming query **keeps running** after `writeStream` starts.

It checks for new data approximately every 10 seconds.

```text
writeStream starts
       ↓
Query keeps running
       ↓
Every ~10 seconds → check for new files
       ↓
New file found?
       ↓
Yes → process the file
       ↓
Wait for the next trigger
       ↓
Check again
       ↓
Continue running...
```

For example:

```python
drop_file("001", rows=5)
```

This function only **adds a new JSON file** to the source folder.

Because the `processingTime` streaming query is already running, Spark can detect the new file during a subsequent trigger and process it automatically.

We do **not** need to start `writeStream` again for every new file while the query is running.
```python
drop_file("002", rows=5)
```
### How `availableNow` works

Our Databricks Serverless environment does not support `processingTime`, so we used:

```python
.trigger(availableNow=True)
```

`availableNow` is different because the query **does not keep running**.

```text
Start writeStream
       ↓
Process currently available files
       ↓
Finish processing
       ↓
STOP
```

If a new file arrives after the query has stopped:

```text
Run 1
  ↓
Process available files
  ↓
STOP

Add new file
  ↓
Run writeStream again
  ↓
Process the new file
  ↓
STOP
```

Therefore:

* **`processingTime`** → the query keeps running and periodically checks for new files.
* **`availableNow`** → the query processes the available data and then stops.
* With `availableNow`, when new data arrives later, we need to **start the streaming query again**.
* The same checkpoint is reused so previously processed files are not processed again.

### Important environment note

The tutor's `processingTime="10 seconds"` example is useful for understanding continuously running streaming queries, but it is **not supported on the Databricks Serverless compute used for this practice**.

For this environment, `availableNow=True` is the Serverless-compatible approach used in our exercise.
