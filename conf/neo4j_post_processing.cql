////////////////////////////////////////////////////////////////////////////////////////////////////
// Sum up quarterly passenger traffic to make it annual

CALL apoc.periodic.iterate("
    MATCH (a1:Airport)
    RETURN a1 ORDER BY a1.ident
","
    WITH a1
        MATCH (a1)-[r1:A2A]-(a2:Airport) 
            WHERE a1.ident < a2.ident
    WITH 
        DISTINCT(a2) AS a2, 
        SUM(r1.passengers)/COUNT(r1) AS passengers, 
        SUM(r1.nsmiles)/COUNT(r1) AS nsmiles, 
        SUM(r1.fare)/COUNT(r1) AS fare, 
        a1
        MERGE (a1)-[r:A2A_PT]-(a2)
            SET 
                r.passengers = passengers,
                r.nsmiles = nsmiles,
                r.fare = fare
",
    {batchSize:1, parallel:false}
);
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Sum up passenger traffic per air route for each connected county pairs

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
);
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Setting valid date range (having Covid data) for each county

MATCH (c:County)
WITH c
    MATCH (d:DailyC19 {fips: c.county_fips})
WITH c, d.date AS date ORDER BY date ASC
WITH DISTINCT(c) AS c, COLLECT(date) AS dates
WITH c, HEAD(dates) AS min_date, HEAD(REVERSE(dates)) AS max_date
    SET c.min_date = min_date, c.max_date = max_date;
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Compute correlation (based on sum of squares of dfference in cases as population percentage) 
// of every connected county pairs.

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
);
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Compute clusters

CALL gds.graph.drop('correlatedCounties');

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
);

CALL gds.louvain.write.estimate('correlatedCounties', { writeProperty: 'community' })
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

CALL gds.louvain.write('correlatedCounties', { writeProperty: 'community' })
YIELD communityCount, modularity, modularities;
```

MATCH (c:County)
WITH DISTINCT(c.community) AS community, COUNT(*) AS count
RETURN community, count;
////////////////////////////////////////////////////////////////////////////////////////////////////