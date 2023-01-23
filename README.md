Data Mesh Proof of Concept

# Overview

In the [first part](#the-imaginative-case), an *imaginative case* is defined, which consists of
- US COVID data was reported from over 3000 counties in 2020;
- Federal CDC  and California State monitoring the situation;
- John Hopkins University determine correlation of surges in counties connected by air routes.

In the [second part](#traditional-approaches), the *imaginative case* then is used to discuss traditional approaches that might have been used to design, develop, and deploy an IT infrastructure to support the execution of the case. Common pitfalls, apparent problems, and emerging risks are identified and analyzed to see why they can surface often in similar problem context.

In the [third part]](#a-short-summary-of-data-mesh), we discuss briefly the Data Mesh architechtural principles and its patterns. All of the content are summaries from the book [*Data Mesh, Delivering Data-Driven Value at Scale, Zhamak Dehghani.*](https://www.starburst.io/info/oreilly-data-mesh/)

In the [fourth part](#a-short-summary-of-data-mesh), a concrete dataset, a set of software tools, and a step-by-step guide how to install, configure, and monitor them are put together for a Proof-of-Concept (PoC) of **Data Mesh** architecture principles and proven practices on how to solve problems similar to the *imaginative case* without repeating the pitfalls, problems, and risks of the traditional convenient, time-consuming and costly human effort approach. In addition, different deployment scenarios are explained briefly how the PoC can be demonstrated due to constraints or availabilities of  resources.

In the [last part](#towards-a-reference-implementation), a description for a possible continuation of the PoC is sketched. In essential, it includes a number of architectural principles, an brief overview on how a Data-as-a-Product as a standalone group of applications, databases, and event streams can be built for different data domains, then how these standalone data domains can work together in a federated manner. The result is a reference implementation that can be used as core tools to construct applications in many different settings. It is also can be served as a foundation for later design and development of a widely used toolbox for building, testing, and deploying applications with better quality, in shorter amount of time, and lower total cost of ownership.

&nbsp;

# Table of Content
## [I.](#the-imaginative-case) [The imaginative case](./doc/I-the-imaginative-case.md)
## [II.](#traditional-approaches) [Traditional approaches](./doc/II-traditional-approaches.md)
## [III.](#a-short-summary-of-data-mesh) [A short summary of Data Mesh](./doc/III-a-short-summary-of-data-mesh.md)
## [IV.](#the-proof-of-concept) [The Proof-of-Concept](./doc/IV-the-proof-of-concept.md)
## [V.](#towards-a-reference-implementation) [Towards a Reference Implementation](./doc/V-towards-a-reference-implementation.md)