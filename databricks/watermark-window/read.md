# Databricks Structured Streaming — Event-Time Windows & Watermarks

## Overview

This practice demonstrates how **event-time windowing** and **watermarks** work in Databricks Structured Streaming using JSON events and an Auto Loader source.

The exercise focuses on understanding:

* Event-time windows
* Tumbling windows
* Watermarks
* Late-arriving events
* Window finalization
* Streaming state
* Append output mode
* Delta Lake as a streaming sink
* Checkpoints and streaming progress

## Architecture

```text
JSON Files
    ↓
Databricks Auto Loader
    ↓
Event-Time Watermark
    ↓
5-Minute Tumbling Window
    ↓
Aggregation
    ↓
Delta Lake
```

## Input Data

The practice uses JSON files containing:

```text
customer
event_time
```

Example:

```json
{"customer":"Rahul","event_time":"2026-10-02T10:00:00"}
{"customer":"Rahul","event_time":"2026-10-02T10:07:00"}
```

The event time is explicitly provided so that windowing and late-event behavior can be controlled during testing.

## Window Configuration

Events are grouped into 5-minute tumbling windows:

```python
.groupBy(
    window(col("event_time"), "5 minutes"),
    col("customer")
)
```

For example:

```text
10:00 → 10:05
10:05 → 10:10
10:10 → 10:15
10:15 → 10:20
```

## Watermark

A 10-minute watermark is applied to the `event_time` column:

```python
.withWatermark("event_time", "10 minutes")
```

Conceptually:

```text
Watermark = latest event_time observed - 10 minutes
```

For example, if the latest event observed is:

```text
10:20
```

the watermark is approximately:

```text
10:10
```

The watermark allows Spark to determine when older event-time windows are sufficiently old and their aggregation state can be cleaned up.

## Output Mode

This practice uses:

```python
.outputMode("append")
```

Append mode outputs a window when Spark considers the window finalized according to the watermark.

Therefore, the Delta output should **not** be interpreted as a continuously updated dashboard of the current count.

For example, a window may eventually be written as:

```text
10:15–10:20 | Rahul | 1
```

If another event for the same window arrives after that result has already been emitted, append mode does not rewrite the previously written Delta row.

## Late Events

A late event is an event whose `event_time` is older than the latest event-time progress observed by the stream.

The watermark determines how long Spark retains state for older windows.

Once a window has become too old and its state has been removed, a later event for that window cannot update the removed aggregation state.

## Important Learning Point

This practice separates three different things:

### 1. Source Data

The original JSON files remain in the landing directory.

```text
landing/
    batch1.json
    batch2.json
    batch3.json
```

The watermark does **not** delete these source files.

### 2. Streaming Checkpoint

The checkpoint stores streaming progress and state-related information required for the query.

```text
_checkpoint/
```

### 3. Delta Output

The aggregation results are written to the Delta output location.

```text
output/
```

These are separate from the source files and checkpoint.

## Key Takeaways

* Windowing groups events according to **event time**.
* A watermark is an **event-time progress boundary**, not a wall-clock timer.
* Watermarks allow Spark to eventually remove old aggregation state.
* Source files are not deleted by the watermark.
* Delta output is separate from streaming state.
* Append mode is designed for finalized results rather than continuously changing counts.
* Multiple input files can contribute to the same window.
* The number of input files does not necessarily equal the number of output rows.

## Practice Limitation

This exercise intentionally uses **append mode with an AvailableNow trigger** for learning.

It is useful for understanding watermark-based window finalization, but it is not intended to demonstrate continuously changing counts such as:

```text
1 → 2 → 3
```

A separate **update-mode/stateful streaming exercise** is better suited for demonstrating that behavior.

## Technologies

* Databricks
* Apache Spark Structured Streaming
* Auto Loader
* PySpark
* Delta Lake
* Event-time windowing
* Watermarks
# Databricks Structured Streaming — Event-Time Windows & Watermarks

## Overview

This practice demonstrates how **event-time windowing** and **watermarks** work in Databricks Structured Streaming using JSON events and Auto Loader.

The exercise focuses on:

* Event-time windows
* Tumbling windows
* Watermarks
* Late-arriving events
* Window finalization
* Streaming state
* Append output mode
* Delta Lake as a streaming sink
* Checkpoints and streaming progress

## Architecture

```text
JSON Files
    ↓
Databricks Auto Loader
    ↓
Event-Time Watermark
    ↓
5-Minute Tumbling Window
    ↓
Aggregation
    ↓
Delta Lake
```

## Input Data

The practice uses JSON files containing:

```text
customer
event_time
```

Example:

```json
{"customer":"Rahul","event_time":"2026-10-02T10:00:00"}
{"customer":"Rahul","event_time":"2026-10-02T10:07:00"}
```

The event time is explicitly provided so that windowing and late-event behavior can be controlled during testing.

## Window Configuration

Events are grouped into 5-minute tumbling windows:

```python
.groupBy(
    window(col("event_time"), "5 minutes"),
    col("customer")
)
```

Example:

```text
10:00 → 10:05
10:05 → 10:10
10:10 → 10:15
10:15 → 10:20
```

## Watermark

A 10-minute watermark is applied:

```python
.withWatermark("event_time", "10 minutes")
```

