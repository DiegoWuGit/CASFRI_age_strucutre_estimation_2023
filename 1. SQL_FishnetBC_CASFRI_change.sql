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
------ Module 1 
------ Join Fistnet to CASFRI covering four western provinces in Canada,
------ Pick the 2 sampled FRIs
------ Self-join the 2 sampled FRIs, which vitness the change over the recent decades
------ Join different kinds of disturbance records (from FRI, and data obtained by remote sensing) to the sampled FRIs
------ Export the change table to CSV for further analysis
------------------------------------------------------------------------------------------------------------------------------

-- 1.1.1
-- create index, and
-- join fishnet with casfri polygon
CREATE INDEX idx_fishnet_prov ON diego_test.fishnet USING btree(prov);

CREATE TABLE diego_test.test_points2 AS
SELECT
    fishnetid,
    cas_id
FROM
    casfri50.geo_all cas,
    diego_test.fishnet fish
WHERE
    ST_Intersects(cas.geometry, ST_Transform(fish.geom, 900914))
    AND fish.prov = 'BC';

-- 1.1.2
--change its name to FNBC_CASFRI
ALTER TABLE
    diego_test.test_points2 RENAME TO FNBC_CASFRI;

-- 1.1.3
--create index, and
--join it with fishnet attributs
CREATE INDEX idx_FNBC_CASFRI_fishnetid ON diego_test.FNBC_CASFRI (fishnetid);

CREATE INDEX idx_FNBC_CASFRI_cas_id ON diego_test.FNBC_CASFRI (cas_id);

ANALYSE diego_test.FNBC_CASFRI;

CREATE TABLE diego_test.FNBC_CASFRI_FNattribut AS
SELECT
    fnbc.*,
    fish.geom,
    fish.xy_id,
    fish.prov
FROM
    diego_test.FNBC_CASFRI AS fnbc
    LEFT JOIN (
        SELECT
            geom,
            xy_id,
            prov,
            fishnetid
        FROM
            diego_test.fishnet
    ) AS fish ON fnbc.fishnetid = fish.fishnetid;

-- 1.1.4
-- join it with casfri attributes 
-- parameters: filter : Layer=1

CREATE TABLE diego_test.FNBC_CASFRI_join1 AS
SELECT *
FROM diego_test.FNBC_CASFRI_FNattribut AS geo
    LEFT JOIN (SELECT cas_id AS lyr_cas_id, LAYER AS lyr_layer, LAYER_RANK AS lyr_layer_rank, SOIL_MOIST_REG AS lyr_SOIL_MOIST_REG, STRUCTURE_PER AS lyr_STRUCTURE_PER, STRUCTURE_RANGE, CROWN_CLOSURE_UPPER AS lyr_CROWN_CLOSURE_UPPER, CROWN_CLOSURE_LOWER AS lyr_CROWN_CLOSURE_LOWER, HEIGHT_UPPER AS lyr_HEIGHT_UPPER, HEIGHT_LOWER AS lyr_height_lower, PRODUCTIVITY, PRODUCTIVITY_TYPE,
    SPECIES_1, SPECIES_PER_1, SPECIES_2, SPECIES_PER_2, SPECIES_3, SPECIES_PER_3, SPECIES_4, SPECIES_PER_4, SPECIES_5, SPECIES_PER_5,
    ORIGIN_UPPER, ORIGIN_LOWER, SITE_CLASS, SITE_INDEX FROM casfri50.lyr_all WHERE layer = 1) lyr ON geo.cas_id= lyr.lyr_cas_id
    LEFT JOIN (SELECT cas_id AS nfl_cas_id, LAYER AS nfl_layer, layer_rank AS nfl_layer_rank, soil_moist_reg AS nfl_SOIL_MOIST_REG, structure_per AS nfl_STRUCTURE_PER, crown_closure_upper AS nfl_CROWN_CLOSURE_UPPER, crown_closure_lower AS nfl_CROWN_CLOSURE_LOWER, height_upper AS nfl_HEIGHT_UPPER, height_lower AS nfl_height_lower, nat_non_veg, non_for_anth, non_for_veg FROM casfri50.nfl_all WHERE layer = 1) nfl ON geo.cas_id= nfl.nfl_cas_id
    LEFT JOIN (SELECT cas_id AS cas_cas_id, inventory_id, stand_structure, num_of_layers, stand_photo_year FROM casfri50.cas_all) cas ON geo.cas_id = cas.cas_cas_id;


-- 1.1.5
--create index, and
--check the joined result
CREATE INDEX idx_FNBC_CASFRI_join_xy_id ON diego_test.FNBC_CASFRI_join (xy_id);

CREATE INDEX idx_FNBC_CASFRI_join_photo ON diego_test.FNBC_CASFRI_join (stand_photo_year);

SELECT
    *
FROM
    diego_test.FNBC_CASFRI_join
WHERE
    LEFT(cas_id, 2) NOT LIKE 'BC'
    AND LEFT(cas_id, 2) NOT LIKE 'PC'
LIMIT
    10




-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- (for BC province only)
-- Cuttig out useless area lying outside 'Hemiboreal' and 'Boreal' region 
-- retains sampling points only in boreal/hemiboreal region
-- can reduce total number of sampling point to half, and thus more efficient later processing
-- shapefile of 'Hemiboreal' and 'Boreal' region can be prepared in GIS software (which involves merging multi-polygon into single polygon for better processing performance
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- inner-joining the diego_test.FNBC_CASFRI_join table with boreal/hemiboreal sampling point, resulting diego_test.FNBC_CASFRI_join_boj

CREATE TABLE diego_test.FNBC_CASFRI_join_boj AS
SELECT change.*, boj.bo_type FROM diego_test.FNBC_CASFRI_join AS change
INNER JOIN (SELECT xy_id AS bo_xy_id, type AS bo_type 
FROM diego_test.fnbc_casfri_changedscas_boj_1f
WHERE type LIKE 'BOREAL' OR type LIKE 'HEMIBOREAL') boj ON boj.bo_xy_id = change.xy_id


-- left-joining diego_test.FNBC_CASFRI_join_boj with the shape of left/right sides of rocky mountain
CREATE TABLE diego_test.FNBC_CASFRI_join_bojLR AS
SELECT change.*,
    CASE 
        WHEN change.bo_type LIKE 'BOREAL' THEN rocky.side 
        ELSE NULL 
    END AS rocky_side
FROM diego_test.FNBC_CASFRI_join_boj AS change
LEFT JOIN diego_test.rocky_break AS rocky ON ST_INTERSECTS(rocky.geom, change.geom);

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1.2 since each sampling point can intersect multiple FRI layer
-- here we set up filtering criteria to choose 2 FRI layers for further analysis
-- 1st: the oldest FRI and the latest FRI (if only 2 epoques of FRI available)
-- 2nd: the 2nd oldest FRI and the lastest fRI (if more 2 epoques of FRI available), which happens currently for the BC province, we have FRI before 1970
-- add a flay '1' and '2' to the target FRI and extract them from FNBC_CASFRI_join to FNBC_CASFRI_join12
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 1.2.1
-- Add a field 'preferred_FRI' for selecting target FRI
-- create index for better performance
ALTER TABLE
    diego_test.FNBC_CASFRI_join
ADD
    preferred_FRI INTEGER;

CREATE INDEX idx_FNBC_CASFRI_join_bojew_xy_id ON diego_test.FNBC_CASFRI_join_bojew (xy_id);

-----------------------------------------------------------------------
-- add 1 to preferred_FRI column for oldest record : for provinces not including BC
-----------------------------------------------------------------------

WITH DuplicateRanks AS (
    SELECT ctid, cas_id,
           -- for BC inventory, ROW_NUMBER() OVER (PARTITION BY xy_id ORDER BY stand_photo_year ASC, cas_id ASC) AS rank,
           ROW_NUMBER() OVER (PARTITION BY xy_id ORDER BY ABS(1990-stand_photo_year) ASC, cas_id ASC) AS rank,
           COUNT(*) OVER (PARTITION BY xy_id) AS partition_count
    FROM diego_test.FNBC_CASFRI_join
    WHERE stand_photo_year >= 0 AND stand_photo_year IS NOT NULL
)
UPDATE diego_test.FNBC_CASFRI_join
SET preferred_FRI = 1
WHERE ctid IN (
    SELECT ctid
    FROM DuplicateRanks
    WHERE rank = 1 AND partition_count > 1
);


-----------------------------------------------------------------------
-- add 1 to preferred_FRI column for the second oldest FRI (>1970 if possible), for BC inventory
-----------------------------------------------------------------------

WITH DistinctYears AS (
    SELECT xy_id,
           COUNT(DISTINCT stand_photo_year) AS distinct_years_count
    FROM diego_test.FNBC_CASFRI_join_bojew
    GROUP BY xy_id
),
RankedRecords AS (
    SELECT a.ctid, a.cas_id, a.xy_id, a.stand_photo_year,
           DENSE_RANK() OVER (PARTITION BY a.xy_id ORDER BY a.stand_photo_year ASC) AS dense_rank,
           ROW_NUMBER() OVER (PARTITION BY a.xy_id, a.stand_photo_year ORDER BY a.cas_id ASC) AS cas_id_rank,
           d.distinct_years_count
    FROM diego_test.FNBC_CASFRI_join_bojew a
    JOIN DistinctYears d ON a.xy_id = d.xy_id
    WHERE a.stand_photo_year >= 0 AND a.stand_photo_year IS NOT NULL
)
UPDATE diego_test.FNBC_CASFRI_join_bojew b
SET preferred_FRI = CASE 
                        WHEN EXISTS (
                            SELECT 1
                            FROM RankedRecords r
                            WHERE b.ctid = r.ctid
                              AND ((r.distinct_years_count = 2 AND r.dense_rank = 1 AND r.cas_id_rank = 1) 
                                OR (r.distinct_years_count >= 3 AND r.dense_rank = 2 AND r.cas_id_rank = 1))
                         ) THEN 1
                        ELSE preferred_FRI
                     END;

-- checking
-- if the '1' is put correctly and only once 
SELECT xy_id, cas_id, stand_photo_year, lyr_cas_id, nfl_cas_id, preferred_FRI
FROM diego_test.FNBC_CASFRI_join_bojew
WHERE xy_id IN (
    SELECT xy_id
    FROM diego_test.FNBC_CASFRI_join_bojew
    GROUP BY xy_id
	HAVING COUNT(DISTINCT stand_photo_year) >2
)
order by xy_id, stand_photo_year
limit 100


----------------------------------------------------------------------------------------
--similarly on FRI2, on the latest FRI
----------------------------------------------------------------------------------------
WITH DuplicateRanks AS (
    SELECT ctid, cas_id,
           ROW_NUMBER() OVER (PARTITION BY xy_id ORDER BY stand_photo_year DESC, cas_id DESC) AS rank,
           COUNT(*) OVER (PARTITION BY xy_id) AS partition_count
    FROM diego_test.FNBC_CASFRI_join
    WHERE stand_photo_year >= 0 AND stand_photo_year IS NOT NULL
)
UPDATE diego_test.FNBC_CASFRI_join
SET preferred_FRI = 2
WHERE ctid IN (
    SELECT ctid
    FROM DuplicateRanks
    WHERE rank = 1 AND partition_count > 1
);


-- 1.2.2
-- Extract data with flag '1' or '2' to a new table
CREATE TABLE diego_test.FNBC_CASFRI_join12 AS ------ OR, FNBC_CASFRI_join12_bojew
SELECT
    *
FROM
    diego_test.FNBC_CASFRI_join
WHERE
    preferred_FRI IS NOT NULL CREATE INDEX idx_FNBC_join12_fishnetid ON diego_test.FNBC_CASFRI_join12 (fishnetid);

CREATE INDEX idx_FNBC_join12_cas_id ON diego_test.FNBC_CASFRI_join12 (cas_id);
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----- 1.3 attach disturbance records in CASFRI to result table
----- creating the blank columns, don't join disturbance records in CASFRI each FRI record
----- we can select the best disturbance record for further process
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- add column to the table FNBC_CASFRI_join12

ALTER TABLE diego_test.FNBC_CASFRI_join12
ADD DST_cas_id text,
ADD DST_layer integer,
ADD DIST_TYPE_1 text,
ADD DIST_YEAR_1 integer,
ADD DIST_EXT_UPPER_1 integer,
ADD DIST_EXT_LOWER_1 integer,
ADD DIST_TYPE_2 text,
ADD DIST_YEAR_2 integer,
ADD DIST_EXT_UPPER_2 integer,
ADD DIST_EXT_LOWER_2 integer,
ADD DIST_TYPE_3 text,
ADD DIST_YEAR_3 integer,
ADD DIST_EXT_UPPER_3 integer,
ADD DIST_EXT_LOWER_3 integer;


-- also to the table FNBC_CASFRI_join

ALTER TABLE diego_test.FNBC_CASFRI_join
ADD DST_cas_id text,
ADD DST_layer integer,
ADD DIST_TYPE_1 text,
ADD DIST_YEAR_1 integer,
ADD DIST_EXT_UPPER_1 integer,
ADD DIST_EXT_LOWER_1 integer,
ADD DIST_TYPE_2 text,
ADD DIST_YEAR_2 integer,
ADD DIST_EXT_UPPER_2 integer,
ADD DIST_EXT_LOWER_2 integer,
ADD DIST_TYPE_3 text,
ADD DIST_YEAR_3 integer,
ADD DIST_EXT_UPPER_3 integer,
ADD DIST_EXT_LOWER_3 integer;


-- extract disturbance records to the table FNBC_CASFRI_join
-- later we use algorithm to select the best records to use
UPDATE
    diego_test.FNBC_CASFRI_join as fnbc
SET
    DST_cas_id = dst.cas_id,
    DST_layer = dst.layer,
    DIST_TYPE_1 = dst.DIST_TYPE_1,
    DIST_YEAR_1 = dst.DIST_YEAR_1,
    DIST_EXT_UPPER_1 = dst.DIST_EXT_UPPER_1,
    DIST_EXT_LOWER_1 = dst.DIST_EXT_LOWER_1,
    DIST_TYPE_2 = dst.DIST_TYPE_2,
    DIST_YEAR_2 = dst.DIST_YEAR_2,
    DIST_EXT_UPPER_2 = dst.DIST_EXT_UPPER_2,
    DIST_EXT_LOWER_2 = dst.DIST_EXT_LOWER_2,
    DIST_TYPE_3 = dst.DIST_TYPE_3,
    DIST_YEAR_3 = dst.DIST_YEAR_3,
    DIST_EXT_UPPER_3 = dst.DIST_EXT_UPPER_3,
    DIST_EXT_LOWER_3 = dst.DIST_EXT_LOWER_3
FROM 
(SELECT * FROM casfri50.dst_all WHERE layer <2) dst
WHERE fnbc.cas_id = dst.cas_id;



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1.4. Self join the previously selected FRI, put them 'side-by-side'
-- rename the 2 FRIs with prefix 'first_' and 'second_'
-- delete the autogenerated duplicate records
-- table change from diego_test.FNBC_CASFRI_join12 to diego_test.FNBC_CASFRI_change 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE diego_test.FNBC_CASFRI_change AS
SELECT a.xy_id, a.geom, a.prov, a.cas_id AS first_cas_id, a.lyr_cas_id AS first_lyr_cas_id, a.lyr_LAYER AS first_layer, a.lyr_LAYER_RANK AS first_LAYER_RANK, a.lyr_SOIL_MOIST_REG AS first_SOIL_MOIST_REG, a.lyr_STRUCTURE_PER AS first_STRUCTURE_PER, a.STRUCTURE_RANGE AS first_STRUCTURE_RANGE,
    a.lyr_CROWN_CLOSURE_UPPER AS first_CROWN_CLOSURE_UPPER, a.lyr_CROWN_CLOSURE_LOWER AS first_CROWN_CLOSURE_LOWER, a.lyr_HEIGHT_UPPER AS first_HEIGHT_UPPER, a.lyr_HEIGHT_LOWER AS first_HEIGHT_LOWER, a.PRODUCTIVITY AS first_PRODUCTIVITY, a.PRODUCTIVITY_TYPE AS first_PRODUCTIVITY_TYPE,
    a.SPECIES_1 AS first_SPECIES_1, a.SPECIES_PER_1 AS first_SPECIES_PER_1, a.SPECIES_2 AS first_SPECIES_2, a.SPECIES_PER_2 AS first_SPECIES_PER_2, a.SPECIES_3 AS first_SPECIES_3, a.SPECIES_PER_3 AS first_SPECIES_PER_3,
    a.SPECIES_4 AS first_SPECIES_4, a.SPECIES_PER_4 AS first_SPECIES_PER_4, a.SPECIES_5 AS first_SPECIES_5, a.SPECIES_PER_5 AS first_SPECIES_PER_5, a.ORIGIN_UPPER AS first_ORIGIN_UPPER, a.ORIGIN_LOWER AS first_ORIGIN_LOWER, a.SITE_CLASS AS first_SITE_CLASS, a.SITE_INDEX AS first_SITE_INDEX, 
    a.nfl_cas_id AS first_nfl_cas_id, a.nfl_layer AS first_nfl_layer, a.nfl_layer_rank AS first_nfl_layer_rank, a.nfl_soil_moist_reg AS first_nfl_soil_moist_reg, a.nfl_structure_per AS first_nfl_structure_per, a.nfl_crown_closure_upper AS first_nfl_crown_closure_upper, a.nfl_crown_closure_lower AS first_nfl_crown_closure_lower,
    a.nfl_height_upper AS first_nfl_height_upper, a.nfl_height_lower AS first_nfl_height_lower, a.nat_non_veg AS first_nat_non_veg, a.non_for_anth AS first_non_for_anth, a.non_for_veg AS first_non_for_veg,
    a.dst_cas_id AS first_dst_cas_id, a.dst_layer AS first_dst_layer, a.DIST_TYPE_1 AS first_DIST_TYPE_1, a.DIST_YEAR_1 AS first_DIST_YEAR_1, a.DIST_EXT_UPPER_1 AS first_DIST_EXT_UPPER_1, a.DIST_EXT_LOWER_1 AS first_DIST_EXT_LOWER_1, a.DIST_TYPE_2 AS first_DIST_TYPE_2, a.DIST_YEAR_2 AS first_DIST_YEAR_2,
    a.DIST_EXT_UPPER_2 AS first_DIST_EXT_UPPER_2, a.DIST_EXT_LOWER_2 AS first_DIST_EXT_LOWER_2, a.DIST_TYPE_3 AS first_DIST_TYPE_3, a.DIST_YEAR_3 AS first_DIST_YEAR_3, a.DIST_EXT_UPPER_3 AS first_DIST_EXT_UPPER_3, a.DIST_EXT_LOWER_3 AS first_DIST_EXT_LOWER_3,
    a.cas_cas_id AS first_cas_cas_id, a.inventory_id AS first_inventory_id, a.stand_structure AS first_stand_structure, a.num_of_layers AS first_num_of_layers, a.stand_photo_year AS first_stand_photo_year,

    b.cas_id AS second_cas_id, b.lyr_cas_id AS second_lyr_cas_id, b.lyr_LAYER AS second_layer, b.lyr_LAYER_RANK AS second_LAYER_RANK, b.lyr_SOIL_MOIST_REG AS second_SOIL_MOIST_REG, b.lyr_STRUCTURE_PER AS second_STRUCTURE_PER, b.STRUCTURE_RANGE AS second_STRUCTURE_RANGE,
    b.lyr_CROWN_CLOSURE_UPPER AS second_CROWN_CLOSURE_UPPER, b.lyr_CROWN_CLOSURE_LOWER AS second_CROWN_CLOSURE_LOWER, b.lyr_HEIGHT_UPPER AS second_HEIGHT_UPPER, b.lyr_HEIGHT_LOWER AS second_HEIGHT_LOWER, b.PRODUCTIVITY AS second_PRODUCTIVITY, b.PRODUCTIVITY_TYPE AS second_PRODUCTIVITY_TYPE,
    b.SPECIES_1 AS second_SPECIES_1, b.SPECIES_PER_1 AS second_SPECIES_PER_1, b.SPECIES_2 AS second_SPECIES_2, b.SPECIES_PER_2 AS second_SPECIES_PER_2, b.SPECIES_3 AS second_SPECIES_3, b.SPECIES_PER_3 AS second_SPECIES_PER_3,
    b.SPECIES_4 AS second_SPECIES_4, b.SPECIES_PER_4 AS second_SPECIES_PER_4, b.SPECIES_5 AS second_SPECIES_5, b.SPECIES_PER_5 AS second_SPECIES_PER_5, b.ORIGIN_UPPER AS second_ORIGIN_UPPER, b.ORIGIN_LOWER AS second_ORIGIN_LOWER, b.SITE_CLASS AS second_SITE_CLASS, b.SITE_INDEX AS second_SITE_INDEX, 
    b.nfl_cas_id AS second_nfl_cas_id, b.nfl_layer AS second_nfl_layer, b.nfl_layer_rank AS second_nfl_layer_rank, b.nfl_soil_moist_reg AS second_nfl_soil_moist_reg, b.nfl_structure_per AS second_nfl_structure_per, b.nfl_crown_closure_upper AS second_nfl_crown_closure_upper, b.nfl_crown_closure_lower AS second_nfl_crown_closure_lower,
    b.nfl_height_upper AS second_nfl_height_upper, b.nfl_height_lower AS second_nfl_height_lower, b.nat_non_veg AS second_nat_non_veg, b.non_for_anth AS second_non_for_anth, b.non_for_veg AS second_non_for_veg,
    b.dst_cas_id AS second_dst_cas_id, b.dst_layer AS second_dst_layer, b.DIST_TYPE_1 AS second_DIST_TYPE_1, b.DIST_YEAR_1 AS second_DIST_YEAR_1, b.DIST_EXT_UPPER_1 AS second_DIST_EXT_UPPER_1, b.DIST_EXT_LOWER_1 AS second_DIST_EXT_LOWER_1, b.DIST_TYPE_2 AS second_DIST_TYPE_2, b.DIST_YEAR_2 AS second_DIST_YEAR_2,
    b.DIST_EXT_UPPER_2 AS second_DIST_EXT_UPPER_2, b.DIST_EXT_LOWER_2 AS second_DIST_EXT_LOWER_2, b.DIST_TYPE_3 AS second_DIST_TYPE_3, b.DIST_YEAR_3 AS second_DIST_YEAR_3, b.DIST_EXT_UPPER_3 AS second_DIST_EXT_UPPER_3, b.DIST_EXT_LOWER_3 AS second_DIST_EXT_LOWER_3,
    b.cas_cas_id AS second_cas_cas_id, b.inventory_id AS second_inventory_id, b.stand_structure AS second_stand_structure, b.num_of_layers AS second_num_of_layers, b.stand_photo_year AS second_stand_photo_year

FROM diego_test.FNBC_CASFRI_join12 a 
JOIN diego_test.FNBC_CASFRI_join12 b ON a.xy_id = b.xy_id AND a.cas_id != b.cas_id


-- check result
-- self-join create duplicate rows
SELECT xy_id, first_cas_id, first_inventory_id, first_stand_photo_year, second_cas_id, second_inventory_id, second_stand_photo_year
    FROM diego_test.FNBC_CASFRI_change
    order by xy_id


-- duplicates must be delete because self-join makes 2x repeat records with different orders
-- delete duplicates - by increasing first_stand_photo_year and increasing cas_id

WITH DuplicateRanks AS (
    SELECT ctid, 
           ROW_NUMBER() OVER (PARTITION BY xy_id ORDER BY first_stand_photo_year ASC, first_cas_id) as rank
    FROM diego_test.FNBC_CASFRI_change
)
DELETE FROM diego_test.FNBC_CASFRI_change
WHERE ctid IN (
    SELECT ctid
    FROM DuplicateRanks
    WHERE rank > 1
);


-- check result
-- self-join create duplicate rows

SELECT xy_id, first_cas_id, first_inventory_id, second_cas_id, second_inventory_id, (second_stand_photo_year - first_stand_photo_year) as diffYear
FROM diego_test.FNBC_CASFRI_change
order by xy_id
LIMIT 100


SELECT (second_stand_photo_year - first_stand_photo_year) as diffYear, count(*)
FROM diego_test.FNBC_CASFRI_change
group by diffYear
order by diffYear
LIMIT 100



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--1.5 join the change table with disturbance record (from remote sensing)
-- change from diego_test.FNBC_CASFRI_change to diego_test.FNBC_CASFRI_changeDS
-- one more self-join to transform DISTURBANCE ROW to DISTURBANCE COLUMN
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- create index on table, on the geometry
CREATE INDEX FNBC_CASFRI_change_geom_idx ON diego_test.FNBC_CASFRI_change USING gist (geom);

CREATE INDEX FNBC_CASFRI_change_xyid_idx ON diego_test.FNBC_CASFRI_change USING btree (xy_id);

CREATE INDEX ds02_wkb_geometry_geom_idx ON rawfri.ds02 USING gist (wkb_geometry);

CREATE INDEX ds03_wkb_geometry_geom_idx ON rawfri.ds03 USING gist (wkb_geometry);

analyse diego_test.FNBC_CASFRI_change
-- don't try to add the geometry in the resulting table
-- parameters: we use ST_intersects to join table

CREATE TABLE diego_test.FNBC_CASFRI_bojew_changeDS AS
SELECT 
    change.*,
    -- Excluding geometry columns from the SELECT list
    ds4.DIST_TYPE_BEAD AS DIST_TYPE_BEAD,
    ds1.DIST_TYPE_NFDB AS DIST_TYPE_NFDB, ds1.DIST_YEAR_NFDB AS DIST_YEAR_NFDB,
    ds2.DIST_TYPE_WnW AS DIST_TYPE_WnW, ds2.DIST_YEAR_WnW AS DIST_YEAR_WnW,
    ds3.DIST_TYPE_CanLad AS DIST_TYPE_CanLad, ds3.DIST_YEAR_CanLad AS DIST_YEAR_CanLad
FROM 
    diego_test.FNBC_CASFRI_bojew_change AS change
LEFT JOIN 
    (SELECT wkb_geometry AS DIST_BEAD_geom, class AS DIST_TYPE_BEAD FROM rawfri.ds04) ds4 
    ON ST_Intersects(ds4.DIST_BEAD_geom, ST_Transform(change.geom, 900914))
LEFT JOIN 
    (SELECT wkb_geometry AS DIST_NFDB_geom, 'BURN' AS DIST_TYPE_NFDB, year AS DIST_YEAR_NFDB FROM rawfri.ds01) ds1 
    ON ST_Intersects(ds1.DIST_NFDB_geom, ST_Transform(change.geom, 900914))
LEFT JOIN 
    (SELECT wkb_geometry AS DIST_WnW_geom, dist_type AS DIST_TYPE_WnW, dist_year AS DIST_YEAR_WnW FROM rawfri.ds02) ds2 
    ON ST_Intersects(ds2.DIST_WnW_geom, ST_Transform(change.geom, 900914))
LEFT JOIN 
    (SELECT wkb_geometry AS DIST_CanLad_geom, dist_type AS DIST_TYPE_CanLad, dist_year AS DIST_YEAR_CanLad FROM rawfri.ds03) ds3 
    ON ST_Intersects(ds3.DIST_CanLad_geom, ST_Transform(change.geom, 900914));

CREATE INDEX FNBC_CASFRI_changeds_xyid_idx ON diego_test.FNBC_CASFRI_changeds USING btree (xy_id);
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1.6 pick the DST records closest to 2015, but not later
-- join it to the result table 
--change from diego_test.FNBC_CASFRI_changeDS to diego_test.FNBC_CASFRI_changeDScas
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- from the full disturbance record sampled
-- based on the below algorithm we pick the best suited distance record
-- parameters: year closest to 2015, but not later than 2015
ALTER TABLE
    diego_test.FNBC_CASFRI_join
ADD
    preferred_DST integer;
    
WITH DuplicateRanks AS (
    SELECT ctid, cas_id,
           ROW_NUMBER() OVER (PARTITION BY xy_id ORDER BY (2015-DIST_YEAR_1) ASC, DIST_YEAR_2 DESC, DIST_YEAR_3 DESC) AS rank
    FROM diego_test.FNBC_CASFRI_join
    WHERE DIST_YEAR_1 >= 0 AND DIST_YEAR_1 IS NOT NULL AND DIST_YEAR_1 <= 2015
)
UPDATE diego_test.FNBC_CASFRI_join
SET preferred_DST = 3
WHERE ctid IN (
    SELECT ctid
    FROM DuplicateRanks
    WHERE rank = 1
);



-- 1.6.1 create the new change table joining CASFRI DST
CREATE TABLE diego_test.FNbc_CASFRI_changeDScas AS
SELECT
    *
FROM
    diego_test.FNbc_CASFRI_changeDS AS change
    LEFT JOIN (
        SELECT
            xy_id AS cas_xy_id,
            DIST_TYPE_1 AS DIST_casfri_type_1,
            DIST_YEAR_1 AS DIST_casfri_year_1,
            DIST_TYPE_2 AS DIST_casfri_type_2,
            DIST_YEAR_2 AS DIST_casfri_year_2,
            DIST_TYPE_3 AS DIST_casfri_type_3,
            DIST_YEAR_3 AS DIST_casfri_year_3
        FROM
            diego_test.FNbc_CASFRI_join
        where
            preferred_DST = 3
    ) AS cas ON cas.cas_xy_id = change.xy_id
-- DROP experimented columns wrongly added in previous steps
-- now only one disturbance record closest to 2015 kept

ALTER TABLE
    diego_test.FNBC_CASFRI_changeDScas DROP first_DST_cas_id,
    DROP first_DST_layer,
    DROP first_DIST_TYPE_1,
    DROP first_DIST_YEAR_1,
    DROP first_DIST_EXT_UPPER_1,
    DROP first_DIST_EXT_LOWER_1,
    DROP first_DIST_TYPE_2,
    DROP first_DIST_YEAR_2,
    DROP first_DIST_EXT_UPPER_2,
    DROP first_DIST_EXT_LOWER_2,
    DROP first_DIST_TYPE_3,
    DROP first_DIST_YEAR_3,
    DROP first_DIST_EXT_UPPER_3,
    DROP first_DIST_EXT_LOWER_3,
    DROP second_DST_cas_id,
    DROP second_DST_layer,
    DROP second_DIST_TYPE_1,
    DROP second_DIST_YEAR_1,
    DROP second_DIST_EXT_UPPER_1,
    DROP second_DIST_EXT_LOWER_1,
    DROP second_DIST_TYPE_2,
    DROP second_DIST_YEAR_2,
    DROP second_DIST_EXT_UPPER_2,
    DROP second_DIST_EXT_LOWER_2,
    DROP second_DIST_TYPE_3,
    DROP second_DIST_YEAR_3,
    DROP second_DIST_EXT_UPPER_3,
    DROP second_DIST_EXT_LOWER_3;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1.7 remove duplicates made by nfdb
-- since NFDB fire history contains lots of overlap polygon
-- rows are duplicated and must be deleted
-- change from diego_test.FNBC_CASFRI_changeDScas to diego_test.FNBC_CASFRI_changeDScas_1f
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- check duplicate

SELECT xy_id, count(dist_type_nfdb), count(dist_type_bead), count(dist_type_wnw), count(dist_casfri_type_1)
FROM diego_test.FNsk_CASFRI_changedscas
GROUP BY xy_id, dist_type_nfdb, dist_type_bead, dist_type_wnw, dist_casfri_type_1
HAVING COUNT(*) > 1
ORDER BY count(dist_type_nfdb) DESC


-- build another table, and delete from it
-- Criteria: Fire happend 1. before 2015, 2. cloest to 2015
CREATE TABLE diego_test.FNSK_CASFRI_changedscas_1f AS
SELECT * FROM diego_test.FNSK_CASFRI_changedscas;

WITH ClosestFire AS (
    SELECT ctid, 
           ROW_NUMBER() OVER (PARTITION BY xy_id ORDER BY abs(2015 - dist_year_nfdb) ASC) as rank
    FROM diego_test.FNSK_CASFRI_changedscas_1f
    WHERE dist_year_nfdb <= 2015
)
DELETE FROM diego_test.FNSK_CASFRI_changedscas_1f
WHERE ctid IN (
    SELECT ctid
    FROM ClosestFire
    WHERE rank <> 1
);


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1.8 further develop the nfdb records, by creating pivot full fire hiistory
-- this part is created when the full NFDB records are considered
-- change from diego_test.FNBC_CASFRI_changeDScas to diego_test.FNBC_CASFRI_changeDScas_pivotf
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 

-- from previous table, we extract all fire records on sampled points
-- extract them in a newly created fire_history table, column-wise instead row-wise
-- parameters: 9 records are created to hold the fire history


CREATE TABLE diego_test.FNMB_CASFRI_change_NFDB_fire_history AS
SELECT 
xy_id,
MAX(CASE WHEN rn = 1 THEN dist_year_nfdb END) AS dist_nfdb_year_1,
MAX(CASE WHEN rn = 2 THEN dist_year_nfdb END) AS dist_nfdb_year_2,
MAX(CASE WHEN rn = 3 THEN dist_year_nfdb END) AS dist_nfdb_year_3,
MAX(CASE WHEN rn = 4 THEN dist_year_nfdb END) AS dist_nfdb_year_4,
MAX(CASE WHEN rn = 5 THEN dist_year_nfdb END) AS dist_nfdb_year_5,
MAX(CASE WHEN rn = 6 THEN dist_year_nfdb END) AS dist_nfdb_year_6,
MAX(CASE WHEN rn = 7 THEN dist_year_nfdb END) AS dist_nfdb_year_7,
MAX(CASE WHEN rn = 8 THEN dist_year_nfdb END) AS dist_nfdb_year_8,
MAX(CASE WHEN rn = 9 THEN dist_year_nfdb END) AS dist_nfdb_year_9
FROM (
SELECT *,
        ROW_NUMBER() OVER (PARTITION BY xy_id ORDER BY dist_year_nfdb DESC) AS rn
  FROM (
        SELECT DISTINCT xy_id, dist_year_nfdb
        FROM diego_test.FNMB_CASFRI_changeDScas
        ) AS distinct_values
) AS numbered_values
GROUP BY xy_id;


-- Join column-wise full fire history to the change table

CREATE TABLE diego_test.FNMB_CASFRI_changedscas_fullf AS
SELECT
    noRepeat.*,
    pivot.dist_nfdb_year_1,
    pivot.dist_nfdb_year_2,
    pivot.dist_nfdb_year_3,
    pivot.dist_nfdb_year_4,
    pivot.dist_nfdb_year_5,
    pivot.dist_nfdb_year_6,
    pivot.dist_nfdb_year_7,
    pivot.dist_nfdb_year_8,
    pivot.dist_nfdb_year_9	
FROM
    diego_test.FNMB_CASFRI_changedscas_1f as noRepeat
JOIN
    diego_test.FNMB_CASFRI_change_NFDB_fire_history AS pivot ON noRepeat.xy_id = pivot.xy_id;


-- now the previous kept fire closest to 2015 is no longer be kept
ALTER TABLE
    diego_test.FNMB_CASFRI_changedscas_fullf DROP dist_type_nfdb DROP dist_year_nfdb;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 
-- Only for BC region
-- join with NaBoreal data, and sides of Rocky mountain
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 

-- create index
CREATE INDEX idx_FNBC_join12_xy_id ON diego_test.FNBC_CASFRI_join12_bojew (xy_id);

CREATE INDEX idx_FNBC_CASFRI_bojew_changedscas_fullf_xy_id ON diego_test.FNBC_CASFRI_bojew_changedscas_fullf (xy_id);

-- joining the 'boreal' and 'sides of rocky' attributes for BC province table
-- by xy_id, don't try to use ST_INTERSECTS

CREATE TABLE diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z AS
SELECT 
    change.*,
    bo.bo_TYPE,
	bo.rocky_side
FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf AS change
LEFT JOIN 
(SELECT xy_id AS bo_xy_id, bo_TYPE, rocky_side FROM diego_test.FNBC_CASFRI_join12_bojew WHERE preferred_FRI = 2) bo 
ON change.xy_id = bo.bo_xy_id

---------------------------------------------------------------------------------------
-- 1.9 final touch and extraction
---------------------------------------------------------------------------------------
-- add a geom column in WKT format, so that R(sf) can read a spatial join Tenure 

ALTER TABLE diego_test.FNBC_CASFRI_changeDScas_1f
ADD COLUMN geometry_wkt TEXT,
ADD COLUMN srs_id INTEGER;

UPDATE diego_test.FNBC_CASFRI_changeDScas_1f
SET geometry_wkt = ST_AsText(geom),
    srs_id = ST_SRID(geom);


-- extraction

COPY diego_test.FNBC_CASFRI_changeDScas_1f  TO 'E:/Diego/FNBC_CASFRI_changeDScas_1f.csv' DELIMITER ',' CSV HEADER;