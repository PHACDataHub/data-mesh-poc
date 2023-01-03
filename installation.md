Data Mesh Proof of Concept

# A. Prerequisites

1. Suggested configuration
- Ubuntu 22.04-LTS
- 32 GB RAM (for all clusters)

2. Get this repository

```    
    git clone https://github.com/PHACDataHub/data-mesh-poc.git
```

3. Install Docker Engine

Install docker

```
    ./scripts/docker/install.sh
```

Make sure that it is running
```
    docker system info
```

Test if you can pull and run a `hell-world` image
```
    ./scripts/docker/test.sh
```

# B. Setup Kafka cluster

1. Prepare folders for data, logs, and test files

```    
    ./scripts/kafka/setup.sh
```

2. Start the cluster

```
    ./scripts/kafka/start_after_setup.sh
```

3. Stop the cluster

```
    ./scripts/kafka/stop.sh
```

4. Restart the cluster (once it has already been set up)

```
    ./scripts/kafka/start_again.sh
```

5. Remove the cluster

```
    ./scripts/kafka/cleanup.sh
```

***Note: sometime the `connect` plugins are not propertly installed. You might need to check `connect` logs.***

```
    docker-compose -f docker-compose-kafka.yml logs connect -f
```

scan for 
```
    connect  | Unable to find a component 
    connect  |  
    connect  | Error: Component not found, specify either valid name from Confluent Hub in format: <owner>/<name>:<version:latest> or path to a local file 
```

and then install them manually (for example for the `neo4j` plugin)

```
    docker exec -it connect bash
    confluent-hub install --no-prompt neo4j/kafka-connect-neo4j:5.0.2
```

# C. US Covid Daily dataset, Airports & Counties & Airport-to-Airport Passenger Traffic master datasets

1. Setup the connectors and topics to read csv data files

```
    ./scripts/kafka/setup_spooldir_connectors.sh
```

Check if the data points are there (press Ctrl+C to quit)
```
    ./scripts/kafka/get_topic_info.sh topic_airports
    ./scripts/kafka/get_topic_info.sh topic_counties
    ./scripts/kafka/get_topic_info.sh topic_arttoarp
    ./scripts/kafka/get_topic_info.sh topic_dailyc19
```

2. Reviewing Kafka topics

Navigate to `http://localhost:9021`, select `Topics`, then select any of `topic_airports`, `topic_arptoarp`, `topic_counties`, `topic_daily19`.

Select `Messages`, then on `offset` (next to `Jump to offset`) select `0` to start seeing messages from the beginning (of the messages in the topic).

3. Setting up PostgreSQL and Grafana

```
    ./scripts/postgres/start_first_time.sh
```

4. Adding Kafka Streams

Open Kafka Control Center at `http://localhost:9021`, `ksql`, then use the `Editor` to create streams as follow.

```
    CREATE STREAM stream_dailyc19 (
        date VARCHAR,
        fips VARCHAR,
        county VARCHAR,
        state VARCHAR,
        cases BIGINT,
        deaths BIGINT
    ) WITH (
        KAFKA_TOPIC='topic_dailyc19',
        KEY_FORMAT='AVRO',
        VALUE_FORMAT='AVRO',
        KEY_SCHEMA_ID=3,
        VALUE_SCHEMA_ID=8
    );
```

```
    CREATE STREAM california_covid
    AS SELECT 
        date, fips, county, cases, deaths
    FROM STREAM_DAILYC19
    WHERE state = 'California'
    EMIT CHANGES;

```

5. Setting up JDBC connector to consume Kafka messages from `topic_daily19` and review imported messages in PorgreSQL database

```
    ./scripts/postgres/setup_kafka_connector.sh
```

```
    docker exec -it postgres bash -c 'psql -U $POSTGRES_USER $POSTGRES_DB'
    postgres=# \dt
    postgres=# SELECT * FROM topic_dailyc19 FETCH FIRST 10 ROWS ONLY;
```

6. Configure Grafana to use PostgreSQL instance

Open browser at `http://localhost:3000`, then use `admin/admin` for login first time.

Create a data source by select `Configuration` on the left menu bar, select `PostgreSQL`, then `postgres:5432`, database `postgres`, username/password as `postgres` (for default). Disable TSL for now.

7. Create dashboards in Grafana to view `US Covid Daily` data

Create a new dashboard with a panel to display first 10 rows in the database.. Selecting `PostgreSQL` as the data source, `Table` as view type, switch the Query Builder to `Code` (instead of `Builder`), and type

```
    SELECT NOW() AS time, * FROM topic_dailyc19 LIMIT 10;
```

Design another panel 

```
    SELECT 
    state,
    SUM(cases) AS cases, 
    100 *SUM(cases) / (SELECT SUM(cases) FROM topic_dailyc19 WHERE date = '2020-03-31') AS percent
    FROM topic_dailyc19
    WHERE date = '2020-03-31'
    GROUP BY state
    ORDER BY percent DESC;
```

Then the third panel, choosing Pie Chart

```
    SELECT
        NOW() AS time,
        state AS metric,
        SUM(cases) AS cases, 
        100 *SUM(cases) / (SELECT SUM(cases) FROM topic_dailyc19 WHERE date = '2020-03-31') AS percent
    FROM topic_dailyc19
    WHERE date = '2020-03-31'
    GROUP BY state
    ORDER BY percent DESC;
```

Then the third panel, choosing Pie Chart

```
    SELECT
        SUM(cases) AS cases,
        state as metric
    FROM topic_dailyc19
    WHERE date = '2020-03-31'
    GROUP BY state;
```
'
And the final panel, choosing Bar Gauge

```
    SELECT
        SUM(cases) AS "cases",
        date
    FROM topic_dailyc19
    WHERE state = 'Washington'
    GROUP BY date
    ORDER BY date ASC
    LIMIT 100;
```

The full config can be viewed in [grafana.json](./conf/grafana.json).

# D. Perform computations to find nearby airports for each county

1. Setup a Spark master and three slaves

```
    ./scripts/spark/start_first_time.sh
```

2. Run the Spark app

```
    ./scripts/spark/run_spark_app.sh
```

3. Push the results into the `topic_ctytoarp`

```
    ./scripts/spark/setup_kafka_connector.sh
```

Check if the data points are there (press Ctrl+C to quit)

```
    ./scripts/kafka/get_topic_info.sh topic_ctytoarp
```

# E. Neo4j for data science, access and visualization

1. Setup a Neo4j and neodash

```
    ./scripts/neo4j/start_first_time.sh
```

2. Setup the database

```
    ./scripts/neo4j/setup_database.sh
```

3. Connect to Kafka to receive all data

```
    ./scripts/neo4j/setup_kafka_connector.sh
```

4. Open Neo4j browser

Open browser at `http://localhost:7474`, then use `neo4j/phac2022` for login.

5. Using Neodash

Open browser at `http://localhost:5005`, then connect to existing dashboard for preview.