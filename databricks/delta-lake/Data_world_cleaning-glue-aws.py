
from pyspark.sql import SparkSession

from pyspark.sql.functions import (
    col, sum, count, when, avg, mean,
    to_date, trim, initcap
)

from pyspark.sql.types import StringType
from pyspark.sql.window import Window

from pyspark.sql.types import (
    IntegerType, LongType, FloatType,
    DoubleType, DecimalType, ShortType
)
 



spark = SparkSession.builder.appName("Data_world_cleaning").getOrCreate()

file_path = '/Volumes/workspace/db_jhansi/world_db_data/World Indicators_Migrated Data5.csv'
df = spark.read.csv(file_path, header=True, inferSchema=True)

df.printSchema()
df.show()

print(df.count())
print(len(df.columns))



df=(
    df.withColumnRenamed("Country/Region","country")
     .withColumnRenamed("Region","region")
     .withColumnRenamed("Year","year")
     .withColumnRenamed("Birth Rate","birth_rate")
     .withColumnRenamed("Business Tax Rate","business_tax_rate")
     .withColumnRenamed("CO2 Emissions","co2_emissions")
     .withColumnRenamed("Days to Start Business","days_to_start_business")
     .withColumnRenamed("Ease of Business","ease_of_business")
     .withColumnRenamed("Energy Usage","energy_usage")
     .withColumnRenamed("GDP","gdp")
     .withColumnRenamed("Health Exp % GDP","health_exp_gdp")
     .withColumnRenamed("Health Exp/Capita","health_exp_capita")
     .withColumnRenamed("Hours to do Tax","hours_to_do_tax")
     .withColumnRenamed("Infant Mortality Rate","infant_mortality_rate")
     .withColumnRenamed("Internet Usage","internet_usage")
     .withColumnRenamed("Lending Interest","lending_interest")
     .withColumnRenamed("Life Expectancy Female","life_expectancy_female")
     .withColumnRenamed("Life Expectancy Male","life_expectancy_male")
     .withColumnRenamed("Mobile Phone Usage","mobile_phone_usage")
     .withColumnRenamed("Military Expenditure","military_expenditure")
     .withColumnRenamed("Population","population")
     .withColumnRenamed("Property Rights","property_rights")
     .withColumnRenamed("Number of Records","number_of_records")
     .withColumnRenamed("Population 0-14","population_0_14")
     .withColumnRenamed("Population 15-64","population_15_64")
     .withColumnRenamed("Population 65+","population_65")
     .withColumnRenamed("Population Total","population_total")
     .withColumnRenamed("Population Urban","population_urban")
     .withColumnRenamed("Tourism Inbound","tourism_inbound")
     .withColumnRenamed("Tourism Outbound","tourism_outbound")
     )



#to check null data in all the column

#null_counts= df.select([count(when(col(column).isNull(),True)).alias(column) for column in df.columns])
null_counts1=df.select( [sum(col(column).isNull().cast("int")).alias(column) for column in df.columns])
null_counts1.show()
#null_counts1.display()

#find outliers
null_dict = null_counts1.first().asDict()
print(null_dict)

'''numeric_cols_with_nulls = [
    col_name
    for col_name, null_count in null_dict.items()
    if null_count > 0
]'''

#Step 3: Pick only numeric columns that have nulls

numeric_cols_with_nulls = [
    field.name
    for field in df.schema.fields
    if isinstance(
        field.dataType,
        (IntegerType, LongType, FloatType, DoubleType, DecimalType, ShortType)
    )
    and null_dict[field.name] > 0
]

print(numeric_cols_with_nulls )

'''
column_int = ["birth_rate","business_tax_rate","co2_emissions","days_to_start_business","ease_of_business","energy_usage","gdp","health_exp_gdp","health_exp_capita","hours_to_do_tax","infant_mortality_rate","internet_usage","lending_interest","life_expectancy_female","life_expectancy_male","mobile_phone_usage","population_0_14","population_15_64","population_65","population_urban","tourism_inbound","tourism_outbound"]'''

def outlier_cal(df,column):
      mean_column = []
      median_column=[]
      for qcolumn in column:
        Q1,Q3 =df.approxQuantile(qcolumn,[0.25,0.75],0)
        IQR = Q3 - Q1
        lower = Q1 - 1.5 * IQR
        upper = Q3 + 1.5 * IQR
        #print(f"outliers in {qcolumn}")
        outlier_df=df.filter( (col(qcolumn) < lower) |(col(qcolumn) > upper))
        outlier_count =outlier_df.count()
        print(f"outliers in {qcolumn} is {outlier_count}")
        if outlier_count==0:
          mean_column.append(qcolumn)
        else:
          median_column.append(qcolumn)
      return mean_column, median_column 
  
Mean, Median = outlier_cal(df, numeric_cols_with_nulls)

print("Use Mean:", Mean)
print("Use Median:", Median)

'''
Mean= ['birth_rate', 'ease_of_business', 'internet_usage', 'population_0_14', 'population_urban']

Median= ['business_tax_rate', 'co2_emissions', 'days_to_start_business', 'energy_usage', 'gdp', 'health_exp_gdp', 'health_exp_capita', 'hours_to_do_tax', 'infant_mortality_rate', 'lending_interest', 'life_expectancy_female', 'life_expectancy_male', 'mobile_phone_usage', 'population_15_64', 'population_65', 'tourism_inbound', 'tourism_outbound']
'''

#fill avg meand values for null rows..
for mean_col in Mean:
    mean_value= df.agg(mean(col(mean_col))).collect()[0][0]
    df=df.fillna({mean_col: mean_value})


# fill median values for null data..
for median_col in Median:
    median_value = df.approxQuantile(median_col,[0.5],0)[0]
    df=df.fillna({median_col:median_value})

#Tocheck whether null is updated
#check nulls

null_counts_after = df.select(
    [sum(col(column).isNull().cast("int")).alias(column) for column in df.columns]
)
null_counts_after.show()

#update date format.change to date from string datatype.

df=df.withColumn("year", to_date(col("year"),"d/M/yyyy"))


#dynamic for all string type in dataframes

for field in df.schema.fields:
    if isinstance(field.dataType,StringType):
      df=df.withColumn(field.name,trim(col(field.name)))


#duplicates checks done

total_rows=df.count()
distinct_rows =df.distinct().count()

print(total_rows,distinct_rows)
print("Duplicate rows:", total_rows - distinct_rows)

df = df.dropDuplicates()
print("Rows after removing duplicates:", df.count())


#check standardize text case (upper/lower/initcap)



df=df.withColumn("country",initcap(col("country")))


#life_expectancy_gap =life_expectancy_female - life_expectancy_male

df_new = (
    df.withColumn(
        "life_expectancy_gap",
        col("life_expectancy_female") - col("life_expectancy_male")
    )
    .withColumn(
        "population_category",
        when(col("population_total") >= 100000000, "Highly Populated")
        .otherwise("Normal")
    )
)


window_spec = Window.partitionBy("region", "year")


df_new= (
    df_new.withColumn(
        "regional_avg_gdp",
        avg("gdp").over(window_spec)
    )
    .filter(col("gdp") > col("regional_avg_gdp"))
)


df_new.printSchema()
df_new.show(5)
print(df_new.count())

