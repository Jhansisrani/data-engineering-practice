**Schema inference vs. explicit schemas**

Same file. Two approaches.
**inferSchema** 
Let Spark guess
load the files let spark decides..
None up front


**Explicit StructType** You define it
declare the file ..load the same files,compare..
A few lines of code


**inferSchema EXPLORATION**
Unfamiliar files, one-off analysis, quick looks
Add processing cost and can still produce a a schema that
does not fit future files.

**Explicit StructType PRODUCTION**
Scheduled pipelines, any write to a Delta table
Types are locked, nothing left to guess



When you used:

("T900", "C900", "P900", "S900", None, "5", 100.0, 500.0, "PROMO20")

"5" is technically a STRING, but because its value can be converted to an integer, Databricks cast it to the target INT column.

When you changed it to:

"abc"

it could not convert "abc" → INT, so you got:

cannot be cast to INT because it is malformed

So yes:

STRING "5" → INT 5 → succeeds
STRING "abc" → INT → fails

This is actually a useful thing to know for interviews: Delta/schema enforcement can involve type coercion for compatible values; incompatible/malformed values fail.

Your observation is correct.

The reason "5" was accepted is not specifically because schema evolution was trying to cast it.

What happened was:

    Existing Delta table has:
    quantity INT

    Your new DataFrame has:
    quantity STRING

    Spark/Delta sees that "5" is a numeric string and can safely cast it:
    STRING "5" → INT 5

    So the append succeeds.

    "abc" → INT is not possible, so it fails.

And mergeSchema is mainly for structural schema changes, such as adding a new column:

Existing table:
quantity INT

New DataFrame:
quantity INT
promo_code STRING

With:

.option("mergeSchema", "true")

Delta can evolve the table to include promo_code.

So remember:

Type coercion → "5" STRING can become 5 INT
Schema evolution → adding promo_code column
mergeSchema does NOT mean "cast every datatype difference."


============================================================
#TEST 2 - A missing column in the incoming DataFrame does not necessarily cause a schema error; the existing table column can receive NULL.
Missing total_amount did NOT fail. It was appended with the column missing, so Delta filled that column with NULL for the new row.

So this test teaches us:

A missing column in the incoming DataFrame does not necessarily cause a schema error; the existing table column can receive NULL.
=================================

---------------------------------------------
# ============================================================
# TEST 3 - MISSING REQUIRED COLUMN without schema defintion--
# ============================================================
The problem is this:

missing_data = [("T1101", "C1101", "P1101", "S1101", None, 2, 50.0)]

You used None and didn't provide a schema. Spark tries to infer the datatype, but it cannot determine the type of a column whose only value is None.

So:

None → no datatype information
       ↓
Spark cannot infer the schema
       ↓
CANNOT_DETERMINE_TYPE

This is schema inference failure, 

chema Enforcement = what happens when incoming data does not match the expected schema.

test has:

Incoming data
      ↓
Spark tries to create DataFrame
      ↓
Schema inference cannot determine the type
      ↓
CANNOT_DETERMINE_TYPE

That is a schema-related production issue, and it belongs in your Schema Enforcement module.

The distinction is only:

CANNOT_DETERMINE_TYPE → failure while inferring the incoming schema
"abc" → INT failure → failure while writing against the existing table schema
Both are useful Schema Enforcement / schema-management tests.

# ============================================================
# TEST 5 - all COLUMN without schema defintion--
# ============================================================


Yes, this is a valid 9-column row, because you added None for promo_code.

But there is one important issue: because you are using schema inference, the None value has no type information. Spark may fail with:

CANNOT_DETERMINE_TYPE






