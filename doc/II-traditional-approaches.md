[Prev](./I-the-imaginative-case.md) | [Top](../README.md) | [Next](./III-a-short-summary-of-data-mesh.md)

# II. Traditional approaches

![Traditional approaches](../images/Data%20Mesh%20PoC/Data%20Mesh%20PoC.002.png)

## II.1. Getting the Data

In order to collect data from various sources into a common pool, one of the well-known practice is to use certain file formats such as Excel, CVS/TSV, JSON, XML, PDF, etc as *encapsulation formats* with appropriately semantics. For example a daily report is represented by a row in an Excel/CSV file , an element of a JSON array or a line in a PDF file. 
- The data files are *manually created data points* are manually entered.
- It is also possible that the data files are by product of some existing applications such as survey, hospital/medical record management, etc. 
- They could also be manually/automatically aggregated data from different systems.  

Email then is used as *transport medium* with data files as attachment. This approach requires:
- The data files to be manual extracted and then uploaded to a common share storage, which could be a local file folder, a LAN share volume, or a cloud storage;
- The data files are automatically extracted from the emails. This method requires additional work with *proprietary knowledge to handle* different types/versions of email systems. It can work only if the email address, subject, or format are customized such that the emails carrying data files can be consistently recognized. It is obvious that this method is difficult to be used in context where such format agreement requires *too many parties*.

Instead of email, the data files can be put in pre-defined folders on a LAN share volume, or a cloud storage. This approach requires access to such destination for multiple parties. It would not be problem for a LAN volume, where typically a few people in a local office has access to the local network for daily work purposes. However the complexity and security risk are increased if many people are allowed to access a common storage. Tradeoff between creating and maintaining some tiresome AAA (authentication, authorization, and accounting) processes and risks of data altercation by careless data file handling need to be considered. In any case it is out-of-scope, ad-hoc, short-live task creating headache, and later risk, to the infrastructure. 

Cloud Storage could simplify somewhat the process by removing repetition of uploading the same data files  or aggregation work at multiple administrative levels, however *the complexity and risks of access control (BRAC/ACL)* are still the same.

Client/Server or Web application could be a much better method to solve the problem of getting the daily reports into a single common repository. However, this would be the most costly if it requires design, development, and deployment of applications from scratch, then staff training and IT infrastructure to support the process. In cases such as COVID or similar emergency, there is no time for large scale deployment. Often, *large scale deployment requiring upgrading IT infrastructure is unrealistic* considering the budget, number of people involved, and difficulties in orchestration.

Cloud deployment would greatly reduce availability and scaling problems, but depending on allocation of resources, would not eliminate them entirely. Locally and on-premises hosted Client/Server or Web applications often face these problems especially when *deploying applications that are not part of the original design/plan* of the existing IT infrastructure. In order to minimize or eliminate these possible problems, additional, often unforeseeable investment required to upgrade the infrastructure, which usually cannot be done within a short time frame.

Beside the above common pitfalls, the number of manual interactions required by the process, regardless how simple would they be, still can be considered as sources of later errors and problems.

Assuming a stable system with a near perfect process is built and put in place, there are still issues with the data itself.  Why? Because of two reasons:
- Multiple sources of data production means *multiple forms and different interpretations*
- Data evolves all the time, thus the needs for additional data fields, or new but related data points might arose
Both of these - change in metadata producing *new metadata versions* - are reasons why data semantic, syntactic, and encapsulation formats have to  change. *These changes ignite a chain-reaction*. All adapters, protocols, transports, applications, storage,  etc that are manually handling the data have to be modified in order to accommodate the changes. The modifications can be small or large depending on the nature of the changes, the quality of the design, or the skills of the teams carrying out the modifications.

Note that the metadata change ripples sometime can be tsunami if they are not contained within certain controllable boundary/context. The question, that used to be asked, is *why don't we handle the metadata, then based on that automatically handle the data*, so that we can base our process design on how the metadata evolves.

## II.2. Storing the Data

The gathered daily reports can be stored in multiple ways in the central repository. The *central* term in central repository means that most of the components in the context can access the gathered data.

Traditional and known practices dictate that the data points can be stored as
- data files as in original format(s)
- cloud-backed data files (in, sort of, lakes)
- (cloud-backed) databases

Often the designers of the storage system have to make decisions to accommodate *two different sets of needs.*

Single and latest state:
- *The system strives on maintaining a single and latest state for every data points.* This results in use of a (set of) (cloud-backed) database(s). The implication is *the mandatory requirements of applications, adapters, and connectors to suppose the data points inside the database(s)*, since it does not make sense to support a single and latest state for every data points (not as replication) at the same time in multiple database(s).
- This requires careful work for decision on how to keep the data up-to-date as its metadata evolves and scarification of data history. Questions or machine learnings about past interactions or earlier data cannot be answered. Monitoring or tracking cannot be *rewind* because there is no past.
- This also requires internal and immediate decision to eliminate data conflict. Data producers and consumers do not have a say on these decisions if they are not involved at the design time.

Keeping everything:
- *Multiple storage formats storing the same data points will co-exist.* The ways the data points are processed might be the same for multiple applications, but they might have to be designed and developed separately (because of tools or skills), increasing costs of maintenance.
- Again, the decision to deal to multiple versions of the data, storing them, aggregate/update/filter them are mostly ad-hoc and proprietary. More likely the data are not dealt with in a uniform way because their metadata is not dealt with methodologically. In a free for all environment, *it is difficult to define processes based on tangible, un-versioned, inconsistent sources (data files).*
- Ensuring access to a database is more simpler than control authentication and authorization to a set of data files, even if they are backed by the cloud.

Evolving from a set of LAN folders to a (cloud) lake, using cloud tools instead of locally installed apps seems to make wonders. However the more rivers dump into a lake, then *the data lake become an data swamp* with no easy way to cleanup the trash, select the right resources, and streamline the processes. There is no safe way to navigate security risks with personal and protected information.

## II.3. Processing the Data

One of the reasons to use the cloud is to enable and ease working with big data. Instead of carefully design doses of data to work on a constrained environment with limited resources, adequate amount of memory, storage, and computational resources can temporarily be assigned to the work. Data collectors are happy to know that with a few click any storage for  streams of collected data can be increased *without* data relocation or lengthy pause of production environment. Scientists do not worry any more to complete a large ML model computation if it just require sheer computational power.  Managers are confident that the temporary surges in required resources increase the bills, but within the limit of their budgets.

Thus, the question here is how to allow the advantages provided by the cloud infrastructure to reach their highest potential to easily couple data gathering, data storing, and data processing in order to lower impact of quantity factor in data processing:
- How can these micro services easily be acquired, ran, and released?
- How to ensure that they start and stay within the scope of user privileges?
- How can they handle stream of data?
- How can they manage multiple versions of data?
- How do we know what states are they in?
- How do we know what data is under processing at the moment?
- How do we know how a data point is processed through a maze of micro services?

Now the complexity shifts towards *design, orchestration, and maintenance of workflows (DAGs) of micro services.*

## II.4. Providing the Data

Once the data gathered, stored, processed, and reach the state of readiness for consumption; they are served to end-users or other systems.

End-user consumption usually is a concern of cost. Constructing workflows, user interfaces for accepting visualization criteria, adding extra preprocessing, defining themes, and selecting the right visualization templates often require large amount of work. *When temporary surge of needs to establish systems dealing with instantaneous problems, there is little time for UI construction. It is also true for evaluating datasets, demonstrating ideas, and piloting systems that are ephemeral.* That's the reason why people use to fallback to Excel, Word, and other simple office tools. We will see later that **the approach of using low- or no-code tools slowly but firmly become a good choice for stakeholders.**

Offering data to another system is a natural mean to increase the value of the work already done with the data. There are multiple known approaches:
- *Offering access to storage and/or databases*: this insecure way to access data  violates rights for data access and increases risks of system instability.
- *Offering REST or similar APIs*: this often a good approach with certain weaknesses, especially when large amount of data or last up-to-date data points (for that specific client are required. Availability and scalability often designed based on the number of components and users within the system, not the number of users from external and unforeseeable systems. This approach often faces problem of authentication and authorization: which external users can access which parts of the data with what right for executing operations on the data?
- For some systems, *the data is designed to remain within its boundary*. External users might run queries or processes on the system and obtain results for external uses. This approach defeats the purpose of sharing data, increase the amount of resources the system must provide to unknown number of external requests, and in practice impossible to prevent data leaving the system. 

Thus, the questions are:
+ How to impose access control on each of the external systems as a whole rather then its users
+ How to provide the metadata and their versions
+ How to provide the data and their updates can be provided in the same way
+ How to provide the date without requiring large efforts or resources of the external system in order to consume 
+ How to revisit the history of data, tracking data in flow, aggregate/transform/filter them with ease.

Now, we see that it is not an easy task to support:
+ Setup *bidirectional data flows for different systems*: assuming that people who collect and provide data would need feedback, supervision, analytical data that are the result of some central processing.
+ Setup a *disaster recovery* infratructure that replicate the whole dataverse: at any moment (with a few seconds/minutes) delay, a whole ecosystem of software can switch over to the replicated dataverse.
+ Setup a *migration process* so that the ecosystem can be migrated to an higher-performance hardware/updated software infrastructure or another cloud or a multi-cloud environment.

Other obvious examples are geo-replication, adding new clusters, etc.

## II.5. Monitoring the Data

Monitoring is an aspect that usually is not considered as key part. Questions that used to arise *during operations, reporting, and troubleshooting* are such as:
- Did the data arrived intact? (is its quality comformant?)
- Was the data stored successfully?
- Was the data processed correctly? (do we obey policy and rules?)
- Was the data used properly?
- Can the chain of impacts be visualized?

Therefore, a monitoring subsystem is more than necessary to provide an understanding how data were processed, store, used from both abstract- and instance level. It should give an ability for system managers to access, track, and visualize the life of data points from the moment it arrives into the system to the moment it crosses the boundary into other systems.

[Prev](./I-the-imaginative-case.md) | [Top](../README.md) | [Next](./III-a-short-summary-of-data-mesh.md)
