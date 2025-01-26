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
------ Module 6 
------ Sample SQL command for generating gapYear plot, photoYear plot
------ while creating year line, on different tables
------------------------------------------------------------------------------------------------------------------------------


-- 6.1 photo year difference

with forest_change as (
SELECT *
FROM  diego_test.FNmb_CASFRI_changedscas_fullf_age9015
--WHERE first_PRODUCTIVITY IS NOT NULL AND second_PRODUCTIVITY IS NULL
WHERE second_stand_photo_year > first_stand_photo_year +5
--WHERE second_stand_photo_year > dist_year_wnw AND first_stand_photo_year < dist_year_wnw AND dist_type_wnw LIKE 'CUT'
--WHERE second_stand_photo_year > dist_year_nfdb AND first_stand_photo_year < dist_year_nfdb
)
SELECT (second_stand_photo_year - first_stand_photo_year) SK_Revisit_years, count(*) , SUM(COUNT(*)) OVER ()
FROM forest_change
group by SK_Revisit_years
ORDER BY SK_Revisit_years ASC


-- 6.2 put all counts of 4 provinces columns-wise

WITH HEMIBOREAL_INSECT AS
(SELECT dist_casfri_year_1, count(dist_casfri_year_1) as HEMIBOREAL_INSECT
FROM diego_test.FNmb_CASFRI_changedscas_fullf_age9015
WHERE type LIKE 'HEMIBOREAL'
GROUP by dist_casfri_year_1),
BOREAL_INSECT AS
(SELECT dist_casfri_year_1, count(dist_casfri_year_1) as BOREAL_INSECT
FROM diego_test.FNmb_CASFRI_changedscas_fullf_age9015
WHERE type LIKE 'BOREAL'
GROUP by dist_casfri_year_1)

SELECT *
FROM HEMIBOREAL_INSECT
full join BOREAL_INSECT on HEMIBOREAL_INSECT.dist_casfri_year_1 = BOREAL_INSECT.dist_casfri_year_1
WHERE HEMIBOREAL_INSECT.dist_casfri_year_1 > 1990 AND HEMIBOREAL_INSECT.dist_casfri_year_1 < 2020


-- 6.3 year plot, coloured by 1/2 FRI of each province

WITH FRI1 AS (
SELECT first_stand_photo_year AS year, COUNT(*) AS first_FRI_count
FROM diego_test.FNmb_CASFRI_changedscas_fullf_age9015
WHERE second_stand_photo_year > first_stand_photo_year + 5
GROUP BY first_stand_photo_year
), FRI2 AS (
SELECT second_stand_photo_year AS year, COUNT(*) AS second_FRI_count
FROM diego_test.FNmb_CASFRI_changedscas_fullf_age9015
WHERE second_stand_photo_year > first_stand_photo_year + 5
GROUP BY second_stand_photo_year
)
SELECT 
  COALESCE(FRI1.year, FRI2.year) AS year,
  COALESCE(first_FRI_count, 0) AS first_FRI_count,
  COALESCE(second_FRI_count, 0) AS second_FRI_count
FROM FRI1
FULL OUTER JOIN FRI2 ON FRI1.year = FRI2.year
ORDER BY year;


-- 6.4 Gap-year plot, coloured by 4 different provinces in four tables
  
WITH BC_year AS
(SELECT (second_stand_photo_year-first_stand_photo_year) as year_bc, count(*) as BC
FROM diego_test.FNmb_CASFRI_changedscas_fullf_age9015
GROUP BY year_bc
),
AB_year AS
(SELECT (second_stand_photo_year-first_stand_photo_year) as year_ab, count(*) as AB
FROM diego_test.fnab_CASFRI_changedscas_1f
GROUP BY year_ab
),
SK_year AS
(SELECT (second_stand_photo_year-first_stand_photo_year) as year_sk, count(*) as SK
FROM diego_test.fnsk_CASFRI_changedscas_1f
GROUP BY year_sk
),
MB_year AS
(SELECT (second_stand_photo_year-first_stand_photo_year) as year_mb, count(*) as MB
FROM  diego_test.fnmb_CASFRI_changedscas_1f
GROUP BY year_mb
)
SELECT *
FROM BC_year
full join AB_year on BC_year.year_bc = AB_year.year_ab
full join SK_year on BC_year.year_bc = SK_year.year_sk
full join MB_year on BC_year.year_bc = MB_year.year_mb
ORDER BY AB_year ASC



-- 6.5 Gap-year plot, coloured by 4 different forest categories in one table

WITH BC_LYR AS
(SELECT (second_stand_photo_year-first_stand_photo_year) as year_lyr, count(*) as LYR
FROM diego_test.FNmb_CASFRI_changedscas_fullf_age9015
WHERE second_stand_photo_year > first_stand_photo_year + 5 AND
first_PRODUCTIVITY IS NOT NULL AND second_PRODUCTIVITY IS NOT NULL
GROUP BY year_lyr
),
BC_NFL AS
(SELECT (second_stand_photo_year-first_stand_photo_year) as year_nfl, count(*) as NFL
FROM diego_test.FNmb_CASFRI_changedscas_fullf_age9015
WHERE second_stand_photo_year > first_stand_photo_year + 5 AND
first_PRODUCTIVITY IS NOT NULL AND (second_PRODUCTIVITY IS NULL AND second_non_for_veg IS NOT NULL AND second_non_for_veg NOT like 'NOT_APPLICABLE')
GROUP BY year_nfl
),
BC_WaterRocks AS
(SELECT (second_stand_photo_year-first_stand_photo_year) as year_waterrocks, count(*) as WaterRocks
FROM diego_test.FNmb_CASFRI_changedscas_fullf_age9015
WHERE second_stand_photo_year > first_stand_photo_year + 5 AND
first_PRODUCTIVITY IS NOT NULL AND (second_PRODUCTIVITY IS NULL AND second_nat_non_veg IS NOT NULL AND second_nat_non_veg NOT like 'NOT_APPLICABLE')
GROUP BY year_waterrocks
),
BC_Others AS
(SELECT (second_stand_photo_year-first_stand_photo_year) as year_others, count(*) as Others
FROM diego_test.FNmb_CASFRI_changedscas_fullf_age9015
WHERE second_stand_photo_year > first_stand_photo_year + 5 AND
first_PRODUCTIVITY IS NOT NULL AND (second_PRODUCTIVITY IS NULL AND second_non_for_veg IS NULL AND second_nat_non_veg IS NULL)
GROUP BY year_others
)
SELECT COALESCE(BC_LYR.year_lyr, BC_NFL.year_nfl, BC_WaterRocks.year_waterrocks, BC_others.year_others) AS year, *
FROM BC_LYR
full join BC_NFL on BC_LYR.year_lyr = BC_NFL.year_nfl
full join BC_WaterRocks on BC_LYR.year_lyr = BC_WaterRocks.year_waterrocks
full join BC_Others on BC_LYR.year_lyr = BC_Others.year_others
ORDER BY year ASC


-- 6.6 Number of sampling points stratified by Tenure in all regions
SELECT mb.tenuretype, mb.count_MB, COALESCE(sk.count_SK, 0) AS count_SK, COALESCE(ab.count_AB, 0) AS count_AB,
COALESCE(BChemi.count_BChemi, 0) AS count_BChemi, COALESCE(BCbore.count_BCbore, 0) AS count_BCbore
FROM (
  SELECT tenuretype, COUNT(*) AS count_MB
  FROM diego_test.FNmb_CASFRI_changedscas_fullf_age9015_ten
  GROUP BY tenuretype
) mb
LEFT JOIN (
  SELECT tenuretype, COUNT(*) AS count_SK
  FROM diego_test.FNsk_CASFRI_changedscas_fullf_age9015_ten
  GROUP BY tenuretype
) sk ON mb.tenuretype = sk.tenuretype
LEFT JOIN (
  SELECT tenuretype, COUNT(*) AS count_AB
  FROM diego_test.FNab_CASFRI_changedscas_fullf_age9015_ten
  GROUP BY tenuretype
) ab ON mb.tenuretype = ab.tenuretype
LEFT JOIN (
  SELECT tenuretype, COUNT(*) AS count_BChemi
  FROM diego_test.FNbc_CASFRI_changedscas_fullf_hemi_age9015_ten
  GROUP BY tenuretype
) BChemi ON mb.tenuretype = bchemi.tenuretype
LEFT JOIN (
  SELECT tenuretype, COUNT(*) AS count_BCbore
  FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015_ten
  GROUP BY tenuretype
) BCbore ON mb.tenuretype = bcbore.tenuretype
ORDER BY count_MB DESC;


-- 6.7 Age 2015 plots in Protected area
WITH age_groups AS (
  SELECT FLOOR(age_2015 / 10) * 10 AS age_interval,
         COUNT(*) AS count,
         SUM(COUNT(*)) OVER () AS total_count
  FROM diego_test.FNsk_CASFRI_changedscas_fullf_age9015_ten
  WHERE tenuretype LIKE 'protected_area' AND age_2015 IS NOT NULL
  GROUP BY FLOOR(age_2015 / 10)
)
SELECT age_interval AS age_group_start,
       age_interval + 9 AS age_group_end,
       count,
       (count::FLOAT / total_count) * 100 AS percentage
FROM age_groups
ORDER BY age_interval;





