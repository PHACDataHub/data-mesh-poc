[Prev](./II-traditional-approaches.md) | [Top](../README.md) | [Next](./IV-the-proof-of-concept.md)

# III. A short summary of Data Mesh

This short summary are based on the  excerpts from the book *Data Mesh, Delivering Data-Driven Value at Scale, Zhamak Dehghani.*

## III.1. Operational Data vs. Analytical Data

### III.1.a. Operational Data = Data on the inside

Operational data records what happens in the business, supports decisions that are specific to the business transaction, and keeps the current state of the business with transactional integrity.

This is private data of application/ micro-service is captured, stored, and processed in real-time, by OLTP (online transaction processing systems). Its modelling and storage are optimized for application logic and access patterns.  

Its design has to accommodate multiple people updating the same data at the same time in unpredictable sequences.

It can be intentionally shared on the outside through APIs - e.g REST, GraphQL, or events. On the outside it has the same nature as the on the inside: it is what we know about the business at the moment.

As the business needs grow, operational data is collected and then transformed into analytical data for training machine learning models (that then the operational systems as intelligent services.)

### III.1.b. Analytical Data = Data on the outside

Analytical data is the temporal, historic, and often aggregated view of the facts of the business over time. In other words, it is nonvolatile, integrated, time-variant collection of data.  

It is modelled to provide retrospective or future-perspective insights. Often this historical, integrated, and aggregate view of data is created as the byproduct of the operational data. It is maintained and used by OLAP (online analytical processing) systems. It is optimized for analytical logic - training machine learning models and creating reports and visualizations, directly accessed by analytical consumers.

Analytical consumers look for comparisons and trends over time, which operational usage has little need for. Analytical access mode tends to include intensive reads across a large body of data, with fewer writers.  

In short, analytical data is used to optimize the business and user experience (that then fuels further AI and analytics aspirations.)

### III.1.c Usage of Analytical Data

Analytical data is used for diagnoses, predictions, and recommendations by providing the key components for visualizations and reports to gain insights into business.  

It provides the data points to train machine learning models, thus enabling a technology shift from human-designed rule-based algorithms to data-driven machine-learned models, resulting in augmentation of business intelligence.

By doing so, it helps organizations to move from intuition and gut-driven decision making to taking actions based on quantifiable observations and data-driven predictions.

### III.2. Architecture evolution and new obstacles

Analytical data grew fast and in order to accommodate them, pipeline processing emerge as a architecture pattern in the beginning of 2000.

![Data pipelines](../images/Data%20Mesh%20SS/Data%20Mesh%20SS.006.png)

The evolution of system architecture to handle analytical data depicts in the below diagram.  Over time the availability of technologies offer multiple options for different scenarios.

Best practices are deduced from field experience and then followed until facing some newly found dilemma of isolation:
+ Operational organization and architecture supports domain-oriented cross-functional teams, separates 
+ Data (analytics) organization and architecture supports data and analytics functional team supported by 

![Two generations](../images/Data%20Mesh%20SS/Data%20Mesh%20SS.007.png)

This results in 
- Monolithic architecture: with sources to ingest and consumers to serve via a big data platform.
- Siloed hyper-specialized teams
	- Cross-functional domain-oriented source teams
	- Hyper-specialized data & ML team
	- Cross-functional domain-oriented consumer teams
+ End-to-end dependency from features to outcome

![Three problems generations](../images/Data%20Mesh%20SS/Data%20Mesh%20SS.008.png)

## III.3. Data Mesh approach

Analytical data is what powers the software and technology of the future. It
is becoming an increasingly critical component of the technology landscape. Data Mesh is a decentralized socio-technical approach to share, access, and manage analytical data in complex and large-scale environments - within or across organizations. Data Mesh is an approach in sourcing, managing, and accessing data for analytical use cases at scale.

Today's challenges:
+ Respond gracefully to change that has complexity, volatility, and uncertainty
+ Sustain agility in the face of growth
+ Increase the ratio of value of return on investment-into-data

### III.3.a. Respond gracefully to change that has complexity, volatility, and uncertainty

Align business, tech, and data (domain data ownership)
	- Create cross-functional business, tech, and data teams each responsible for long-term ownership of their data.

Close the gap between the operational and analytical data planes (data as a product):
	- Remove organization-wide pipelines and the two-plane data architecture,
	- Integrate applications and data products more closely through dumb pipes.
	
Localize data changes to business domains (data as a product)
	- Localize maintenance and ownership of data products in their specific domains,
	- Create clear contracts between domain-oriented data products to reduce impact of change.

Reduce the accidental complexity of pipelines and copying of data (data as a product, data product quantum architectural component)
	- Breakdown pipelines, move the necessary transformation logic into the corresponding data products, and abstract them as an internal implementation.

### III.3.b. Sustain agility in the face of growth

Remove centralized architectural bottlenecks (domain data ownership, data as a product)
	- Remove centralized data warehouses and data lakes.
	- Enable peer-to-peer data sharing of data products through their data interfaces.

Reduce the coordination of data pipelines (domain data ownership, data as a product)
	- Move from a top-level functional decomposition of pipeline architecture to a domain-oriented decomposition of architecture,
	- Introduce explicit data contracts between domain-oriented data products.

Reduce coordination of data governance (federated computational governance)
	- Delegate governance responsibilities to autonomous domains and their data product owners,
	- Automate governance policies as code embedded and verified by each data product quantum.

Enable team autonomy (federated computational governance, self-serve data platform)
	- Give domain teams autonomy in moving fast independently,
	- Balance team autonomy with computational standards to create interoperability and a globally consistent experience of the mesh,
	- Provide domain-agnostic infrastructure capabilities in a self-serve manner to give domain teams autonomy.

### III.3.c Increase the ratio of value of return on investment-into-data

Abstract complexity with a data platform (data as a product, self-serve data platform)
	- Create a data-developer-centric and a data-user-centric infrastructure to remove friction and hidden costs in data development and use journeys,
	- Define open and standard interfaces for data products to reduce vendor integration complexity.

Embed product thinking everywhere (data as a product, self-serve data platform)
	-  Focus and measure success based on data user and developer happiness,
	-  Treat both data and the data platform as a product.

Go beyond the boundaries of an organization (data as a product, self-serve data platform)
	- Share data across physical and logical boundaries of platforms and organizations with standard and internet-based data sharing contracts across data products.

## III.4. Data Mesh's Model at a Glance

![Data Mesh Architecture](../images/Data%20Mesh%20SS/Data%20Mesh%20SS.019.png)

## III.5. Five Principles of Domain Ownership

Purposes:
+ Decentralize the ownership of analytical data to business domains closest to the data-either the source of the data or its main consumers.
+ Decompose the (analytical) data logically and based on the business domain it represents, and manage the life cycle of domain-oriented data independently.
+ Architecturally and organizationally align business, technology, and analytical data.

Five principles
1. The ability to scale out data sharing aligned with the axes of organizational growth: increased number of data sources, increased number of data consumers, and increased diversity of data use cases
2. Optimization for continuous change by localizing change to the business domains
3. Enabling agility by reducing cross-team synchronizations and removing centralized bottlenecks of data teams, warehouses, and lake architecture
4. Increasing data business truthfulness by closing the gap between the real origin of the data, and where and when it is used for analytical use cases
5. Increasing resiliency of analytics and machine learning solutions by removing complex intermediary data pipelines

![Interlay of The Architectural Principles](../images/Data%20Mesh%20SS/Data%20Mesh%20SS.018.png)

## III.6. Four Principles of Data as a Product

Purposes:
+ Data as a product adheres to a set of usability characteristics:
	- Discoverable
	- Addressable
	- Understandable
	- Trustworthy and truthful
	- Natively accessible
	- Interoperable and composable
	- Valuable on its own
	- Secure
+ A data product provides a set of explicitly defined and easy to use data sharing contracts. Each data product is autonomous, and its life cycle and model are managed independently of others.
+ Data as a product introduces a new unit of logical architecture called data quantum, controlling and encapsulating all the structural components needed to share data as a product data, metadata, code, policy, and declaration of infrastructure dependencies autonomously.

Four principles:
1. Remove the possibility of creating domain-oriented data silos by changing the relationship of teams with data. Data becomes a product that teams share rather than collect and silo.
2. Create a data-driven innovation culture, by streamlining the experience of discovering and using high-quality data, peer-to-peer, without friction.
3. Create resilience to change with built-time and runtime isolation between data products and explicitly defined data sharing contracts so that changing one does not destabilize others.
4. Get higher value from data by sharing and using data across organizational boundaries.

[Prev](./II-traditional-approaches.md) | [Top](../README.md) | [Next](./IV-the-proof-of-concept.md)