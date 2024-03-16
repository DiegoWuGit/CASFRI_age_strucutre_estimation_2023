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
------ Module 5.1 
------ Attribute insect effects to the change of FRI
------ The influence of Mountain Pine Beetle (IBM) is further inspected 
------------------------------------------------------------------------------------------------------------------------------

-- 5.1.1 join change table with raw FRI

CREATE INDEX idx_bc12_ogc_fid ON rawfri.bc12 (ogc_fid);
CREATE INDEX idx_hemi_age9015_second_cas_id ON diego_test.FNbc_CASFRI_changedscas_fullf_hemi_age9015 (second_cas_id);

CREATE TABLE diego_test.FNbc_CASFRI_changedscas_fullf_hemi_age9015_MPB_raw AS
SELECT 
    change.*, 
    insect.earliest_nonlogging_dist_type, 
    insect.earliest_nonlogging_dist_date, 
    insect.stand_percentage_dead
FROM 
    diego_test.FNbc_CASFRI_changedscas_fullf_hemi_age9015 AS change
INNER JOIN 
    rawfri.bc12 AS insect
ON 
    RIGHT(change.second_cas_id, 7) = LPAD(insect.ogc_fid::text, 7, 'x')
WHERE 
    change.dist_casfri_type_1 LIKE 'INSECT'



-- 5.1.2 find the highest pencentage of 'earliest_nonlogging_dist_type', which is 'IBM
SELECT  earliest_nonlogging_dist_type, count(*)
FROM diego_test.FNbc_CASFRI_changedscas_fullf_hemi_age9015_MPB_raw
GROUP by  earliest_nonlogging_dist_type
Order BY count(*) DESC


-- 5.1.3 the distribution of motality
SELECT  stand_percentage_dead, count(*)
FROM diego_test.FNbc_CASFRI_changedscas_fullf_hemi_age9015_MPB_raw
WHERE earliest_nonlogging_dist_type LIKE 'IBM'
GROUP by stand_percentage_dead


-- 5.1.3b time stamp of the FRI
SELECT  
  earliest_nonlogging_dist_date, 
  COUNT(*) AS count
FROM 
  diego_test.FNbc_CASFRI_changedscas_fullf_hemi_age9015_MPB_raw
WHERE 
  earliest_nonlogging_dist_type LIKE 'IBM' 
  AND EXTRACT(YEAR FROM earliest_nonlogging_dist_date) > 2000
GROUP BY 
  earliest_nonlogging_dist_date



--5.1.4 the mean mortality
WITH CTE AS (
    SELECT 
        stand_percentage_dead, 
        COUNT(*) AS count
    FROM 
        diego_test.FNbc_CASFRI_changedscas_fullf_hemi_age9015_MPB_raw
    WHERE 
        earliest_nonlogging_dist_type LIKE 'IBM'
    GROUP BY 
        stand_percentage_dead
)
SELECT 
    SUM(stand_percentage_dead * count) / SUM(count) AS weighted_mean
FROM 
    CTE;



--5.1.5 the standard d of distribution of mortality
-- Calculate the weighted mean first
WITH WeightedMean AS (
    SELECT SUM(stand_percentage_dead * count) / SUM(count) AS mean
    FROM (
        SELECT 
            stand_percentage_dead, 
            COUNT(*) AS count
        FROM diego_test.FNbc_CASFRI_changedscas_fullf_hemi_age9015_MPB_raw
        WHERE earliest_nonlogging_dist_type LIKE 'IBM'
        GROUP BY stand_percentage_dead
    ) AS Sub
),
-- Calculate squared differences based on the weighted mean
SquaredDifferences AS (
    SELECT 
        (stand_percentage_dead - (SELECT mean FROM WeightedMean))^2 AS squared_difference,
        COUNT(*) AS count
    FROM diego_test.FNbc_CASFRI_changedscas_fullf_hemi_age9015_MPB_raw
    WHERE earliest_nonlogging_dist_type LIKE 'IBM'
    GROUP BY stand_percentage_dead
),
-- Calculate variance using squared differences
Variance AS (
    SELECT 
        SUM(squared_difference * count) / SUM(count) AS variance
    FROM SquaredDifferences
)
-- Finally, calculate the standard deviation
SELECT 
    SQRT(SUM(variance)) AS standard_deviation
FROM Variance;

-----------------------------------------------------------------------------------------------------------------
--5.1.6 IBM is the deadiest non-logging disturbance above NULL and BW
SELECT earliest_nonlogging_dist_type, count(*), round(count(*)/(sum(count(*)) over ())*100,2) as percentage
FROM rawfri.bc12
WHERE stand_percentage_dead IS NOT NULL 
GROUP BY earliest_nonlogging_dist_type
ORDER bY count(*) DESC;


--5.1.7 IBM mortality / crown_closure / R=-0.7 
SELECT corr(stand_percentage_dead, l1_crown_closure) AS correlation_coefficient
FROM rawfri.bc12
WHERE earliest_nonlogging_dist_type LIKE 'IBM';


--5.1.7 IBM / tree_species / mainly PL, PLI, SX
SELECT earliest_nonlogging_dist_type, l1_species_cd_1, count(*), round(count(*)/(sum(count(*)) over ())*100,2) as percentage
FROM rawfri.bc12
WHERE earliest_nonlogging_dist_type LIKE 'IBM'
GROUP BY earliest_nonlogging_dist_type, l1_species_cd_1
ORDER bY count(*) DESC;


--5.1.8 Species composition in BC: BL(13.62), NULL(11.56), SX(9.28), PLI(7.77), SB(6.57) 
SELECT l1_species_cd_1, count(*), round(count(*)/(sum(count(*)) over ())*100,2) as percentage
FROM rawfri.bc12
--WHERE stand_percentage_dead IS NOT NULL 
GROUP BY l1_species_cd_1
ORDER bY count(*) DESC;
