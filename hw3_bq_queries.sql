
-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `nytaxihw.external_yellow_tripdata`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://tasemgt-kestra-bucket/yellow_tripdata_2024-*.parquet']
);

-- -- Check yello trip data
SELECT * FROM nytaxihw.external_yellow_tripdata limit 10;

-- -- Create materialized table
CREATE TABLE `nytaxihw.materialized_yellow_tripdata` AS
SELECT * FROM `nytaxihw.external_yellow_tripdata`;

-- -- Q1. Count yello trip data
SELECT COUNT(*) FROM nytaxihw.external_yellow_tripdata;

-- Q2a. Count the distinct number of PULocationIDs (External Table)
SELECT COUNT(DISTINCT PULocationID) AS distinctPULocationIDs
FROM `nytaxihw.external_yellow_tripdata`;

-- Q2b. Count the distinct number of PULocationIDs (Regular Table)
SELECT COUNT(DISTINCT PULocationID) AS distinctPULocationIDs
FROM `nytaxihw.materialized_yellow_tripdata`;

-- Q3a. Select PULocationID (Regular Table)
SELECT PULocationID FROM `nytaxihw.materialized_yellow_tripdata`;

-- Q3b. Select PULocationID (Regular Table)
SELECT PULocationID, DOLocationID FROM `nytaxihw.materialized_yellow_tripdata`;

-- Q4. Count where fare_amount = 0?
SELECT COUNT(*) FROM `nytaxihw.external_yellow_tripdata`
WHERE fare_amount = 0;

-- Q5. Creating a partition and cluster table
CREATE OR REPLACE TABLE `nytaxihw.yellow_tripdata_partitoned_clustered`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM `nytaxihw.external_yellow_tripdata`;

--- RUN EXAMPLE QUERY
SELECT * FROM `nytaxihw.yellow_tripdata_partitoned_clustered`
WHERE tpep_dropoff_datetime = '2024-06-28 17:15:30 UTC'
ORDER BY VendorID
LIMIT 100;

-- Q6a. Select the distinct number of PULocationIDs (Regular Table)
SELECT DISTINCT PULocationID FROM `nytaxihw.materialized_yellow_tripdata`
WHERE DATE(tpep_dropoff_datetime) > '2024-03-01' AND DATE(tpep_dropoff_datetime) <= '2024-03-15';

-- Q6b. Select the distinct number of PULocationIDs (Partitioned Table)
SELECT DISTINCT PULocationID FROM `nytaxihw.yellow_tripdata_partitoned_clustered`
WHERE DATE(tpep_dropoff_datetime) > '2024-03-01' AND DATE(tpep_dropoff_datetime) <= '2024-03-15';
