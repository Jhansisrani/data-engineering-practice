🔹 **Databricks Auto Loader: Schema Evolution vs `_rescued_data`**



🧩 The Two Faces of _rescued_data


1️⃣ When using addNewColumns (Schema Evolution Mode)

• What it does: Auto Loader's primary goal is to change your table's schema when it sees a new column.
• Why _rescued_data is created: By default, Auto Loader always adds the _rescued_data column as a safety net only for data type mismatches (e.g., expecting an INT but getting "abc").
• The Rule: New columns are never put into _rescued_data here—they are immediately evolved into real, normal columns.

2️⃣ When using rescue (Schema Enforcement Mode)

• What it does: You are telling Auto Loader, "Lock down the schema. Do not change it under any circumstances."
• Why _rescued_data is created: Now, the safety net has to catch both problems because the schema is frozen.
• The Rule: It will catch Data Type Mismatches (e.g., text in a decimal column) AND New/Unexpected Columns (e.g., if SALESCHANNEL arrives, it won't be added to the schema; it gets stuffed entirely into _rescued_data).
===========================================================================================================================================================================================================================================

While practicing Databricks Auto Loader hands-on, I came across an important distinction between **schema evolution** and **rescued data**.

They are related, but they are **not the same thing**.

### 1️⃣ What happens with a new column?

Suppose our existing schema contains:

`SALESORDERID | NETAMOUNT | TAXAMOUNT | ...`

and a new file arrives with:

`SALESCHANNEL`

If we use:

```text
cloudFiles.schemaEvolutionMode = "addNewColumns"
```

Auto Loader can **evolve the schema** and add:

`SALESCHANNEL`

as a normal column.

In my hands-on test, `_rescued_data` also appeared in the resulting Auto Loader schema.

⚠️ But simply seeing `_rescued_data` in the schema does **not** mean that data has actually been rescued.

### 2️⃣ When does data actually go into `_rescued_data`?

`_rescued_data` becomes useful when Auto Loader encounters source data that **doesn't fit the schema being used for the ingestion** under the configured rescue behavior.

For example, if a new/unexpected field is encountered while using:

```text
cloudFiles.schemaEvolutionMode = "rescue"
```

instead of adding that field as a normal column, Auto Loader can preserve it inside:

`_rescued_data`

So:

**`addNewColumns`**

➡️ New column → added to the schema

**`rescue`**

➡️ Unexpected/unrecognized data → captured in `_rescued_data`

### 3️⃣ Then I found an important catch with my own project

My Bronze schema was intentionally defined with **all columns as STRING**.

For example:

`TAXAMOUNT → STRING`

I deliberately put:

`TAXAMOUNT = "X"`

to test whether Auto Loader would rescue it.

It didn't.

Why?

Because from the schema's point of view:

`"X"` is a perfectly valid **STRING**.

Auto Loader doesn't know that TAXAMOUNT is *supposed* to be a number just because the column name suggests it.

So:

`TAXAMOUNT = "X"`
→ valid STRING
→ not a datatype mismatch
→ not rescued

💡 **This was an important learning for me:**

> A value can be business-invalid without being schema-invalid.

### 4️⃣ What happens if we explicitly define proper datatypes?

This is where rescue becomes more interesting.

Instead of:

```text
TAXAMOUNT → STRING
NETAMOUNT → STRING
CREATEDAT → STRING
```

we can explicitly define:

```text
TAXAMOUNT → DECIMAL(18,2)
NETAMOUNT → DECIMAL(18,2)
CREATEDAT → DATE
```

Now if the incoming source contains:

`TAXAMOUNT = "X"`

the value doesn't conform to the expected datatype.

With rescue behavior enabled, this becomes a meaningful **datatype-mismatch rescue test**, rather than simply being accepted as a string.

### 5️⃣ What happens to the rescued data later?

This is where the **Bronze → Silver** architecture becomes useful.

We can preserve the unexpected/incompatible source data in Bronze and later inspect `_rescued_data` during transformation.

In Silver, we can:

✅ parse valid values
✅ convert datatypes
✅ validate business rules
✅ handle invalid records
✅ extract useful information from `_rescued_data`
✅ quarantine/reject records according to the data-quality rules

For example:

```text
Bronze
"7248,5"
"X"
"20281205"
     ↓
Silver transformation
     ↓
7248.50
INVALID
2028-12-05
```

### ⭐ The key distinction

**Schema evolution answers:**

> "What should happen when the source structure changes?"

**Rescued data answers:**

> "What should happen when incoming data doesn't fit the schema we are using?"

And **data-quality transformation answers:**

> "Is this value actually valid for the business?"

These are three different concerns.

This hands-on experiment made the distinction much clearer to me than simply learning the Auto Loader options individually.


==========================================================================
