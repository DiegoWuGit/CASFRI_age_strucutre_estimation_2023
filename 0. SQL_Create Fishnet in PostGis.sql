------------------------------------------------------------------------------------------------------------------------------
----- Project Name:
------Assessing change in forest age structure in the western boreal forest using CASFRI and remote sensing products
-----
----- Author:
------Siu Chung Wu (Diego)
-----
----- Date:
------2024 Mar 1
------------------------------------------------------------------------------------------------------------------------------
------ Module 0
------ Create Fistnet covering four western provinces in Canada for sampling forest resource inventories
------------------------------------------------------------------------------------------------------------------------------
--1.
--Create a New Table for the Fishnet: 
CREATE TABLE diego_test.fishnet (
    FishNetid serial PRIMARY KEY,
    geom geometry(Point, 102001),
    prov VARCHAR(10)
);


--2.
--Generate function for creating the Fishnet
--Parameters: 316 meters
 
CREATE OR REPLACE FUNCTION diego_test.CreateFishnetPoints(
    nrow integer, ncol integer,
    x_start double precision, y_start double precision,
    x_end double precision, y_end double precision)
RETURNS SETOF geometry AS
$$
DECLARE
    x_step double precision := 316; -- .316 kilometers in meters
    y_step double precision := 316; -- .316 kilometers in meters
    i integer;
    j integer;
    geom geometry;
BEGIN
    FOR i IN 0..ncol LOOP
        FOR j IN 0..nrow LOOP
            geom := ST_SetSRID(ST_MakePoint(
                x_start + i * x_step,
                y_start + j * y_step
            ), 102001);
            RETURN NEXT geom;
        END LOOP;
    END LOOP;
    RETURN;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;



--3.
--Populate the Table with the Fishnet Grid
--Parameters: x_start_-2346177, y_start_984795, x_end_422331, y_end_2952031 (bounding box of 4 western provinces, CRS:102001)

 
INSERT INTO diego_test.fishnet (geom)
SELECT * FROM diego_test.CreateFishnetPoints(
    (2952031 - 984795)/316, -- Number of rows
    (422331 - (-2346177))/316, -- Number of columns
    -2346177, 984795, -- Starting X, Y coordinates in EPSG:102001
    422331, 2952031 -- Ending X, Y coordinates in EPSG:102001
);



--4.
-- classify points by provinces and add a flag (BC/BC/SK/MB) for easier joining in later step
-- remove unnessary points

WITH FilteredBC AS (
    SELECT *
    FROM diego_test."Province"
    WHERE prename LIKE 'British Columbia'
)
UPDATE diego_test.fishnet fn
SET prov = 'BC'
FROM FilteredBC
WHERE ST_Within(fn.geom, FilteredBC.geom);

WITH FilteredAB AS (
    SELECT *
    FROM diego_test."Province"
    WHERE prename LIKE 'Alberta'
)
UPDATE diego_test.fishnet fn
SET prov = 'AB'
FROM FilteredAB
WHERE ST_Within(fn.geom, FilteredAB.geom);

WITH FilteredSK AS (
    SELECT *
    FROM diego_test."Province"
    WHERE prename LIKE 'Saskatchewan'
)
UPDATE diego_test.fishnet fn
SET prov = 'SK'
FROM FilteredSK
WHERE ST_Within(fn.geom, FilteredSK.geom);

WITH FilteredMB AS (
    SELECT *
    FROM diego_test."Province"
    WHERE prename LIKE 'Manitoba'
)
UPDATE diego_test.fishnet fn
SET prov = 'MB'
FROM FilteredMB
WHERE ST_Within(fn.geom, FilteredMB.geom);

DELETE FROM diego_test.fishnet
WHERE prov IS NULL;



--5.
--Add the New Columns with X and Y Values, concatenating then into XY_id
--xy_id will be the primary key of the sampling points in later process

ALTER TABLE diego_test.fishnet
ADD X DOUBLE PRECISION,
ADD Y DOUBLE PRECISION;

UPDATE diego_test.fishnet
SET X = ST_X(geom),
    Y = ST_Y(geom);

ALTER TABLE diego_test.fishnet
ADD XY_id VARCHAR(20);

UPDATE diego_test.fishnet
SET XY_id = CONCAT(TRIM(CAST(X AS CHAR(10))), TRIM(CAST(Y AS CHAR(10))));


--6.
--Saving Fishnets into 4 tables according to province
 
CREATE TABLE diego_test.FNBC AS
SELECT *
FROM diego_test.fishnet
WHERE prov = 'BC';

CREATE TABLE diego_test.FNAB AS
SELECT *
FROM diego_test.fishnet
WHERE prov = 'AB';

CREATE TABLE diego_test.FNSK AS
SELECT *
FROM diego_test.fishnet
WHERE prov = 'SK';

CREATE TABLE diego_test.FNMB AS
SELECT *
FROM diego_test.fishnet
WHERE prov = 'MB'
