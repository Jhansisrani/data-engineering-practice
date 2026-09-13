\# Delta Lake Practice



\## Topics Covered



\- Delta Lake

\- Delta tables

\- Schema enforcement

\- Schema evolution

\- Table history

\- Time travel

\- Unity Catalog

\- Databricks table management



\## Key Learning



Delta Lake provides ACID transactions and data management features on top of data lake storage.



Schema enforcement helps prevent incompatible data from being written to a Delta table.



Schema evolution allows the schema to be updated when new columns or compatible changes are introduced.



Delta table history allows us to see previous versions of a table and use time travel to access earlier versions.



\## Practice



Created and worked with Delta tables in Databricks using SQL.



Explored table versions and history using:



```sql

DESCRIBE HISTORY table_name;
