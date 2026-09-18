
# Marketing Data Cleaning with Pandas, Snowflake & Visualization

## Project Overview

This project demonstrates a practical data cleaning and transformation workflow using **Python, Pandas, NumPy, Snowflake, and data visualization**.

The marketing dataset contains **1,143 records and 11 columns** covering campaign, audience, impression, click, spending, and conversion-related information.

The project focuses on identifying data-quality issues, cleaning and transforming the dataset, loading the processed data into Snowflake, and performing basic exploratory visualization.

## Technologies Used

* Python
* Pandas
* NumPy
* Snowflake
* Snowflake Python Connector
* Matplotlib
* Seaborn
* Jupyter Notebook

## Dataset

The dataset contains marketing campaign information including:

* `ad_id`
* `xyz_campaign_id`
* `fb_campaign_id`
* `age`
* `gender`
* `interest`
* `Impressions`
* `Clicks`
* `Spent`
* `Total_Conversion`
* `Approved_Conversion`

## Data Inspection

The dataset was initially inspected using Pandas to understand its structure and data quality.

Practiced:

* `head()`
* `tail()`
* `info()`
* `shape`
* `isnull()`
* `isnull().sum()`
* `unique()`
* `value_counts()`

The initial dataset contained:

* Missing values
* Numeric values stored as strings
* Invalid values
* Categorical columns requiring transformation

## Data Cleaning

### Missing Values

Missing values were identified using:

```python
Marketing_data.isnull().sum()
```

Missing numerical values were handled using **median imputation**.

The median was used instead of the mean because some numerical columns contained skewed distributions and potential outliers.

### Invalid Values

The `Approved_Conversion` column contained an invalid `&` value.

It was converted to numeric using:

```python
Marketing_data['Approved_Conversion'] = pd.to_numeric(
    Marketing_data['Approved_Conversion'],
    errors='coerce'
)
```

Using `errors='coerce'` converted invalid values into `NaN`, which could then be handled during missing-value treatment.

### Numeric Conversion

The `Impressions` column was stored as an object/string type and was converted into a numeric datatype:

```python
Marketing_data['Impressions'] = pd.to_numeric(
    Marketing_data['Impressions'],
    errors='coerce'
)
```

Missing values created during conversion were subsequently handled using median imputation.

## Outlier Analysis

The Interquartile Range (IQR) method was used to identify potential outliers in numerical columns.

Potential outliers were examined in:

* `interest`
* `Clicks`
* `Spent`
* `Total_Conversion`
* `Approved_Conversion`

Outliers were **not automatically removed**, because unusually high values can represent legitimate high-performing marketing campaigns.

## Categorical Data Transformation

### Gender

The `gender` column was converted into numerical representation using one-hot encoding:

```python
pd.get_dummies(
    Marketing_data,
    columns=['gender'],
    drop_first=True
)
```

The resulting `gender_M` column was converted to integer values.

### Age

Age ranges were mapped to numerical values:

```python
age_map = {
    '30-34': 1,
    '35-39': 2,
    '40-44': 3,
    '45-49': 4
}
```

## Column Standardization

Column names were converted to uppercase:

```python
Marketing_data.columns = Marketing_data.columns.str.upper()
```

This also made the dataset consistent with the Snowflake table definition.

## Snowflake Loading

The cleaned Pandas DataFrame was loaded into Snowflake using the **Snowflake Python Connector** and `write_pandas()`.

A Snowflake table named:

```text
MARKETING_DATA
```

was created with appropriate numeric datatypes.

The cleaned dataset was then loaded using:

```python
write_pandas(
    conn,
    Marketing_data,
    'MARKETING_DATA',
    chunk_size=200
)
```

The load completed successfully with:

```text
Success: True
Number of chunks: 6
Number of rows: 1143
```

## Visualization

Seaborn and Matplotlib were used for basic exploratory visualization.

Boxplots were created for:

* `Spent`
* `Approved_Conversion`
* `Total_Conversion`

For example:

```python
sns.boxplot(x=Marketing_data['Spent'])
plt.show()
```

The `Spent` column showed a right-skewed distribution.

The calculated skewness was approximately:

```text
2.71
```

This supported the use of median-based handling for missing numerical values.

## End-to-End Flow

```text
Marketing CSV
      ↓
Load using Pandas
      ↓
Data Inspection
      ↓
Missing Value Analysis
      ↓
Invalid Value Detection
      ↓
Numeric Conversion
      ↓
Median Imputation
      ↓
Outlier Analysis using IQR
      ↓
Categorical Transformation
      ↓
Column Standardization
      ↓
Exploratory Visualization
      ↓
Load into Snowflake
      ↓
MARKETING_DATA
```

## Key Learning Outcomes

This project provided hands-on practice with:

* Pandas data inspection
* Missing-value analysis
* Median imputation
* Invalid-value handling
* Numeric datatype conversion
* IQR-based outlier analysis
* One-hot encoding
* Categorical-to-numeric transformation
* DataFrame column standardization
* Snowflake Python Connector
* Loading Pandas DataFrames into Snowflake
* Basic exploratory data visualization using Seaborn and Matplotlib

## Project Outcome

The project demonstrates a complete practice workflow from **raw marketing data → data cleaning and transformation → visualization → Snowflake loading** using Python and SQL-based data warehousing technology.
