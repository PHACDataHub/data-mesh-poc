[Prev](./III-a-short-summary-of-data-mesh.md) | [Top](../README.md) | [Next](./V-towards-a-reference-implementation.md)

# IV. The Proof-of-Concept

The PoC is to provide an working system.to illustrate the key points of an possible implementation based on Data Mesh principle with three key subsystems:
- The underlying data streaming infrastructure provided by a Kafka cluster for internal data flows as event streams inside each of the two Data Product instances, see below, as well as external data flows between them.
- A group of software components as an implementation of Data Product principles representing daily COVID report gathering, storing, and monitoring by the State of California and the Federal CDC.
- Another group of software components as another implementation of Data Product principles representing John Hopkins University's data science team collecting master datasets, processing big data, and performing Machine Learning (ML) tasks to find correlations between surges in paris ofcounties connected by air routes.

![The Data Mesh approach](../images/Data%20Mesh%20PoC/Data%20Mesh%20PoC.003.png)

Each of the sections below describes in details the architecture, functions, configurations, installations, and some functional tests of the subsystems. High-level descriptions accompanied by detailed explaination and concrete technical instructions. The technical instructions, although important for readers who want to repeat the deployment of the PoC on their own computers, local servers or (private) cloud, are not relevant for an overview and understanding of the subsystems.

*Note: If you are interested only in the technical installation of the PoC, please refer to the [installation](../installation.md) document*.

## IV.1. System Requirements

Any computer system such as a personal computers (PC), physical servers, virtual machines with at least
- 8-core CPUs
- 32 GB RAM memory
- 64 GB disk storage (preferable SDD)
- Ubuntu 22.04-LTS
- Internet connectivity

## IV.2. Github repository

In software development, multiple team members develop code and contribute to creating the software’s functionality. When multiple people contribute to a code base, it is important to maintain its integrity and ensure that any team member can retrieve the latest version and build and run it locally. Github helps to facilitate a **single source of truth**.

### IV.1.a Install system tools

Make sure that you have the following tools installed on the designated system: `git` (or TBC `GitBash` on Windows), `curl`, and `jq`.

### IV.1.b Obtain the PoC source repository

Open a terminal and run:
```bash
    git clone https://github.com/PHACDataHub/data-mesh-poc.git
```

Make sure that a local copy of the repository is ready, then
```bash
	cd data-mesh-poc
```

### IV.1.c (Optional) Keep the repository up-to-date

Fetch the latest source (TBC fetch/pull)
```bash
	git fetch
```
### IV.1.d. (Optional) Visual Code and SSH access

To ease development on the cloud, a combined use of 
+ [Visual Studio Code](https://code.visualstudio.com);
+ [Remote-SSH extension](https://code.visualstudio.com/docs/remote/ssh);
together with a few terminals and port forwarding settings allow developers to *develop directly on and for the cloud*.

## IV.2. Containerized Deployment

The purpose of containerization - by Docker in this case - is to provide a secure, reliable, and lightweight runtime environment for applications that is consistent from host to host. In contrast, the purpose of serverless technology is to provide a way to build and run applications without having to consider the underlying hosts at all.

[Docker Engine](https://docs.docker.com) is an open source containerization technology for building and containerizing your applications.  Docker Compose is a tool for defining and running multi-container Docker applications. With Compose, we can use a YAML file to configure our application’s services. Then, with a single command, we can create and start all the services from our configuration. Docker Compose works in all environments: production, staging, development, testing, as well as CI workflows. It also has commands for managing the whole lifecycle of your application:
+ Start, stop, and rebuild services
+ View the status of running services
+ Stream the log output of running services
+ Run a one-off command on a service

### IV.2.a Install Docker Engine and Docker Compose

Make sure that you are inside the `data-mesh-poc` folder.

To install Docker Engine and Docker Compose, run
```bash
    ./scripts/docker/install.sh
```

Make sure that Docker Engine is running
```bash
    docker system info
```

Test if you can pull and run a `hell-world` Docker image
```bash
    ./scripts/docker/test.sh
```

### IV.2.b (Optional) Cleanup Docker

In case if you need to cleanup previously Docker images, volumes, networks, containers, and folders

```bash
    ./scripts/docker/cleanup.sh
```

### VI.2.c (Optional) Uninstall Docker

In case if you don't want Docker Engine and Docker Compose on your system any more.

```bash
    ./scripts/docker/uninstall.sh
```

Of course, you can reinstall Docker Engine and Docker Compose by running.
```bash
    ./scripts/docker/install.sh
```
*Note: do not install Docker over an existing installation, removing Docker where there is no installation, and other similar cases.*

## IV.3. The Streaming Infrastructure

An event stream is an unbounded sequence of events. An event captures that something has happened. For example, it could be a customer buying a car, a plane landing, or a sensor triggering. In real life, events happen constantly and, in most industries, businesses are reacting to these events in real time to make decisions. So event streams are a great abstraction as new events are added to the stream as they happen. Event streaming systems provide mechanisms to process and distribute events in real time and store them durably so they can be replayed later.

Kafka is an open source project with an open governance under the Apache foundation. It is distributed, scalable, and able to handle very high throughput with high availability. It provides low latency and unique characteristics make it ideal for handling streams of events. Finally the various components of the project create a robust and flexible platform to build data systems.

### IV.3.a The Kafka Cluster

![The Kafka Cluster](../images/Data%20Mesh%20PoC/Data%20Mesh%20PoC.004.png)

A Kafka Cluster usually consists of:
- Brokers form a Kafka cluster and handle requests for Kafka clients.
- Producers send data to Kafka brokers.
- Consumers receive data from Kafka brokers.
- KSQL provides stream processing (aggregate, transform, filter) capabilities.
- Connectors to enable building data pipelines between Kafka and external systems.

1. Prepare folders for data, logs, and test files

```bash
    ./scripts/kafka/setup.sh
```

2. Start the cluster

```bash
    ./scripts/kafka/start_after_setup.sh
```

![The Kafka Docker Set](../images/docker-diagrams/docker-compose-kafka.png)

### IV.3.b (Optional) Other utilities

1. Stop the cluster

```bash
    ./scripts/kafka/stop.sh
```

2. Restart the cluster (once it has already been set up)

```bash
    ./scripts/kafka/start_again.sh
```

3. Remove the cluster

```bash
    ./scripts/kafka/cleanup.sh
```

***Note: at the first time the `connect` plugins are not propertly installed. You might need to check `connect` logs.***

```bash
    docker-compose -f docker-compose-kafka.yml logs connect -f
```

scan for 
```bash
    connect  | Unable to find a component 
    connect  |  
    connect  | Error: Component not found, specify either valid name from Confluent Hub in format: <owner>/<name>:<version:latest> or path to a local file 
```

and then install them manually (for example for the `neo4j` plugin)

```bash
    docker exec -it connect bash
    confluent-hub install --no-prompt neo4j/kafka-connect-neo4j:5.0.2
```

## IV.4. The Daily Reports

![Daily Data](../images/Data%20Mesh%20PoC/Data%20Mesh%20PoC.005.png)

The Kafka Publish/Subscribe (PubSub) model:
- simplify the topology of applications exchanging information with each other: instead of a $n \times n$ matrix, its a $n \times 1$ (applications-to-Kafka) and $1 \times n$ (Kafka-to-applications)
- makes it easy to add or remove applications that want to exchange without affecting any of the others.

Although there are many other technologies that use PubSub, very few provide a durable PubSub system. Unlike other messaging systems, Kafka does not remove data once it has been received by a particular consumer. Other systems have to make copies of the data so that multiple applications can read it, and the same application cannot read the same data twice.

A Kafka record is made up of a `key`, a `value`, a `timestamp` and some `headers`:
- The record `key` is optional and is often used to logically group records and can inform routing;
- The `headers` are also optional. They are a map of key/value pairs that can be used to send additional information alongside the data.
- The `timestamp` is always present on a record, but it can be set in two different ways. Either the application sending the record can set the timestamp, or the Kafka runtime can add the timestamp when it receives the record

Kafka doesn’t store one single stream of data, it stores multiple streams and each one is called a `topic`. When applications send records to Kafka they can decide which topic to send them to. To receive data, applications can choose one or more topics to consume records from. It uses `partitions` to handle a high volume of data by spreading the workload across the different brokers. A partition is a subset of a particular topic. Kafka will guarantee that the records are placed onto the partition in the `order` that it received them.

Kafka can maintain copies or `replicas` of partitions on a configurable number of brokers. This is useful because if one of the brokers goes down, the data in partitions on that broker isn’t lost or unavailable. Applications can continue sending and receiving data to that partition, they just have to connect to a different broker. Kafka client can determine which partition to add your record to using a `partitioner`.

Kafka supports
- **exactly once semantics** via the idempotent and transactional producers;
- **at least once** or **at most once delivery semantics** by configuring producers;

### IV.4.a SpoolDir Connectors

Connectors are plugins we can add to a Kafka Connect runtime. They serve as the interface between external systems and the Connect runtime and encapsulate all the external system specific logic. There are two types of connectors:
- Sink connectors: To export records from Kafka to external systems
- Source connectors: To import records from external systems into Kafka

The Kafka community has implemented connectors for hundreds of popular technologies ranging from messaging systems, to databases, to storage and data warehouse systems. To find connectors for your use case, you can use repositories like [Confluent Hub](https://www.confluent.io/hub/) or the [Event Streams connector catalog](https://ibm.github.io/event-streams/connectors/) that reference the most used and tested connectors.

Now we process US Covid Daily dataset, Airports & Counties & Airport-to-Airport Passenger Traffic master datasets by sending each data point as a record in into various Kafka topics

***Note that please ensure that `jq` is installed.*** Use `sudo apt install jq` on Ubuntu and `brew install jq` on Mac OS.

Setup the connectors and topics to read csv data files

```bash
    ./scripts/kafka/setup_spooldir_connectors.sh
```

This scripts creates four connectors `spooldir_counties`, `spooldir_airports`, `spooldir_arptoarp`, and `spooldir_dailyc19`. Each connector is created by execute a command via REST endpoint of Kafka `connect`:

This is a part of above the script:
```bash
    curl -i -X PUT -H "Accept:application/json" \
        -H  "Content-Type:application/json" http://${connect}/connectors/spooldir_${item}/config \
        -d '{
            "connector.class":"com.github.jcustenborder.kafka.connect.spooldir.SpoolDirCsvSourceConnector",
            "topic":"topic_'${item}'",
            "input.path":"/data/unprocessed",
            "finished.path":"/data/processed",
            "error.path":"/data/error",
            "input.file.pattern":"'${item}'\\.csv",
            "schema.generation.enabled":"true",
            "schema.generation.key.fields":"'${key_fields}'",
            "csv.first.row.as.header":"true",
            "transforms":"castTypes",
            "transforms.castTypes.type":"org.apache.kafka.connect.transforms.Cast$Value",
            "transforms.castTypes.spec":"'${cast_types}'"
            }'
```

The input `csv` files for each connector can be uploaded into `/data/unprocessed` with a prefix `counties`, `airports`, `arptoarp`, or `dailyc19` as specified in `"input.file.pattern":"'${item}'\\.csv"`.

Note that there is a single connector for each topic, but there is *no limit on the number of csv files can be uploaded to the folder, which effectively provides a method of **aggregation** for multiple sources.

The *schema for data in each connector is generated directly from the data* by specifying `"schema.generation.enabled":"true"`. We add some instructions 
- identify the key for the record: `key_fields_airports=ident`;
- or to transform some of the fields (from string to float data type): `cast_types_airports=lat:float32,lng:float32`

The list of created `spooldir connector`s can easily be seen by using:
```bash
    curl -s localhost:8083/connectors | jq '.[]'
```

We should see something as below
```bash
    "spooldir_counties"
    "spooldir_arptoarp"
    "spooldir_dailyc19"
    "spooldir_airports"
```

On an Ubuntu-based deployment, the list of created `topic`s can also be seen by using:
```bash
    docker exec kafkacat kafkacat -b broker:29092 -q -L  -J | jq '.topics[].topic' | sort
```

(Optional) for Mac OS deployment, after install `kafkakat` by `brew`, we can use:
```bash
    kcat -b localhost:9092 -q -L  -J | jq '.topics[].topic' | sort
```

We should see something as below
```bash
    ...
    "topic_airports"
    "topic_arptoarp"
    "topic_counties"
    "topic_dailyc19"
    ...
```

### IV.4.b (Optional) Using command-line scripts to check if the data points are sent to the topics

To check if the data points are there for the `US daily covid 19` dataset (press Ctrl+C to quit):
```bash
    ./scripts/kafka/get_topic_info.sh topic_dailyc19
```

We should see:
```bash
{
  "key": "\u0000\u0000\u0000\u0000\u0003\u0002\u00142020-12-05\u0002\n56045",
  "payload": {
    "date": {
      "string": "2020-12-05"
    },
    "county": {
      "string": "Weston"
    },
    "state": {
      "string": "Wyoming"
    },
    "fips": {
      "string": "56045"
    },
    "cases": {
      "int": 419
    },
    "deaths": {
      "int": 2
    }
  }
}
% Reached end of topic topic_dailyc19 [0] at offset 793550
```

To check if the data points are there for the `airport` dataset (press Ctrl+C to quit)
```bash
    ./scripts/kafka/get_topic_info.sh topic_airports
```

To check if the data points are there for the `county` dataset (press Ctrl+C to quit)
```bash
    ./scripts/kafka/get_topic_info.sh topic_counties
```

To check if the data points are there for the `airport-to-airport` dataset (press Ctrl+C to quit)
```bash
    ./scripts/kafka/get_topic_info.sh topic_arttoarp
```

### IV.4.c Control Center

We use `Confluent Control Center` to have a better view on the current status of the brokers, topics, messages, etc.
- If the Kafka cluster is deployed on the local machine, navigate to `http://localhost:9021`, select `Topics`.
- If it is deployed on the cloud, use `Remote-SSH Extension` on `Visual Studio Code`, forward the port `9021`, then right-click on the line to open a browser instance to that forwarded port.

![Forwarded Control Center](../images/screen-captured/vscode-control-center.png)

We will first see the `Control Center` screen.

![Control Center](../images/screen-captured/control-center.png)

Lets click on the `Cluster overview` link (menu item) on the left to see the cluster's overview.

![Cluster's overview](../images/screen-captured/control-center-cluster-overview.png)

Lets click on the `Brokers` link (menu item) on the left to see the brokers' overview.

![Brokers' overview](../images/screen-captured/control-center-broker-overview.png)

Lets click on the `Topics` link (menu item) on the left to see the topic list.

![Topic list](../images/screen-captured/control-center-topic-list.png)

Now, lets click on `topic_airports`, we should see the `topic_airports` topic information:

![Topic overview](../images/screen-captured/control-center-topic-overview.png)

Select the `Messages` tab then click on the `offset` (next to `Jump to offset`), enter `0`, then we should be able to see messages from the topic.

![Topic messages](../images/screen-captured/control-center-topic-messages.png)

Select the `Schema` tab then click on the `Key` then we should be able to see the schema for the key, which in this case consists only of the `ident` field.

![Topic key schema](../images/screen-captured/control-center-topic-key-schema.png)

Select the `Schema` tab then click on the `Value` then we should be able to see the schema for the value, which in this case consists all the fields.

![Topic value schema](../images/screen-captured/control-center-topic-value-schema.png)

Finally select the `Configuration` tab to see the topic configuration,

![Topic config](../images/screen-captured/control-center-topic-config.png)

### IV.4.d Event streams

Streams applications process data on client-side, so we don’t need to deploy a separate processing engine. Being a key component of the Kafka project, it takes full advantage of Kafka topics to store intermediate data during complex processes. Streams applications follow the read-process-write pattern. One or more Kafka topics are used as the stream input. As it receives the stream from Kafka, the application applies some processing and emits results in real time to output topics.

Stream processing can easily be performed by using `ksqldb` functionalities of Kafka `Control Center` from the browser.

![ksqldb](../images/screen-captured/ksqldb.png)

We use stream processing capability of Kafka by first to find the value the `KEY_SCHEMA_ID` of the `topic_dailyc19` by clicking on `Topics`, `topic_dailyc19`, `Schema`, then `Key`,

![Find key schema id](../images/screen-captured/ksqldb-find-schema-id.png)

then, to `create a stream`  called `stream_dailyc19` from the `topic_dailyc19` records', basically turning any topic into a stream;

```SQL
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
        KEY_SCHEMA_ID=3
    );
```

![Create stream from topic](../images/screen-captured/ksqldb-create-stream.png)

and finally, to perform (aggregation/transformation/)filtering only the messages to provide California-only daily reports and turn it into a topic `CALIFORNIA_COVID`.

```SQL
    CREATE STREAM california_covid
    AS SELECT 
        ROWKEY, date, fips, county, cases, deaths
    FROM STREAM_DAILYC19
    WHERE state = 'California'
    EMIT CHANGES;
```

![Filter stream and create topic from stream](../images/screen-captured/ksqldb-create-stream.png)

## IV.5 Monitoring the reports

![Monitoring Reports](../images/Data%20Mesh%20PoC/Data%20Mesh%20PoC.006.png)

### IV.5.a PostgreSQL and Grafana

PostgreSQL, also known as Postgres, is a free and open-source relational database management system emphasizing extensibility and SQL compliance. It was originally named POSTGRES, referring to its origins as a successor to the Ingres database developed at the University of California, Berkeley. 

Grafana is a multi-platform open source analytics and interactive visualization web application. It provides charts, graphs, and alerts for the web when connected to supported data sources. 

Now, the monitoring component contains only a PostgeSQL database and a Grafana visualization software, both run as Docker containers, configured in `docker-compose-postgres.yml` and easily be ran by:

```bash
    ./scripts/postgres/start_first_time.sh
```

![The Postgres Docker Set](../images/docker-diagrams/docker-compose-postgres.png)

### IV.5.b JDBC Connectors

The daily reports as Kafka records flow from `topic_dailyc19` and `CALIFORNIA_COVID` topic into the database via two connectors, one for each topic. They can be configured in a similar manner via REST endpoints of Kafka `connect`:

```bash
    ./scripts/postgres/setup_kafka_connector.sh
```

This is a part of above the script:
```bash
    curl -X PUT http://${connect}/connectors/sink-postgres/config \
        -H "Content-Type: application/json" \
        -d '{
            "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
            "connection.url": "jdbc:postgresql://'${postgres}'/",
            "connection.user": "postgres",
            "connection.password": "postgres",
            "tasks.max": "1",
            "topics": "'${topic_name}'",
            "auto.create": "true",
            "auto.evolve":"true",
            "pk.mode":"record_value",
            "pk.fields":"'${composite_keys}'",
            "insert.mode": "upsert",
            "table.name.format":"'${topic_name}'"
        }'
```

Note that we can define composite key (a key as a comnbination of multiple data fields) as `composite_keys=date,fips`.

To see if the connectors are successfully created:
```bash
    curl -s "http://localhost:8083/connectors?expand=info&expand=status" | \
        jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state, .value.status.tasks[].state, .value.info.config."connector.class" ] | join (":|:")' | \
        column -s : -t | sed 's/\"//g' |sort
```

We should see something similar to
```bash
    sink    |  sink-california-covid   |  RUNNING  |  RUNNING  |  io.confluent.connect.jdbc.JdbcSinkConnector
    sink    |  sink-postgres           |  RUNNING  |  RUNNING  |  io.confluent.connect.jdbc.JdbcSinkConnector
    source  |  spooldir_airports       |  RUNNING  |  RUNNING  |  com.github.jcustenborder.kafka.connect.spooldir.SpoolDirCsvSourceConnector
    source  |  spooldir_arptoarp       |  RUNNING  |  RUNNING  |  com.github.jcustenborder.kafka.connect.spooldir.SpoolDirCsvSourceConnector
    source  |  spooldir_counties       |  RUNNING  |  RUNNING  |  com.github.jcustenborder.kafka.connect.spooldir.SpoolDirCsvSourceConnector
    source  |  spooldir_ctytoarp       |  RUNNING  |  RUNNING  |  com.github.jcustenborder.kafka.connect.spooldir.SpoolDirCsvSourceConnector
    source  |  spooldir_dailyc19       |  RUNNING  |  RUNNING  |  com.github.jcustenborder.kafka.connect.spooldir.SpoolDirCsvSourceConnector
```

Once created, the records will automatically populate the PostgreSQL database without any manual intervention.

### IV.5.c (Optional) Verify if the database is populated

```bash
    docker exec -it postgres bash -c 'psql -U $POSTGRES_USER $POSTGRES_DB'

    psql (12.13 (Debian 12.13-1.pgdg110+1))
    Type "help" for help.

    postgres=#     
```

then inside PosgreSQL command line prompt:
```postgres
    postgres=# \dt
                List of relations
    Schema |       Name       | Type  |  Owner   
    --------+------------------+-------+----------
    public | CALIFORNIA_COVID | table | postgres
    public | topic_dailyc19   | table | postgres
    (2 rows)

    postgres=# 
```

```postgres
    postgres=# SELECT * FROM topic_dailyc19 FETCH FIRST 10 ROWS ONLY;
        date    |   county    |   state    | fips  | cases | deaths 
    ------------+-------------+------------+-------+-------+--------
    2020-01-22 | Snohomish   | Washington | 53061 |     1 |      0
    2020-01-23 | Snohomish   | Washington | 53061 |     1 |      0
    2020-01-24 | Cook        | Illinois   | 17031 |     1 |      0
    2020-01-24 | Snohomish   | Washington | 53061 |     1 |      0
    2020-01-25 | Orange      | California | 06059 |     1 |      0
    2020-01-25 | Cook        | Illinois   | 17031 |     1 |      0
    2020-01-25 | Snohomish   | Washington | 53061 |     1 |      0
    2020-01-26 | Maricopa    | Arizona    | 04013 |     1 |      0
    2020-01-26 | Los Angeles | California | 06037 |     1 |      0
    2020-01-26 | Orange      | California | 06059 |     1 |      0
    (10 rows)
```

```postgres
    postgres=# SELECT * FROM "CALIFORNIA_COVID" FETCH FIRST 10 ROWS ONLY;
        DATE    | FIPS  |   COUNTY    | CASES | DEATHS 
    ------------+-------+-------------+-------+--------
    2020-01-25 | 06059 | Orange      |     1 |      0
    2020-01-26 | 06037 | Los Angeles |     1 |      0
    2020-01-26 | 06059 | Orange      |     1 |      0
    2020-01-27 | 06037 | Los Angeles |     1 |      0
    2020-01-27 | 06059 | Orange      |     1 |      0
    2020-01-28 | 06037 | Los Angeles |     1 |      0
    2020-01-28 | 06059 | Orange      |     1 |      0
    2020-01-29 | 06037 | Los Angeles |     1 |      0
    2020-01-29 | 06059 | Orange      |     1 |      0
    2020-01-30 | 06037 | Los Angeles |     1 |      0
    (10 rows)
```

To exit:
```postgres
    postgres=# \q
```

### IV.5.d Grafana visualizations

First we need to access Grafana by
- open a browser at `localhost:3000`, if the cluster is deployed on your local machine, or
- forward the port `3000` on your `Visual Studio Code` (similar to the way to access Kafka `Control Center` in the previous part), and then open the browser.

Type `admin` for both username and password for the first login, then set the password for later use.

Navigate to the configuration (click on the cog at the top at the bottom menu on the left), then select `PostgreSQL` for the data source. Use `postgres:5432` for `Host`, `postgres` for all `Database`, `User`, and `Password`. Select ``disable` for `TLS/SSL Mode` for now. `Save & test` the connection.

![Setup Postgres for Grafana](../images/screen-captured/grafana-postgres.png)

Once done, click on the `Dashboard` (four squares) to create dashboards. There are several ways to create them. 

One way to visualize data is to create an empty dashboard, then an empty panel, then select `PostgreSQL` as data source, add the `SQL` queries, then customize the look-and-feel.

First, we need to create a new dashboard by navigating to the left menu, select the `>` arrow to unfold the menu, then `+ New dashboard` menu item.

<img src="../images/screen-captured/grafana-new-dashboard.png" alt="Grafana new dashboard" width="640"/>

Click on `Add a new panel`.

<img src="../images/screen-captured/grafana-new-panel.png" alt="Grafana new panel" width="640"/>

Switch to `Code` mode to enter query,

![Grafana new panel](../images/screen-captured/grafana-panel-code.png)

then type

```SQL
    SELECT 
        TO_TIMESTAMP("DATE", 'YYYY-MM-DD') AS time , 
        "CASES" as metric
    FROM "CALIFORNIA_COVID" 
    WHERE "COUNTY" = 'Los Angeles'
```

click on `Run Query`, then select `Time series` as panel type (top on the right option panel), on `Panel options`, give it a `Title` *Los Angeles County cases*, and a `Description` *Surges in Los Angeles County over the year 2020.*

![Grafana panel design](../images/screen-captured/grafana-panel-design.png)

Click on the top-right button `Apply` to apply the design. Now you should see the whole panel.

![Grafana panel design](../images/screen-captured/grafana-first-panel.png)

To save time, previously design dashboards can be easily imported and by select `Import` on `Dashboards` and then copy the content of [grafana_us.json](../conf/grafana_us.json) or  [grafana_california.json](../conf/grafana_california.json) into  the `Import via panel json` textbox and `Load` it. 

![Import dashboard for Grafana](../images/screen-captured/grafana-import-json.png)

Once done, we will need to go into each of the panel of the newly imported dashboard and select the current PostgreSQL instance for the dashboard.

![Update source for Grafana](../images/screen-captured/grafana-update-source.png)

If done without any problems, we should be able to see both monitoring dashboard for the Federal CDC

![Grafana dashboard for Federal CDC](../images/screen-captured/grafana-federal-cdc.png)

and one for California State

![Grafana dashboard for California State](../images/screen-captured/grafana-california.png)

### IV.5.e Power BI Desktop visualizations

If you can install a Power BI Desktop version,

<img src="../images/screen-captured/power-bi-installation.png" alt="Power BI Desktop Installation" width="640"/>

then you can setup a connection to the PostgreSQL database and use Power BI Desktop in a similar way (as Grafana) by first choosing the Database Type

<img src="../images/screen-captured/postgres-server.png" alt="Choosing PostgreSQL Database as source" width="640"/>

then the connectivity to access it

<img src="../images/screen-captured/postgres-server-2.png" alt="Connectivity to PostgreSQL" width="640"/>

then the login to it

<img src="../images/screen-captured/postgres-login.png" alt="Login into PostgreSQL" width="640"/>

then selecting the proper data source (`California Covid`),

![Power BI for California Covid](../images/screen-captured/power-bi-california-covid.png)

Finally work on the dashboard,

![California Covid dashboard by Power BI](../images/screen-captured/power-bi-dashboard.png)

### IV.5.f (Optional) Stop, restart, and cleanup

1. Stop the cluster

```bash
    ./scripts/postgres/stop.sh
```

2. Restart the cluster (once it has already been set up)

```bash
    ./scripts/postgres/start_again.sh
```

3. Remove the cluster

```bash
    ./scripts/postgres/cleanup.sh
```

## IV.5. The Search for Correlations

### IV.5.a Big data processing by Spark

![Bid Data Processing](../images/Data%20Mesh%20PoC/Data%20Mesh%20PoC.007.png)

Apache Spark is an open-source unified analytics engine for large-scale data processing. Spark provides an interface for programming clusters with implicit data parallelism and fault tolerance.

To perform computations to find nearby airports for each county, se setup a Spark cluster

1. Setup a Spark master and three slaves

```bash
    ./scripts/spark/start_first_time.sh
```

![The Spark Docker Set](../images/docker-diagrams/docker-compose-spark.png)

2. Run the Spark app

```bash
    ./scripts/spark/run_spark_app.sh
```

```bash
Loading counties ... 
Showing counties ... 
+--------------+--------------+--------------------+-----------+--------+----------+-------+---------+----------+
|        county|  county_ascii|         county_full|county_fips|state_id|state_name|    lat|      lng|population|
+--------------+--------------+--------------------+-----------+--------+----------+-------+---------+----------+
|   Los Angeles|   Los Angeles|  Los Angeles County|      06037|      CA|California|34.3209|-118.2247|  10040682|
|          Cook|          Cook|         Cook County|      17031|      IL|  Illinois|41.8401| -87.8168|   5169517|
|        Harris|        Harris|       Harris County|      48201|      TX|     Texas|29.8578| -95.3936|   4680609|
|      Maricopa|      Maricopa|     Maricopa County|      04013|      AZ|   Arizona| 33.349|-112.4915|   4412779|
|     San Diego|     San Diego|    San Diego County|      06073|      CA|California|33.0343| -116.735|   3323970|
|        Orange|        Orange|       Orange County|      06059|      CA|California|33.7031|-117.7609|   3170345|
|    Miami-Dade|    Miami-Dade|   Miami-Dade County|      12086|      FL|   Florida|25.6149| -80.5623|   2705528|
|        Dallas|        Dallas|       Dallas County|      48113|      TX|     Texas|32.7666| -96.7778|   2622634|
|         Kings|         Kings|        Kings County|      36047|      NY|  New York|40.6395| -73.9385|   2576771|
|     Riverside|     Riverside|    Riverside County|      06065|      CA|California|33.7437|-115.9938|   2437864|
|        Queens|        Queens|       Queens County|      36081|      NY|  New York|40.7023| -73.8203|   2270976|
|         Clark|         Clark|        Clark County|      32003|      NV|    Nevada|36.2152|-115.0135|   2228866|
|          King|          King|         King County|      53033|      WA|Washington|47.4902|-121.8052|   2225064|
|San Bernardino|San Bernardino|San Bernardino Co...|      06071|      CA|California|34.8414|-116.1785|   2162532|
|       Tarrant|       Tarrant|      Tarrant County|      48439|      TX|     Texas|32.7719| -97.2911|   2077153|
|         Bexar|         Bexar|        Bexar County|      48029|      TX|     Texas|29.4489|   -98.52|   1978826|
|       Broward|       Broward|      Broward County|      12011|      FL|   Florida|26.1523| -80.4871|   1942273|
|   Santa Clara|   Santa Clara|  Santa Clara County|      06085|      CA|California|37.2318|-121.6951|   1924379|
|         Wayne|         Wayne|        Wayne County|      26163|      MI|  Michigan|42.2819| -83.2822|   1753059|
|       Alameda|       Alameda|      Alameda County|      06001|      CA|California|37.6469|-121.8888|   1661584|
+--------------+--------------+--------------------+-----------+--------+----------+-------+---------+----------+
only showing top 20 rows

Loading airports ... 
Filtering airports ... 
Showing airports ... 
+---------+-----------+---------+------------+--------+---------+-----+-----------+----------+----------+---------------+--------------------+-------------+
|continent|        lng|      lat|elevation_ft|gps_code|iata_code|ident|iso_country|iso_region|local_code|   municipality|                name|         type|
+---------+-----------+---------+------------+--------+---------+-----+-----------+----------+----------+---------------+--------------------+-------------+
|       NA|   -80.2748|  25.3254|           8|    07FA|      OCA| 07FA|         US|     US-FL|      07FA|      Key Largo|Ocean Reef Club A...|small_airport|
|       NA|     -162.9|  61.9346|         305|    null|      PQS|  0AK|         US|     US-AK|       0AK|  Pilot Station|Pilot Station Air...|small_airport|
|       NA|-106.928345|38.851917|        8980|    0CO2|      CSE| 0CO2|         US|     US-CO|      0CO2|  Crested Butte|Crested Butte Air...|small_airport|
|       NA|   -98.6225|  30.2518|        1515|    0TE7|      JCY| 0TE7|         US|     US-TX|      0TE7|   Johnson City|   LBJ Ranch Airport|small_airport|
|       NA|   -72.3114|  42.2233|         418|    13MA|      PMX| 13MA|         US|     US-MA|      13MA|         Palmer|Metropolitan Airport|small_airport|
|       NA|   -131.637|  55.6013|           0|     13Z|      WLR|  13Z|         US|     US-AK|       13Z|         Loring|Loring Seaplane Base|seaplane_base|
|       NA| -162.44046| 60.90559|          12|    PPIT|      NUP|  16A|         US|     US-AK|       16A|    Nunapitchuk| Nunapitchuk Airport|small_airport|
|       NA|   -133.597|   55.803|           0|     16K|      PTC|  16K|         US|     US-AK|       16K|     Port Alice|Port Alice Seapla...|seaplane_base|
|       NA|   -141.662|   59.969|          50|    19AK|      ICY| 19AK|         US|     US-AK|      19AK|        Icy Bay|     Icy Bay Airport|small_airport|
|       NA|    -133.61|  56.3288|           0|     19P|      PPV|  19P|         US|     US-AK|       19P|Port Protection|Port Protection S...|seaplane_base|
|       NA| -156.82039|64.416626|        1598|     1KC|      KKK|  1KC|         US|     US-AK|       1KC|Kalakaket Creek|Kalakaket Creek A...|small_airport|
|       NA|   -122.272|  41.2632|        3258|    KMHS|      MHS|  1O6|         US|     US-CA|       1O6|       Dunsmuir|Dunsmuir Muni-Mot...|small_airport|
|       NA|  -97.66192|28.362444|         190|    null|      NIR| 1XA2|         US|     US-TX|       TX2|       Beeville|Chase Field Indus...|small_airport|
|       NA|-113.231155|36.258614|        4100|    null|      GCT|  1Z1|         US|     US-AZ|       1Z1|       Whitmore|Grand Canyon Bar ...|small_airport|
|       NA| -146.70404|60.893818|           0|    null|      ELW|  1Z9|         US|     US-AK|       1Z9|        Ellamar|Ellamar Seaplane ...|seaplane_base|
|       NA|    -155.44|  61.3591|         552|     2AK|      LVD|  2AK|         US|     US-AK|       2AK|   Lime Village|Lime Village Airport|small_airport|
|       NA|   -155.669|  66.2161|         534|    2AK6|      HGZ| 2AK6|         US|     US-AK|      2AK6|        Hogatza|   Hog River Airport|small_airport|
|       NA|   -87.4997|  38.8514|         426|     I20|      OTN| 2IG4|         US|     US-IN|       I20|        Oaktown|      Ed-Air Airport|small_airport|
|       NA|   -153.269|  63.3939|         650|     2K5|      TLF|  2K5|         US|     US-AK|       2K5|         Telida|      Telida Airport|small_airport|
|       NA|   -95.5797|  28.9822|          15|    2TE0|      BZT| 2TE0|         US|     US-TX|      2TE0|       Brazoria|      Eagle Air Park|small_airport|
+---------+-----------+---------+------------+--------+---------+-----+-----------+----------+----------+---------------+--------------------+-------------+
only showing top 20 rows

Creating crossjoin ... 
+-----+-------+---------+----+-------+--------+
| fips|  c_lat|    c_lng|iata|  a_lat|   a_lng|
+-----+-------+---------+----+-------+--------+
|06037|34.3209|-118.2247| OCA|25.3254|-80.2748|
|17031|41.8401| -87.8168| OCA|25.3254|-80.2748|
|48201|29.8578| -95.3936| OCA|25.3254|-80.2748|
|04013| 33.349|-112.4915| OCA|25.3254|-80.2748|
|06073|33.0343| -116.735| OCA|25.3254|-80.2748|
|06059|33.7031|-117.7609| OCA|25.3254|-80.2748|
|12086|25.6149| -80.5623| OCA|25.3254|-80.2748|
|48113|32.7666| -96.7778| OCA|25.3254|-80.2748|
|36047|40.6395| -73.9385| OCA|25.3254|-80.2748|
|06065|33.7437|-115.9938| OCA|25.3254|-80.2748|
|36081|40.7023| -73.8203| OCA|25.3254|-80.2748|
|32003|36.2152|-115.0135| OCA|25.3254|-80.2748|
|53033|47.4902|-121.8052| OCA|25.3254|-80.2748|
|06071|34.8414|-116.1785| OCA|25.3254|-80.2748|
|48439|32.7719| -97.2911| OCA|25.3254|-80.2748|
|48029|29.4489|   -98.52| OCA|25.3254|-80.2748|
|12011|26.1523| -80.4871| OCA|25.3254|-80.2748|
|06085|37.2318|-121.6951| OCA|25.3254|-80.2748|
|26163|42.2819| -83.2822| OCA|25.3254|-80.2748|
|06001|37.6469|-121.8888| OCA|25.3254|-80.2748|
+-----+-------+---------+----+-------+--------+
only showing top 20 rows

Calculate distances ... 
+-----+-------+---------+----+-------+--------+--------------------+------------------+
| fips|  c_lat|    c_lng|iata|  a_lat|   a_lng|                   a|          distance|
+-----+-------+---------+----+-------+--------+--------------------+------------------+
|06037|34.3209|-118.2247| OCA|25.3254|-80.2748| 0.08507581181020094|3771379.8973415224|
|17031|41.8401| -87.8168| OCA|25.3254|-80.2748| 0.02353944033163009|1962702.1969749152|
|48201|29.8578| -95.3936| OCA|25.3254|-80.2748|0.015130352228900412|1571315.5859158405|
|04013| 33.349|-112.4915| OCA|25.3254|-80.2748| 0.06301967976259198| 3233303.234682059|
|06073|33.0343| -116.735| OCA|25.3254|-80.2748| 0.07867837378687664| 3622697.105266685|
|06059|33.7031|-117.7609| OCA|25.3254|-80.2748| 0.08297600449285199| 3723157.713276724|
|12086|25.6149| -80.5623| OCA|25.3254|-80.2748|1.151298378889396...| 43234.69311607899|
|48113|32.7666| -96.7778| OCA|25.3254|-80.2748|0.019866397250171502|1801962.4103455562|
|36047|40.6395| -73.9385| OCA|25.3254|-80.2748|0.019848761135084082|1801157.0267206228|
|06065|33.7437|-115.9938| OCA|25.3254|-80.2748| 0.07608030418714773| 3560746.030648261|
|36081|40.7023| -73.8203| OCA|25.3254|-80.2748|0.020070557445618024|1811260.3683528423|
|32003|36.2152|-115.0135| OCA|25.3254|-80.2748| 0.07399605630246278|3510342.1588307596|
|53033|47.4902|-121.8052| OCA|25.3254|-80.2748| 0.11372193053193944|4382860.7762210155|
|06071|34.8414|-116.1785| OCA|25.3254|-80.2748| 0.07735536162972613|3591268.9125193553|
|48439|32.7719| -97.2911| OCA|25.3254|-80.2748|0.020853143007784188|1846479.2771022911|
|48029|29.4489|   -98.52| OCA|25.3254|-80.2748|0.021080012381522035|  1856567.68216607|
|12011|26.1523| -80.4871| OCA|25.3254|-80.2748|5.485549648022722E-5| 94373.84432793199|
|06085|37.2318|-121.6951| OCA|25.3254|-80.2748| 0.10076067220674248| 4115872.508645151|
|26163|42.2819| -83.2822| OCA|25.3254|-80.2748|0.022197275813378967|1905493.0609944456|
|06001|37.6469|-121.8888| OCA|25.3254|-80.2748|   0.101824891863125| 4138344.518741266|
+-----+-------+---------+----+-------+--------+--------------------+------------------+
only showing top 20 rows

Limiting distances to 40 miles ... 
+-----+-------+---------+----+---------+-----------+--------------------+------------------+
| fips|  c_lat|    c_lng|iata|    a_lat|      a_lng|                   a|          distance|
+-----+-------+---------+----+---------+-----------+--------------------+------------------+
|12086|25.6149| -80.5623| OCA|  25.3254|   -80.2748|1.151298378889396...| 43234.69311607899|
|02158| 62.155|-163.3826| PQS|  61.9346|     -162.9|7.596913893372199E-6|35120.181576660434|
|08097|39.2171|-106.9166| CSE|38.851917|-106.928345|1.016202731813934E-5| 40618.93341142659|
|08051|38.6668|-107.0317| CSE|38.851917|-106.928345|3.104303769218115E-6| 22450.18538285592|
|08065|39.2025|-106.3448| CSE|38.851917|-106.928345|2.500939538568901E-5| 63722.23608685986|
|48209|30.0579| -98.0312| JCY|  30.2518|   -98.6225|2.277032497993663...| 60802.83978732194|
|48091|29.8082| -98.2783| JCY|  30.2518|   -98.6225|2.174810198652220...|59422.354429979925|
|48259|29.9447| -98.7115| JCY|  30.2518|   -98.6225|7.633703781612457E-6| 35205.11806154229|
|48171|30.3181| -98.9465| JCY|  30.2518|   -98.6225|6.296169739141368E-6| 31972.47602152779|
|48299|30.7057| -98.6841| JCY|  30.2518|   -98.6225|1.590421399140834E-5| 50815.34251108926|
|48031|30.2664| -98.3999| JCY|  30.2518|   -98.6225|2.831418936763779E-6| 21440.74500871218|
|09003|41.8064| -72.7329| PMX|  42.2233|   -72.3114|2.070437588944565...|57978.926668764085|
|25027|42.3514| -71.9077| PMX|  42.2233|   -72.3114|8.041933637577737E-6| 36134.19844483637|
|25013|42.1351| -72.6316| PMX|  42.2233|   -72.3114|4.880110590711167E-6|  28148.3398543281|
|25015|42.3402| -72.6638| PMX|  42.2233|   -72.3114|6.217323891092089E-6|31771.652001177645|
|09013| 41.855| -72.3365| PMX|  42.2233|   -72.3114|1.035645651937917...| 41005.67294046831|
|09015|  41.83| -71.9874| PMX|  42.2233|   -72.3114|1.619117315338834...| 51271.72525316231|
|25011|42.5831| -72.5918| PMX|  42.2233|   -72.3114|1.312314031563772...|46159.111096013294|
|02130|55.5852|-130.9288| WLR|  55.6013|   -131.637|1.221483841184451...| 44533.04053001048|
|02198|55.7997|-133.0192| PTC|   55.803|   -133.597|8.032840930174344E-6| 36113.76483314352|
+-----+-------+---------+----+---------+-----------+--------------------+------------------+
only showing top 20 rows

Saving county and near by airports ... 
```

3. Push the results into the `topic_ctytoarp` topic via a `spooldir` connector

```bash
    ./scripts/spark/setup_kafka_connector.sh
```

4. (Optional) Check if the data points are there (press Ctrl+C to quit)

```bash
    ./scripts/kafka/get_topic_info.sh topic_ctytoarp
```

5. (Optional) Stop the cluster

```bash
    ./scripts/spark/stop.sh
```

6. (Optional) Restart the cluster (once it has already been set up)

```bash
    ./scripts/spark/start_again.sh
```

7. (Optional) Remove the cluster

```bash
    ./scripts/spark/cleanup.sh
```

### IV.5.b Surge Correlation Detection by Neo4j

![Data Science](../images/Data%20Mesh%20PoC/Data%20Mesh%20PoC.008.png)

Neo4j is a graph database management system developed by Neo4j, Inc. Described by its developers as an ACID-compliant transactional database with native graph storage and processing.

1. Setup a Neo4j and neodash

```bash
    ./scripts/neo4j/start_first_time.sh
```

![The neo4j Docker Set](../images/docker-diagrams/docker-compose-neo4j.png)

Note that we have to wait until `neo4j` is ready. There are several ways to do so, the easier, although not the best for automation, is to scan the log if `Neo4j` is `Started`

```bash
    docker compose docker-compose-neo4j.yml logs neo4j -f
```

2. Setup the constraints and indexes for faster data search

```bash
    ./scripts/neo4j/setup_database.sh
```

3. Connect to Kafka to receive all data

Import all nodes and relationships
```bash
    ./scripts/neo4j/setup_kafka_node_connector.sh
```

Wait until complete (approx 3-4 mins, depending on hardware configuration, check on neo4j if `854114` nodes were imported)
```bash
    ./scripts/neo4j/setup_kafka_rels_connector.sh
```
By opening a browser to port `localhost:7474`, we can see if the data are successfully imported. See the number of nodes.

![Neo4j after import](../images/screen-captured/neo4j-after-import.png)

You can also monitor the event flow progress from `Kafka Control Center`, using the `Consumer Group` menu item, then select [`Neo4jEntitySinkConnector`](../conf/neo4j_node_sink_connector.json) for the nodes, created from `topic_counties,topic_airports,topic_dailyc19` topics, 

![Neo4j nodes import](../images/screen-captured/neo4j-node-consumer-group.png)

and [`Neo4jRelationshipSinkConnector`](../conf/neo4j_rels_sink_connector.json) for the relationships, created from `topic_arptoarp,topic_ctytoarp` topics.

![Neo4j relationship import](../images/screen-captured/neo4j-relationship-consumer-group.png)

4. We then have to perform a few queries on the `neo4j browser` to get the data ready for our study:

```bash
    ./scripts/neo4j/post_processing.sh
```

Sum up quarterly passenger traffic to make it annual
```Cypher
    CALL apoc.periodic.iterate("
        MATCH (a1:Airport)
        RETURN a1 ORDER BY a1.ident
    ","
        WITH a1
            MATCH (a1)-[r1:A2A]-(a2:Airport) 
                WHERE a1.ident < a2.ident
        WITH DISTINCT(a2) AS a2, SUM(r1.passengers)/COUNT(r1) AS passengers, a1
            MERGE (a1)-[r:A2A_PT]-(a2)
                SET r.passengers = passengers
    ",
        {batchSize:1, parallel:false}
    )
```

![Neo4j browser query](../images/screen-captured/neo4j-browser-query.png)

Sum up passenger traffic per air route for each connected county pairs
```Cypher
    CALL apoc.periodic.iterate("
        MATCH (c1:County)
        RETURN c1 ORDER BY c1.county_fips
    "," 
        WITH c1
            MATCH (c1)-[:C2A]-(a1:Airport)-[r1:A2A_PT]-(a2:Airport)-[:C2A]-(c2:County)
                WHERE a1 <> a2 AND c1 <> c2 AND NOT((c1)-[:C2C_PT]-(c2))
        WITH DISTINCT(c2) AS c2, SUM(r1.passengers) AS passengers, c1
        WITH c1, c2, passengers
            MERGE (c1)-[r:C2C_PT]-(c2)
                SET r.passengers = passengers
        WITH DISTINCT(c1) AS c1, SUM(passengers) AS passengers
        WITH c1, passengers
            SET c1.passengers = passengers
    ",  
        {batchSize:1, parallel:false}
    )
```

Here is an example: counties connected by air routes to Snohomish County, Washington State:
![Counties connected by air routes to Snohomish County](../images/screen-captured/connected-counties-snohomish.png)

Setting valid date range (having Covid data) for each county
```Cypher
    MATCH (c:County)
    WITH c
        MATCH (d:DailyC19 {fips: c.county_fips})
    WITH c, d.date AS date ORDER BY date ASC
    WITH DISTINCT(c) AS c, COLLECT(date) AS dates
    WITH c, HEAD(dates) AS min_date, HEAD(REVERSE(dates)) AS max_date
        SET c.min_date = min_date, c.max_date = max_date
```

5. Once the data is ready, then we compute [correlations among connectecd counties](#correlation) and cluster them

**Compute correlation of every connected county pairs (c1, c2)**
+ *first, we take two counties that are connected by a direct air routes (each county is within 60 kilometers/ 40 miles (an usual driving distance) of one of the airports);*
+ *second, we compare daily surge in each county in respect to its population as percentage (between 0% and 100%);*
+ *third, we compare the surges in population percentage between two counties by each day, take the square of each difference, then the sum of them, finally dividing by the number of days.*

*The result should be less than a threshold. 0.2 is chosen for this experiment, which means that basically the difference in daily surge of the two counties should not exceed 0.45%*

&nbsp;

$$\frac{1}{max_{date} - min_{date} + 1} \sum_{i=min_{date}}^{max_{date}} \left( 100 \cdot \frac{c1_{cases}}{c1_{population}} - 100 \cdot \frac{c2_{cases}}{c2_{population}} \right)^2 \le 0.2$$

&nbsp;

**What does it mean?**
+ *Imagine that each county is a point in a multi-dimensional space. The number of dimensions are the number of (reported) days, so we have over 3000 points (counties) in a **300+ dimensional space**. The values of the coordinates of the points are the numbers of daily surges;*
+ *Since the coordinates of the points can greatly vary, we perform a **normalization** by translating these points into a multi-dimensional cube whose side length is 100 (percent);*
+ *For each of the connected neighbors (counties connected by direct air routes), we compute the (multi-dimensional) **Euclidean distance** between the point and this neighbor. If the distance is within $0.2 \times n,$ where $n$ is the number of dimensions, then the neighbor is consider **correlated**. For example inside a $100 \times 100 \times 100$ cube two points within a distance of $0.6$ are considered correlated.* 

&nbsp;

Below is the implementation in `Cypher Query Language`, the query language of `Neo4j`:

```Cypher
    CALL apoc.periodic.iterate("
        MATCH (c1:County)-[r:C2C_PT]-(c2:County)
        WHERE c1.county_fips < c2.county_fips
        RETURN c1, r, c2,
            (CASE c1.min_date <= c2.min_date WHEN TRUE THEN c2.min_date ELSE c1.min_date END) AS min_date, 
            (CASE c1.max_date <= c2.max_date WHEN TRUE THEN c1.max_date ELSE c2.max_date END) AS max_date
    "," 
        WITH c1, r, c2, min_date, max_date
        MATCH (d1:DailyC19 {fips: c1.county_fips})
            WHERE d1.date >= min_date AND d1.date <= max_date
        WITH c1, r, c2, d1 
            MATCH (d2:DailyC19 {fips: c2.county_fips, date: d1.date})
        WITH c1, r, c2, d1.date AS date, (d1.cases*100.0/c1.population)-(d2.cases*100.0/c2.population) AS diff
        WITH DISTINCT(c1) AS c1, r, c2, SQRT(SUM(diff*diff)/COUNT(diff)) AS sos
        WITH r, sos            
            WHERE sos <= 0.2
            SET r.sos = sos
    ",
        {batchSize:1000, parallel:true}
    )
```

Perform `Louvain clustering` algorithm
```Cypher
    CALL gds.graph.drop('correlatedCounties');
```

```Cypher
    CALL gds.graph.project(
        'correlatedCounties',
        'County',
        {
            C2C_PT: {
                orientation: 'UNDIRECTED'
            }
        },
        {
            relationshipProperties: 'sos'
        }
    )
```

```Cypher
    CALL gds.louvain.write.estimate('correlatedCounties', { writeProperty: 'community' })
    YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory
```

```Cypher
    CALL gds.louvain.write('correlatedCounties', { writeProperty: 'community' })
    YIELD communityCount, modularity, modularities
```

### IV.5.e Neodash visualization

Neodash supports presenting your data as tables, graphs, bar charts, line charts, maps and more. It contains a Cypher editor to directly write the Cypher queries that populate the reports. You can save dashboards to your database, and share them with others.

Quickstart: lets watch this [video](https://youtu.be/Ygzj0Y4cYm4), or a [hands-on lab](https://youtu.be/vjZ9M7JpExA), or start [here](https://neo4j.com/labs/neodash/2.2/user-guide/dashboards/). Knowledge of [Cypher Query Language](https://neo4j.com/labs/neodash/2.2/user-guide/dashboards/) is a must. If you are already good at it, here is the [Cheat Sheet](https://neo4j.com/docs/cypher-cheat-sheet/current/), or more powerful functions and procedures supported by the [Awesome Procedures for Neo4j](https://neo4j.com/docs/apoc/current/).

Following Cypher queries are use to fetch and show correlated data

```Cypher
    MATCH (c1:County {county_fips: "06037"})-[r:C2C_PT]-(c2:County)
        WHERE r.sos <= 0.2
    RETURN c2.county_fips, c2.county_ascii, c2.state_name, r.sos ORDER BY r.sos ASC
```

```Cypher
    MATCH (d1:DailyC19 {fips: "06037"}), (c1:County {county_fips: "06037"})
        WHERE d1.date >= "2020-04-01"
    WITH d1, c1
        MATCH (d2:DailyC19 {fips: "37119", date: d1.date}), (c2:County {county_fips: "37119"})
    WITH d1, c1, d2, c2
        MATCH (d3:DailyC19 {fips: "22103", date: d1.date}), (c3:County {county_fips: "22103"})
    WITH d1, c1, d2, c2, d3, c3
        MATCH (d4:DailyC19 {fips: "12071", date: d1.date}), (c4:County {county_fips: "12071"})
    WITH d1, c1, d2, c2, d3, c3, d4, c4
        MATCH (d5:DailyC19 {fips: "13121", date: d1.date}), (c5:County {county_fips: "13121"})
    RETURN DATE(d1.date) AS date, 
        d1.cases*100.0/c1.population AS Los_Angeles_CA,
        d2.cases*100.0/c2.population AS Mecklenburg_NC,
        d3.cases*100.0/c3.population AS St_Tammany_LA,
        d4.cases*100.0/c4.population AS Lee_FL,
        d5.cases*100.0/c5.population AS Fulton_GA
        LIMIT 250
```

The results are visualized via Neodash.

Top 4 correlated counties to Los Angeles County, California
![Top 4 correlated counties to Los Angeles County, California](../images/screen-captured/top-4-correlated-counties-los-angeles.png)

All correlated counties to Los Angeles County, California
![All correlated counties to Los Angeles County, California](../images/screen-captured/correlated-counties-los-angeles.png)

### IV.5.f Neo4j Bloom visualization

[Neo4j Bloom](https://neo4j.com/product/bloom/) is a beautiful and expressive data visualization tool to quickly explore and freely interact with Neo4j’s graph data platform with no coding required. Read the [Visual Guide](https://neo4j.com/whitepapers/bloom-visual-guide/) or watch the [video](https://youtu.be/y9trGgqFu_k) for a quickstart.

1. Installing Neo4j Desktop

[Neo4j Desktop](https://neo4j.com/developer/neo4j-desktop/#what-is-neo4j-desktop) is a Developer IDE or Management Environment for Neo4j instances similar to Enterprise Manager, but better. You can manage as many projects and database servers locally as you like and also connect to remote Neo4j servers. *Neo4j Desktop comes with a free Developer License of Neo4j Enterprise Edition. The Java Runtime is also bundled.* It can be downloaded from [here](https://neo4j.com/download/).

[Install and configure it](https://neo4j.com/download-thanks-desktop/) with a given `Activation Key`, don't install the example database.

Click on the `New` button next to the `Projects` title, add a new project, and give it a name `Data Mesh PoC`, access to `Neo4j` instance `neo4j://localhost:7687` with `neo4j` and `phac2022` as credential.

Click on the `Connect` button, then choose `Neo4j Browser` from the dropdown list, then you have access to Neo4j via browser. Now, repeat the step and choose `Neo4j Bloom`.

2. Using Neo4j Bloom

After open it, you probably find an empty screen, called a scene.

![New Scene](../images/screen-captured/neo4j-bloom-new-scene.png)

First, type part of the name of the `Snohomish` county to find which entities might have such a property matching this string. 

![Finding Snohomish County](../images/screen-captured/neo4j-bloom-find-snoho-county.png)

Click on the `County` node, then it offers some relationship to some `Airport`, 

![Snohomish County with an air route](../images/screen-captured/neo4j-bloom-snoho-airport.png)

then click on an `Airport` (nearby one), then to another `Airport` (the one connected by a direct air route, now we have an *abstract route* with unknown airports. There would be many possible two-airports paths.

![Snohomish County with an air route](../images/screen-captured/neo4j-bloom-find-snoho-la-county.png)

 Choose `Los Angeles` county as the next node on the path, basically to see what air routes connected the two counties.

 ![Snohomish County with air routes to Los Angeles](../images/screen-captured/neo4j-bloom-find-snohomish-la-via-air-routes.png)

More details of nodes and relationships can be seen,

![Details in paths connecting Snohomish County via air routes with Los Angeles](../images/screen-captured/neo4j-bloom-find-snoho-la-county-details.png)

Of course without using `Los Angeles` as an end node, we can see all possible paths.

![Snohomish County with air routes to all countiees](../images/screen-captured/neo4j-bloom-find-snoho-all-county.png)

And we can remove the airports to see the abstraction of Snohomish and connected counties at higher level.

![Snohomish County with air routes to all countiees](../images/screen-captured/neo4j-bloom-snoho-all-counties-no-airport.png)

[Prev](./III-a-short-summary-of-data-mesh.md) | [Top](../README.md) | [Next](./V-towards-a-reference-implementation.md)