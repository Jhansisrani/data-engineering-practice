# Lending Data Cleaning with Pandas

## Project Overview

This project demonstrates data cleaning and transformation using **Python and Pandas** on a lending dataset containing missing values, inconsistent representations, and datatype issues.

The objective was to inspect the raw dataset, identify data-quality problems, clean and transform the data, and generate a cleaned dataset for further analysis.

## Dataset

The original dataset was provided as an Excel file:

`Lending_data.xlsx`

The dataset contains lending-related information such as lender details, financial ratios, asset size, rankings, and other numerical and categorical attributes.

> The raw Excel file is used locally for practice. It may not be included in the public repository depending on the dataset's redistribution terms.

## Data Cleaning & Transformation

The following Pandas techniques were practiced:

* Loaded Excel data using `pandas.read_excel()`
* Inspected the dataset using:

  * `head()`
  * `tail()`
  * `info()`
  * `shape`
  * `describe()`
* Identified missing values using `isnull().sum()`
* Removed an unnecessary column
* Created a backup copy of the dataset
* Identified special missing-value representations such as `-`
* Replaced invalid/missing-value markers with `NaN`
* Checked categorical values using `value_counts()` and `unique()`
* Removed unwanted whitespace using `str.strip()`
* Converted string columns to numeric using `pd.to_numeric()`
* Used `errors='coerce'` to handle invalid numeric values
* Filled missing numerical values using column mean
* Converted categorical values such as `NR` into usable numerical representations
* Checked for invalid values such as `.`
* Validated the cleaned dataset using `info()`, `isnull()`, `unique()`, and value counts
* Exported the cleaned dataset to CSV

## Data Quality Issues Identified

The raw dataset contained several common data-quality issues:

* Missing values
* `-` used as a missing-value indicator
* `.` appearing as an invalid value
* Numeric values stored as strings
* Non-numeric values such as `NR`
* Leading/trailing whitespace
* Unnecessary columns
* Inconsistent categorical representations

## Cleaning Flow

```text
Raw Excel Dataset
        ↓
Data Inspection
        ↓
Remove Unnecessary Columns
        ↓
Identify Missing / Invalid Values
        ↓
Standardize Missing Values
        ↓
Clean String Values
        ↓
Convert Data Types
        ↓
Handle Missing Numerical Values
        ↓
Transform Categorical Values
        ↓
Validate Cleaned Data
        ↓
Export Cleaned CSV
```

## Tools & Technologies

* Python
* Pandas
* NumPy
* Jupyter Notebook
* Excel
* CSV

## Output

The cleaned dataset was exported as:

`Lending_cleansed.csv`

## Learning Outcome

This practice strengthened hands-on understanding of **Pandas data inspection, missing-value handling, datatype conversion, string cleaning, categorical transformation, validation, and dataset export**.

The project demonstrates a practical data-cleaning workflow that can be applied before downstream analysis or data-engineering pipelines.

