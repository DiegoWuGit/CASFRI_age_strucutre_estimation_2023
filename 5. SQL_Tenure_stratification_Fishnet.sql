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
------ Module 5 
------ Stratify tenure statues to the change of FRI
------ Remarks: tenure 2020 layer is processed beforehand in GIS software, and is imported through GIS software 
------------------------------------------------------------------------------------------------------------------------------


-- 5.1 Prepation
-- intersects Tenure with fishnet, by ST_INTERSECTS

CREATE INDEX idx_fishnet_geom ON diego_test.fishnet USING btree (geom);
analyse diego_test.tenure2020
analyse diego_test.fishnet

CREATE TABLE diego_test.fnab_tenure2020 AS
SELECT fishnetid, xy_id, prov, gridcode, tenuretype
  FROM diego_test.tenure2020 tenure, diego_test.fishnet fish
  WHERE ST_Intersects(tenure.geom, fish.geom) AND fish.prov = 'AB';

CREATE INDEX idx_fnab_tenure2020_xy_id ON diego_test.fnab_tenure2020 (xy_id);
analyse diego_test.fnab_tenure2020



-- 5.2 join FRI with tenure
-- much more effective by xy_id, than with ST_INTERSECTS

CREATE INDEX idx_fnab_changedscas_fullf_age9015_xy_id ON diego_test.FNab_CASFRI_changedscas_fullf_age9015 (xy_id);
analyse diego_test.FNab_CASFRI_changedscas_fullf_age9015

CREATE TABLE diego_test.FNab_CASFRI_changedscas_fullf_age9015_ten AS
SELECT age.*, tenure.gridcode, tenure.tenuretype
FROM diego_test.FNab_CASFRI_changedscas_fullf_age9015 as age
LEFT JOIN diego_test.fnab_tenure2020 as tenure
ON age.xy_id  = tenure.xy_id;



-- 5.3 generate category statistics, group by tenureType

SELECT tenuretype, count(*)
FROM diego_test.FNab_CASFRI_changedscas_fullf_age9015_ten
WHERE second_stand_photo_year > first_stand_photo_year +5
GROUP BY tenuretype
ORDER BY count(*) DESC


-- 5.3 Inside the tenureType 'Tenure', generate age2015 per decade
-- unclassified chart in age 1990
SELECT
    FLOOR(age_1990 / 10) * 10 AS age_group,
    COUNT(*) AS count
FROM
    diego_test.FNmb_CASFRI_changedscas_fullf_age9015_ten
WHERE
    -- tenuretype LIKE '%tenure' 
    -- tenuretype LIKE 'protected_area'
    age_1990 > 0
    AND second_stand_photo_year > first_stand_photo_year + 5
GROUP BY
    FLOOR(age_1990 / 10) * 10
ORDER BY
    age_group ASC;


-- classified chart in age 2015
SELECT
    FLOOR(age_2015 / 10) * 10 AS age_group,
    COUNT(*) AS count
FROM
    diego_test.FNmb_CASFRI_changedscas_fullf_age9015_ten
WHERE
    tenuretype LIKE '%tenure' 
    -- tenuretype LIKE 'protected_area'
    AND age_2015 > 0
    AND second_stand_photo_year > first_stand_photo_year + 5
GROUP BY
    FLOOR(age_2015 / 10) * 10
ORDER BY
    age_group ASC;

