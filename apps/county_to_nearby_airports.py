# -*- coding: utf-8 -*-

from math import radians, cos, sin, asin, sqrt
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, FloatType, IntegerType, StringType
import pyspark.sql.functions as F

print('Creating SparkSession ... ')
spark = SparkSession.builder.appName('Data Mesh Experiments').getOrCreate()
spark.sparkContext.setLogLevel("WARN")

print('Loading counties ... ')
c_schema = StructType() \
    .add("county",StringType(),True) \
    .add("county_ascii",StringType(),True) \
    .add("county_full",StringType(),True) \
    .add("county_fips",StringType(),True) \
    .add("state_id",StringType(),True) \
    .add("state_name",StringType(),True) \
    .add("lat",FloatType(),True) \
    .add("lng",FloatType(),True) \
    .add("population",IntegerType(),True) 
df_counties = spark.read \
    .format('csv') \
    .option("header", True) \
    .schema(c_schema) \
    .load("/opt/spark/data/csv/counties.csv")

print('Summarizing counties ... ')
# df_counties.summary().show()
df_counties.show()

print('Loading airports ... ')
a_schema = StructType() \
    .add("continent",StringType(),True) \
    .add("lng",FloatType(),True) \
    .add("lat",FloatType(),True) \
    .add("elevation_ft",StringType(),True)\
    .add("gps_code",StringType(),True) \
    .add("iata_code",StringType(),True) \
    .add("ident",StringType(),True) \
    .add("iso_country",StringType(),True) \
    .add("iso_region",StringType(),True) \
    .add("local_code",StringType(),True) \
    .add("municipality",StringType(),True) \
    .add("name",StringType(),True)  \
    .add("type",StringType(),True) 
df_airports = spark.read \
    .format('csv') \
    .option("header", True) \
    .schema(a_schema) \
    .load("/opt/spark/data/csv/airports.csv")

print('Filtering airports ... ')    
df_airports = df_airports.filter(df_airports.iso_country == 'US').filter(df_airports.iata_code.isNotNull())

print('Summarizing airports ... ')
# df_airports.summary().show()
df_airports.show()

print('Creating crossjoin ... ')
df_cty = df_counties.select(F.col("county_fips").alias("fips"), F.col("lat").alias("c_lat"), F.col("lng").alias("c_lng"))
df_arp = df_airports.select(F.col("iata_code").alias("iata"), F.col("lat").alias("a_lat"), F.col("lng").alias("a_lng"))
df_cj =  df_cty.crossJoin(df_arp)
df_cj.show()

print('Calculate distances ... ')
df_cj = df_cj \
    .withColumn("a", (
        F.pow(F.sin(F.radians(F.col("a_lat") - F.col("c_lat")) / 2), 2) +
        F.cos(F.radians(F.col("c_lat"))) * F.cos(F.radians(F.col("a_lat"))) *
        F.pow(F.sin(F.radians(F.col("a_lng") - F.col("c_lng")) / 2), 2)
    )).withColumn("distance", F.atan2(F.sqrt(F.col("a")), F.sqrt(-F.col("a") + 1)) * 12742000)
df_cj.show()

print('Limiting distances to 40 miles ... ')
df_cj = df_cj.filter(df_cj.distance < 40000 * 1.6)
# df_cj.summary().show()
df_cj.show()

print('Saving county and near by airports ... ')
with open('/opt/spark/data/csv/ctytoarp.csv', mode='w', encoding='utf-8') as out_file:
    out_file.write('fips,iata,distance\n')
    for row in df_cj.collect():
        out_file.write(f"{row['fips']},{row['iata']},{row['distance']}\n")
print('Done.')
