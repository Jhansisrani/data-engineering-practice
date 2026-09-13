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
