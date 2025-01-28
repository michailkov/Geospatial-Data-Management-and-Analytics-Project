--Q1

CREATE TABLE Positions (
    taxi_id VARCHAR(50),        
    timestamp BIGINT,        
    latitude DOUBLE PRECISION,   
    longitude DOUBLE PRECISION,  
    occupancy SMALLINT,           
    location GEOMETRY(Point, 4326), 
    PRIMARY KEY (taxi_id, timestamp) 
);


COPY Positions(taxi_id, timestamp, latitude, longitude, occupancy)
FROM 'C:/Users/Feuer_Frei/Desktop/DataGeospatial.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM Positions;


--Q2 Number of rows 11219955

UPDATE Positions
SET location = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);

SELECT * FROM Positions;

--Q3 9914327

DELETE FROM Positions
WHERE latitude < 37.707 OR latitude > 37.811
   OR longitude < -122.514 OR longitude > -122.358;
   
SELECT * FROM Positions;

--Q4 5957058

WITH CTE AS (
    SELECT 
        taxi_id,
        timestamp AS timestamp1,
        LAG(timestamp) OVER (PARTITION BY taxi_id ORDER BY timestamp) AS timestamp2
    FROM Positions
)
DELETE FROM Positions
WHERE (taxi_id, timestamp) IN (
    SELECT taxi_id, timestamp1
    FROM CTE
    WHERE (timestamp1 - timestamp2) < 60
);



--Q5 5955069

ALTER TABLE Positions ADD COLUMN speed_kmh FLOAT;

WITH position_data AS (
    SELECT 
        taxi_id,
        timestamp AS timestamp1,
        LAG(location) OVER (PARTITION BY taxi_id ORDER BY timestamp) AS prev_location,
        LAG(timestamp) OVER (PARTITION BY taxi_id ORDER BY timestamp) AS prev_timestamp,
        ST_Distance(location::geography, LAG(location) OVER (PARTITION BY taxi_id ORDER BY timestamp)::geography) AS distance_meters,
        (timestamp - LAG(timestamp) OVER (PARTITION BY taxi_id ORDER BY timestamp)) AS time_seconds
    FROM Positions
)
UPDATE Positions
SET speed_kmh = (position_data.distance_meters / position_data.time_seconds) * 3.6  
WHERE Positions.taxi_id = position_data.taxi_id
AND Positions.timestamp = position_data.timestamp1
AND position_data.time_seconds > 0;


SELECT *
FROM Positions
ORDER BY speed_kmh DESC;



DELETE FROM Positions
WHERE speed_kmh > 120;


--Q9



CREATE TABLE Trips (
    trip_id SERIAL PRIMARY KEY,  
    taxi_id VARCHAR(255),
    depart_time BIGINT,  
    arrival_time BIGINT,  
    depart_location GEOMETRY(Point, 4326),
    arrival_location GEOMETRY(Point, 4326),
    occupancy SMALLINT  
);

drop table trips;

WITH Trip_Segments AS (
    SELECT
        taxi_id,  
        timestamp AS event_time_unix,  
        location AS event_location,
        occupancy,
        LAG(occupancy) OVER (PARTITION BY taxi_id ORDER BY timestamp) AS previous_occupancy,
        LAG(timestamp) OVER (PARTITION BY taxi_id ORDER BY timestamp) AS previous_time_unix,  
        LAG(location) OVER (PARTITION BY taxi_id ORDER BY timestamp) AS previous_location
    FROM Positions
)
INSERT INTO Trips (taxi_id, depart_time, arrival_time, depart_location, arrival_location, occupancy)
SELECT
    taxi_id,
    previous_time_unix AS depart_time, 
    event_time_unix AS arrival_time, 
    previous_location AS depart_location,
    event_location AS arrival_location,
    previous_occupancy AS occupancy
FROM Trip_Segments
WHERE previous_occupancy IS NOT NULL
AND occupancy != previous_occupancy;

select *from trips;

CREATE TABLE SpeedLimits (
    objectid SERIAL PRIMARY KEY,               
    cnn VARCHAR(50),                           
    street VARCHAR(100),                    
    st_type VARCHAR(50),                       
    from_st VARCHAR(100),                       
    to_st VARCHAR(100),                        
    speedlimit INTEGER,                         
    schoolzone BOOLEAN,                        
    schoolzone_limit INTEGER,                   
    analysis_neighborhood VARCHAR(100),         
    geometry GEOMETRY(MultiLineString, 4326)    
);


COPY SpeedLimits (objectid, cnn, street, st_type, from_st, to_st, speedlimit, schoolzone, schoolzone_limit, analysis_neighborhood, geometry)
FROM 'E:/ModifiedDownloads/Filtered_Speed_Limits.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',', NULL '', QUOTE '"');

select * from SpeedLimits


--Q10
CREATE INDEX idx_positions_location ON Positions USING GIST (location);
CREATE INDEX idx_speedlimits_geometry ON SpeedLimits USING GIST (geometry);

WITH Buffered_SpeedLimits AS (
    SELECT 
        objectid,
        speedlimit,
        ST_Buffer(geometry::geography, 50)::geometry AS buffered_geometry 
    FROM SpeedLimits
),
Speed_Violations AS (
    SELECT 
        p.taxi_id,
        p.timestamp,
        p.speed_kmh,
        s.speedlimit,
        p.speed_kmh - s.speedlimit AS speed_over_limit,
        s.objectid AS road_segment_id
    FROM Positions p
    JOIN Buffered_SpeedLimits s
    ON ST_Intersects(p.location, s.buffered_geometry) 
    WHERE p.speed_kmh > s.speedlimit
)
SELECT 
    taxi_id,
    timestamp,
    speed_kmh,
    speedlimit,
    speed_over_limit,
    road_segment_id
FROM Speed_Violations;

--Q11

ALTER TABLE Trips ADD COLUMN length FLOAT;  

SELECT 
    COUNT(CASE WHEN occupancy = 1 THEN 1 END) AS occupancy_true_count, 
    COUNT(*) AS total_count,
    (COUNT(CASE WHEN occupancy = 1 THEN 1 END) * 100.0 / COUNT(*)) AS occupancy_percentage
FROM 
    Trips;


UPDATE Trips SET length = ST_Distance(depart_location::geography, arrival_location::geography);


SELECT
    taxi_id,
    AVG(length) AS average_length,
    AVG(arrival_time - depart_time) AS average_duration,
    MIN(length) AS min_length,
    MAX(length) AS max_length,
    MIN(arrival_time - depart_time) AS min_duration,
    MAX(arrival_time - depart_time) AS max_duration
FROM
    Trips
WHERE
    occupancy = 1 
GROUP BY
    taxi_id;

SELECT * FROM Trips;