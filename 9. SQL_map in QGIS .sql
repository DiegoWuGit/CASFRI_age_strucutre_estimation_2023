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
------ Module 9 
------ Attributs disturbance to changes of states of forest
------ 
------ Visulatisation on maps
------------------------------------------------------------------------------------------------------------------------------
-- double temporal coverage map

SELECT geom, first_cas_id, first_productivity, first_nat_non_veg, first_non_for_veg, second_cas_id, second_productivity, second_nat_non_veg, second_non_for_veg
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
WHERE first_stand_photo_year +5 < second_stand_photo_year

UNION ALL
SELECT geom, first_cas_id, first_productivity, first_nat_non_veg, first_non_for_veg, second_cas_id, second_productivity, second_nat_non_veg, second_non_for_veg
FROM diego_test.FNbc_CASFRI_changedscas_fullf_hemi_age9015
WHERE first_stand_photo_year +5 < second_stand_photo_year

UNION ALL
SELECT geom, first_cas_id, first_productivity, first_nat_non_veg, first_non_for_veg, second_cas_id, second_productivity, second_nat_non_veg, second_non_for_veg
FROM diego_test.FNab_CASFRI_changedscas_fullf_age9015
WHERE first_stand_photo_year +5 < second_stand_photo_year

UNION ALL
SELECT geom, first_cas_id, first_productivity, first_nat_non_veg, first_non_for_veg, second_cas_id, second_productivity, second_nat_non_veg, second_non_for_veg
FROM diego_test.FNsk_CASFRI_changedscas_fullf_age9015
WHERE first_stand_photo_year +5 < second_stand_photo_year

UNION ALL
SELECT geom, first_cas_id, first_productivity, first_nat_non_veg, first_non_for_veg, second_cas_id, second_productivity, second_nat_non_veg, second_non_for_veg
FROM diego_test.FNmb_CASFRI_changedscas_fullf_age9015
WHERE first_stand_photo_year +5 < second_stand_photo_year
AND	(LEFT(second_cas_id, 4) NOT IN ('MB04', 'MB01', 'MB02') AND LEFT(first_cas_id, 4) NOT IN ('MB04', 'MB01', 'MB02')) -- for removing error MB area
AND NOT (first_cat LIKE 'Others' AND first_non_for_anth IS NULL)                                                           -- for removing error MB area
AND NOT (second_cat LIKE 'Others' AND second_non_for_anth IS NULL)                                                         -- for removing error MB area

*************************************************************************************************************************************************************

-- single temporal coverage map
SELECT geom
FROM "diego_test"."fnbc_casfri_join" 

UNION ALL
SELECT geom
FROM "diego_test"."fnab_casfri_join" 

UNION ALL
SELECT geom
FROM "diego_test"."fnsk_casfri_join" 

UNION ALL
SELECT geom
FROM "diego_test"."fnmb_casfri_join" 

*************************************************************************************************************************************************************
--age change map

SELECT (age_2015-age_1990) as ageChange, geom
FROM diego_test.FNsk_CASFRI_changedscas_fullf_age9015
WHERE (first_cat LIKE 'NFL' OR first_cat LIKE 'Others' OR first_cat LIKE 'LYR') AND second_cat LIKE 'LYR'
AND second_stand_photo_year > first_stand_photo_year +5

UNION ALL
SELECT (age_2015-age_1990), geom
FROM diego_test.FNAB_CASFRI_changedscas_fullf_age9015
WHERE (first_cat LIKE 'NFL' OR first_cat LIKE 'Others' OR first_cat LIKE 'LYR') AND second_cat LIKE 'LYR'
AND second_stand_photo_year > first_stand_photo_year +5

UNION ALL
SELECT (age_2015-age_1990), geom
FROM diego_test.FNmb_CASFRI_changedscas_fullf_age9015
WHERE (first_cat LIKE 'NFL' OR first_cat LIKE 'Others' OR first_cat LIKE 'LYR') AND second_cat LIKE 'LYR'
AND second_stand_photo_year > first_stand_photo_year +5

UNION ALL
SELECT (age_2015-age_1990), geom
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
WHERE (first_cat LIKE 'NFL' OR first_cat LIKE 'Others' OR first_cat LIKE 'LYR') AND second_cat LIKE 'LYR'
AND second_stand_photo_year > first_stand_photo_year +5

UNION ALL
SELECT (age_2015-age_1990), geom
FROM diego_test.FNbc_CASFRI_changedscas_fullf_hemi_age9015
WHERE (first_cat LIKE 'NFL' OR first_cat LIKE 'Others' OR first_cat LIKE 'LYR') AND second_cat LIKE 'LYR'
AND second_stand_photo_year > first_stand_photo_year +5
*************************************************************************************************************************************************************
--age map age 1990
SELECT age_1990, geom
FROM diego_test.FNsk_CASFRI_changedscas_fullf_age9015
WHERE second_stand_photo_year > first_stand_photo_year +5

UNION ALL
SELECT age_1990, geom
FROM diego_test.FNAB_CASFRI_changedscas_fullf_age9015
WHERE second_stand_photo_year > first_stand_photo_year +5

UNION ALL
SELECT age_1990, geom
FROM diego_test.FNmb_CASFRI_changedscas_fullf_age9015
WHERE second_stand_photo_year > first_stand_photo_year +5
AND	(LEFT(second_cas_id, 4) NOT IN ('MB04', 'MB01', 'MB02') AND LEFT(first_cas_id, 4) NOT IN ('MB04', 'MB01', 'MB02')) 
AND NOT (first_cat LIKE 'Others' AND first_non_for_anth IS NULL)                                                          
AND NOT (second_cat LIKE 'Others' AND second_non_for_anth IS NULL)   

UNION ALL
SELECT age_1990, geom
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
WHERE second_stand_photo_year > first_stand_photo_year +5

UNION ALL
SELECT age_1990, geom
FROM diego_test.FNbc_CASFRI_changedscas_fullf_hemi_age9015
WHERE second_stand_photo_year > first_stand_photo_year +5

*************************************************************************************************************************************************************
-- error region map in MB, including MB01, 02, 04

--error area
SELECT * FROM "diego_test"."fnmb_casfri_changedscas_fullf_age9015"
WHERE(LEFT(second_cas_id, 4) IN ('MB04', 'MB01', 'MB02') OR LEFT(first_cas_id, 4) IN ('MB04', 'MB01', 'MB02'))
AND second_stand_photo_year > first_stand_photo_year + 5
AND (first_cat LIKE 'Others' OR second_cat LIKE 'Others')


--area not including error area
SELECT * FROM "diego_test"."fnmb_casfri_changedscas_fullf_age9015"
WHERE(LEFT(second_cas_id, 4) NOT IN ('MB04', 'MB01', 'MB02') AND LEFT(first_cas_id, 4) NOT IN ('MB04', 'MB01', 'MB02'))
AND second_stand_photo_year > first_stand_photo_year + 5
AND (first_cat NOT LIKE 'Others' AND second_cat NOT LIKE 'Others')

*************************************************************************************************************************************************************
-- 'Others'(Antropogenic disturbance / error) map region in SK

SELECT * FROM "diego_test"."fnsk_casfri_changedscas_fullf_age9015" 
WHERE (first_cat LIKE 'Others' OR second_cat LIKE 'Others')
AND second_stand_photo_year > first_stand_photo_year +5

*************************************************************************************************************************************************************
--identify 'INSECTS' region in BC, so do the 'IBM, and the 'mortality' of IBM

SELECT geom,dist_casfri_type_1,dist_casfri_year_1 FROM "diego_test"."fnbc_casfri_changedscas_fullf_hemi_age9015" 
WHERE dist_casfri_type_1 LIKE 'INSECT' AND dist_casfri_year_1 between 1985 AND 2020 
AND second_stand_photo_year > first_stand_photo_year +5
UNION ALL
SELECT geom,dist_casfri_type_1,dist_casfri_year_1 FROM "diego_test"."fnbc_casfri_changedscas_fullf_bore_age9015" 
WHERE dist_casfri_type_1 LIKE 'INSECT' AND dist_casfri_year_1 between 1985 AND 2020 
AND second_stand_photo_year > first_stand_photo_year +5


SELECT geom, stand_percentage_dead
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015_MPB_raw
WHERE earliest_nonlogging_dist_type LIKE 'IBM'

SELECT geom, stand_percentage_dead
FROM diego_test.FNbc_CASFRI_changedscas_fullf_hemi_age9015_MPB_raw
WHERE earliest_nonlogging_dist_type LIKE 'IBM'

*************************************************************************************************************************************************************
--identify BEAD disturbed regions

SELECT dist_type_bead, geom FROM "diego_test"."fnbc_casfri_changedscas_fullf_bore_age9015" 
WHERE dist_type_bead IS NOT NULL AND
second_stand_photo_year > first_stand_photo_year +5
UNION ALL
SELECT dist_type_bead, geom FROM "diego_test"."fnbc_casfri_changedscas_fullf_bore_age9015" 
WHERE dist_type_bead IS NOT NULL AND
second_stand_photo_year > first_stand_photo_year +5
UNION ALL
SELECT dist_type_bead, geom FROM "diego_test"."fnab_casfri_changedscas_fullf_age9015" 
WHERE dist_type_bead IS NOT NULL AND
second_stand_photo_year > first_stand_photo_year +5
UNION ALL
SELECT dist_type_bead, geom FROM "diego_test"."fnsk_casfri_changedscas_fullf_age9015" 
WHERE dist_type_bead IS NOT NULL AND
second_stand_photo_year > first_stand_photo_year +5
UNION ALL
SELECT dist_type_bead, geom FROM "diego_test"."fnsk_casfri_changedscas_fullf_age9015" 
WHERE dist_type_bead IS NOT NULL AND
second_stand_photo_year > first_stand_photo_year +5


-- so do the statistics of states of forest changed, not by Cutblock
WITH BEAD AS (
SELECT first_cat, second_cat, dist_type_bead, geom FROM "diego_test"."fnbc_casfri_changedscas_fullf_bore_age9015" 
WHERE dist_type_bead IS NOT NULL AND dist_type_bead NOT LIKE 'Cutblock' AND 
second_stand_photo_year > first_stand_photo_year +5
UNION ALL
SELECT first_cat, second_cat, dist_type_bead, geom FROM "diego_test"."fnbc_casfri_changedscas_fullf_bore_age9015" 
WHERE dist_type_bead IS NOT NULL AND dist_type_bead NOT LIKE 'Cutblock' AND 
second_stand_photo_year > first_stand_photo_year +5
UNION ALL
SELECT first_cat, second_cat, dist_type_bead, geom FROM "diego_test"."fnab_casfri_changedscas_fullf_age9015" 
WHERE dist_type_bead IS NOT NULL AND dist_type_bead NOT LIKE 'Cutblock' AND 
second_stand_photo_year > first_stand_photo_year +5
UNION ALL
SELECT first_cat, second_cat, dist_type_bead, geom FROM "diego_test"."fnsk_casfri_changedscas_fullf_age9015" 
WHERE dist_type_bead IS NOT NULL AND dist_type_bead NOT LIKE 'Cutblock' AND 
second_stand_photo_year > first_stand_photo_year +5
UNION ALL
SELECT first_cat, second_cat, dist_type_bead, geom FROM "diego_test"."fnsk_casfri_changedscas_fullf_age9015" 
WHERE dist_type_bead IS NOT NULL AND dist_type_bead NOT LIKE 'Cutblock' AND 
second_stand_photo_year > first_stand_photo_year +5 )

SELECT first_cat, second_cat, count(*)
FROM BEAD
GROUP BY first_cat, second_cat
*************************************************************************************************************************************************************
-- in CASFRI the statistics of states of forest changed, not by Cutblock -- result not interesting
WITH CASFRI_DST AS (
SELECT first_cat, second_cat, dist_casfri_type_1, geom FROM "diego_test"."fnbc_casfri_changedscas_fullf_bore_age9015" 
WHERE dist_type_bead IS NOT NULL AND dist_casfri_type_1 NOT LIKE 'CUT' AND dist_casfri_type_1 NOT LIKE 'BURN' AND
second_stand_photo_year > first_stand_photo_year +5
UNION ALL
SELECT first_cat, second_cat, dist_casfri_type_1, geom FROM "diego_test"."fnbc_casfri_changedscas_fullf_bore_age9015" 
WHERE dist_type_bead IS NOT NULL AND dist_casfri_type_1 NOT LIKE 'CUT' AND dist_casfri_type_1 NOT LIKE 'BURN' AND
second_stand_photo_year > first_stand_photo_year +5
UNION ALL
SELECT first_cat, second_cat, dist_casfri_type_1, geom FROM "diego_test"."fnab_casfri_changedscas_fullf_age9015" 
WHERE dist_type_bead IS NOT NULL AND dist_casfri_type_1 NOT LIKE 'CUT' AND dist_casfri_type_1 NOT LIKE 'BURN' AND
second_stand_photo_year > first_stand_photo_year +5
UNION ALL
SELECT first_cat, second_cat, dist_casfri_type_1, geom FROM "diego_test"."fnsk_casfri_changedscas_fullf_age9015" 
WHERE dist_type_bead IS NOT NULL AND dist_casfri_type_1 NOT LIKE 'CUT' AND dist_casfri_type_1 NOT LIKE 'BURN' AND
second_stand_photo_year > first_stand_photo_year +5
UNION ALL
SELECT first_cat, second_cat, dist_casfri_type_1, geom FROM "diego_test"."fnsk_casfri_changedscas_fullf_age9015" 
WHERE dist_type_bead IS NOT NULL AND dist_casfri_type_1 NOT LIKE 'CUT' AND dist_casfri_type_1 NOT LIKE 'BURN' AND
second_stand_photo_year > first_stand_photo_year +5 )

SELECT first_cat, second_cat, dist_casfri_type_1, count(*)
FROM CASFRI_DST 
GROUP BY first_cat, second_cat, dist_casfri_type_1
ORDER BY count(*) DESC

*************************************************************************************************************************************************************
-- cut region in boread BC, using all 3 external cut sources, time-frame 1985-2015, animation

SELECT dist_casfri_type_1, greatest(dist_casfri_year_1, dist_year_wnw, dist_year_canlad) AS result, geom FROM "diego_test"."fnbc_casfri_changedscas_fullf_bore_age9015" 
WHERE (dist_casfri_type_1 LIKE 'CUT' OR dist_type_wnw LIKE 'CUT' OR dist_type_canlad =2) AND dist_casfri_year_1 between 1985 AND 2015 AND dist_year_wnw <= 2015 AND
second_stand_photo_year > first_stand_photo_year +5

UNION ALL
SELECT dist_casfri_type_1, greatest(dist_casfri_year_1, dist_year_wnw, dist_year_canlad) AS result, geom FROM "diego_test"."fnbc_casfri_changedscas_fullf_hemi_age9015" 
WHERE (dist_casfri_type_1 LIKE 'CUT' OR dist_type_wnw LIKE 'CUT' OR dist_type_canlad =2) AND dist_casfri_year_1 between 1985 AND 2015 AND dist_year_wnw <= 2015 AND
second_stand_photo_year > first_stand_photo_year +5

UNION ALL
SELECT dist_casfri_type_1, greatest(dist_casfri_year_1, dist_year_wnw, dist_year_canlad) AS result, geom FROM "diego_test"."fnab_casfri_changedscas_fullf_age9015" 
WHERE (dist_casfri_type_1 LIKE 'CUT' OR dist_type_wnw LIKE 'CUT' OR dist_type_canlad =2) AND dist_casfri_year_1 between 1985 AND 2015 AND dist_year_wnw <= 2015 AND
second_stand_photo_year > first_stand_photo_year +5

UNION ALL
SELECT dist_casfri_type_1, greatest(dist_casfri_year_1, dist_year_wnw, dist_year_canlad) AS result, geom FROM "diego_test"."fnsk_casfri_changedscas_fullf_age9015" 
WHERE (dist_casfri_type_1 LIKE 'CUT' OR dist_type_wnw LIKE 'CUT' OR dist_type_canlad =2) AND dist_casfri_year_1 between 1985 AND 2015 AND dist_year_wnw <= 2015 AND
second_stand_photo_year > first_stand_photo_year +5 

*************************************************************************************************************************************************************
-- region in boread BC, change from WaterAndRocks to LYR, cross-check with Tenure 2020 data

SELECT * FROM
"diego_test"."fnbc_casfri_changedscas_fullf_bore_age9015_ten" 
WHERE second_stand_photo_year > first_stand_photo_year +5
AND first_cat LIKE 'WaterAndRocks' AND second_cat LIKE 'LYR'
AND gridcode <> 100

-- percentage of 'ALPINE' which leads the change of states of forest
SELECT first_nat_non_veg , count(*), round(count(*)/ SUM(COUNT(*)) OVER () * 100,2) AS percentage
FROM "diego_test"."fnbc_casfri_changedscas_fullf_bore_age9015_ten" 
WHERE second_stand_photo_year > first_stand_photo_year +5
AND first_cat LIKE 'WaterAndRocks' AND second_cat LIKE 'LYR'
GROUP BY first_nat_non_veg








