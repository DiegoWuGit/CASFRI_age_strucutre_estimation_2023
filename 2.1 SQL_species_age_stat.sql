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
------ Module 2.1 
------ Calculate mean species age, in each province
------ while grouping different naming of species into bigger group for simpler interpretation
------ (this script for all regions except BC, where contains more species)
------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE diego_test.FNsk_CASFRI_change_species_age AS

WITH mb_ABIE AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_ABIE_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'ABIE%' AND first_origin_upper >0 AND second_stand_photo_year > first_stand_photo_year +5), 
mb_ACER AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_ACER_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'ACER%' AND first_origin_upper >0 AND second_stand_photo_year > first_stand_photo_year +5),
mb_BETU AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_BETU_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'BETU%' AND first_origin_upper >0 AND second_stand_photo_year > first_stand_photo_year +5),
mb_LARI AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_LARI_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'LARI%' AND first_origin_upper >0 AND second_stand_photo_year > first_stand_photo_year +5),
mb_PICE_ENG AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_PICE_ENG_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'PICE_ENG%' AND first_origin_upper >0 AND second_stand_photo_year > first_stand_photo_year +5),
mb_PICE_GLA AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_PICE_GLA_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'PICE_GLA%' AND first_origin_upper >0 AND second_stand_photo_year > first_stand_photo_year +5),
mb_PICE_MAR AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_PICE_MAR_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'PICE_MAR%' AND first_origin_upper >0 AND second_stand_photo_year > first_stand_photo_year +5),
mb_PINU_BAN AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_PINU_BAN_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'PINU_BAN%' AND first_origin_upper >0 AND second_stand_photo_year > first_stand_photo_year +5),
mb_PINU_CON AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_PINU_CON_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'PINU_CON%' AND first_origin_upper >0 AND second_stand_photo_year > first_stand_photo_year +5),
mb_PINU_SPP AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_PINU_SPP_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'PINU_SPP%' AND first_origin_upper >0 AND second_stand_photo_year > first_stand_photo_year +5),
mb_POPU_BAL AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_POPU_BAL_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'POPU_BAL%' AND first_origin_upper >0 AND second_stand_photo_year > first_stand_photo_year +5),
mb_POPU_TRE AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_POPU_TRE_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'POPU_TRE%' AND first_origin_upper >0 AND second_stand_photo_year > first_stand_photo_year +5),
mb_ULMU_AME AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_ULMU_AME_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'ULMU_AME%' AND first_origin_upper >0 AND second_stand_photo_year > first_stand_photo_year +5)

SELECT
    'ABIE' as species,
	round(AVG(mb_ABIE_mean)) AS mean,
    round(STDDEV(mb_ABIE_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_ABIE
UNION ALL
SELECT
    'ACER' as species,
	round(AVG(mb_ACER_mean)) AS mean,
    round(STDDEV(mb_ACER_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_ACER
UNION ALL
SELECT
    'BETU' as species,
	round(AVG(mb_BETU_mean)) AS mean,
    round(STDDEV(mb_BETU_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_BETU
UNION ALL
SELECT
    'LARI' as species,
	round(AVG(mb_LARI_mean)) AS mean,
    round(STDDEV(mb_LARI_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_LARI
UNION ALL
SELECT
    'PICE_ENG' as species,
	round(AVG(mb_PICE_ENG_mean)) AS mean,
    round(STDDEV(mb_PICE_ENG_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_PICE_ENG
UNION ALL
SELECT
    'PICE_GLA' as species,
	round(AVG(mb_PICE_GLA_mean)) AS mean,
    round(STDDEV(mb_PICE_GLA_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_PICE_GLA
UNION ALL
SELECT
    'PICE_MAR' as species,
	round(AVG(mb_PICE_MAR_mean)) AS mean,
    round(STDDEV(mb_PICE_MAR_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_PICE_MAR
UNION ALL
SELECT
    'PINU_BAN' as species,
	round(AVG(mb_PINU_BAN_mean)) AS mean,
    round(STDDEV(mb_PINU_BAN_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_PINU_BAN
UNION ALL
SELECT
    'PINU_CON' as species,
	round(AVG(mb_PINU_CON_mean)) AS mean,
    round(STDDEV(mb_PINU_CON_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_PINU_CON
UNION ALL
SELECT
    'PINU_SPP' as species,
	round(AVG(mb_PINU_SPP_mean)) AS mean,
    round(STDDEV(mb_PINU_SPP_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_PINU_SPP
UNION ALL
SELECT
    'POPU_BAL' as species,
	round(AVG(mb_POPU_BAL_mean)) AS mean,
    round(STDDEV(mb_POPU_BAL_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_POPU_BAL
UNION ALL
SELECT
    'POPU_TRE' as species,
	round(AVG(mb_POPU_TRE_mean)) AS mean,
    round(STDDEV(mb_POPU_TRE_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_POPU_TRE
UNION ALL
SELECT
    'ULMU_AME' as species,
	round(AVG(mb_ULMU_AME_mean)) AS mean,
    round(STDDEV(mb_ULMU_AME_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_ULMU_AME

ORDER BY species ASC


-----------------------------------------------------------------------------------------------------------------------------
------ without filter second_stand_photo_year > first_stand_photo_year +5
-----------------------------------------------------------------------------------------------------------------------------
-- DROP TABLE diego_test.FNsk_CASFRI_change_species_age
CREATE TABLE diego_test.FNsk_CASFRI_change_species_age AS

WITH mb_ABIE AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_ABIE_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'ABIE%' AND first_origin_upper >0), 
mb_ACER AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_ACER_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'ACER%' AND first_origin_upper >0),
mb_BETU AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_BETU_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'BETU%' AND first_origin_upper >0),
mb_LARI AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_LARI_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'LARI%' AND first_origin_upper >0),
mb_PICE_ENG AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_PICE_ENG_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'PICE_ENG%' AND first_origin_upper >0),
mb_PICE_GLA AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_PICE_GLA_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'PICE_GLA%' AND first_origin_upper >0),
mb_PICE_MAR AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_PICE_MAR_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'PICE_MAR%' AND first_origin_upper >0),
mb_PINU_BAN AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_PINU_BAN_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'PINU_BAN%' AND first_origin_upper >0),
mb_PINU_CON AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_PINU_CON_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'PINU_CON%' AND first_origin_upper >0),
mb_PINU_SPP AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_PINU_SPP_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'PINU_SPP%' AND first_origin_upper >0),
mb_POPU_BAL AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_POPU_BAL_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'POPU_BAL%' AND first_origin_upper >0),
mb_POPU_TRE AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_POPU_TRE_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'POPU_TRE%' AND first_origin_upper >0),
mb_ULMU_AME AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS mb_ULMU_AME_mean
    FROM diego_test.FNsk_CASFRI_changedscas_fullf
    WHERE first_species_1 LIKE 'ULMU_AME%' AND first_origin_upper >0)

SELECT
    'ABIE' as species,
	round(AVG(mb_ABIE_mean)) AS mean,
    round(STDDEV(mb_ABIE_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_ABIE
UNION ALL
SELECT
    'ACER' as species,
	round(AVG(mb_ACER_mean)) AS mean,
    round(STDDEV(mb_ACER_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_ACER
UNION ALL
SELECT
    'BETU' as species,
	round(AVG(mb_BETU_mean)) AS mean,
    round(STDDEV(mb_BETU_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_BETU
UNION ALL
SELECT
    'LARI' as species,
	round(AVG(mb_LARI_mean)) AS mean,
    round(STDDEV(mb_LARI_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_LARI
UNION ALL
SELECT
    'PICE_ENG' as species,
	round(AVG(mb_PICE_ENG_mean)) AS mean,
    round(STDDEV(mb_PICE_ENG_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_PICE_ENG
UNION ALL
SELECT
    'PICE_GLA' as species,
	round(AVG(mb_PICE_GLA_mean)) AS mean,
    round(STDDEV(mb_PICE_GLA_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_PICE_GLA
UNION ALL
SELECT
    'PICE_MAR' as species,
	round(AVG(mb_PICE_MAR_mean)) AS mean,
    round(STDDEV(mb_PICE_MAR_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_PICE_MAR
UNION ALL
SELECT
    'PINU_BAN' as species,
	round(AVG(mb_PINU_BAN_mean)) AS mean,
    round(STDDEV(mb_PINU_BAN_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_PINU_BAN
UNION ALL
SELECT
    'PINU_CON' as species,
	round(AVG(mb_PINU_CON_mean)) AS mean,
    round(STDDEV(mb_PINU_CON_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_PINU_CON
UNION ALL
SELECT
    'PINU_SPP' as species,
	round(AVG(mb_PINU_SPP_mean)) AS mean,
    round(STDDEV(mb_PINU_SPP_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_PINU_SPP
UNION ALL
SELECT
    'POPU_BAL' as species,
	round(AVG(mb_POPU_BAL_mean)) AS mean,
    round(STDDEV(mb_POPU_BAL_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_POPU_BAL
UNION ALL
SELECT
    'POPU_TRE' as species,
	round(AVG(mb_POPU_TRE_mean)) AS mean,
    round(STDDEV(mb_POPU_TRE_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_POPU_TRE
UNION ALL
SELECT
    'ULMU_AME' as species,
	round(AVG(mb_ULMU_AME_mean)) AS mean,
    round(STDDEV(mb_ULMU_AME_mean)) AS stddev,
	COUNT(*) AS count
FROM mb_ULMU_AME

   ORDER BY species ASC
