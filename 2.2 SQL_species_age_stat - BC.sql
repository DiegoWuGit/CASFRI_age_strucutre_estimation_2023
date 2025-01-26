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
------ Module 2.2 
------ Calculate mean species age, in each province
------ while grouping different naming of species into bigger group for simpler interpretation
------ (this script for BC region, where contains more species than easter regions)
------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE diego_test.FNBC_CASFRI_change_species_age_bore AS

WITH BC_ABIE AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_ABIE_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'ABIE%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL'), 
BC_ACER AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_ACER_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'ACER%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL'),
BC_BETU AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_BETU_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'BETU%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL'),
BC_LARI AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_LARI_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'LARI%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL'),
BC_PICE_ENG AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PICE_ENG_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PICE_ENG%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL'),
BC_PICE_GLA AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PICE_GLA_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PICE_GLA%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL'),
BC_PICE_MAR AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PICE_MAR_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PICE_MAR%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL'),
BC_PINU_BAN AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PINU_BAN_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PINU_BAN%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL'),
BC_PINU_CON AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PINU_CON_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PINU_CON%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL'),
BC_PINU_SPP AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PINU_SPP_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PINU_SPP%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL'),
BC_POPU_BAL AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_POPU_BAL_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'POPU_BAL%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL'),
BC_POPU_TRE AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_POPU_TRE_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'POPU_TRE%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL'),
BC_ULMU_AME AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_ULMU_AME_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'ULMU_AME%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL'),
BC_PICE_HYB AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PICE_HYB_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PICE_HYB%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL'),
BC_PICE_SPP AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PICE_SPP_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PICE_SPP%' AND first_origin_upper >0 AND bo_type LIKE 'BOREAL')


SELECT
    'ABIE' as species,
	round(AVG(BC_ABIE_mean)) AS mean,
    round(STDDEV(BC_ABIE_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_ABIE
UNION ALL
SELECT
    'ACER' as species,
	round(AVG(BC_ACER_mean)) AS mean,
    round(STDDEV(BC_ACER_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_ACER
UNION ALL
SELECT
    'BETU' as species,
	round(AVG(BC_BETU_mean)) AS mean,
    round(STDDEV(BC_BETU_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_BETU
UNION ALL
SELECT
    'LARI' as species,
	round(AVG(BC_LARI_mean)) AS mean,
    round(STDDEV(BC_LARI_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_LARI
UNION ALL
SELECT
    'PICE_ENG' as species,
	round(AVG(BC_PICE_ENG_mean)) AS mean,
    round(STDDEV(BC_PICE_ENG_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PICE_ENG
UNION ALL
SELECT
    'PICE_GLA' as species,
	round(AVG(BC_PICE_GLA_mean)) AS mean,
    round(STDDEV(BC_PICE_GLA_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PICE_GLA
UNION ALL
SELECT
    'PICE_MAR' as species,
	round(AVG(BC_PICE_MAR_mean)) AS mean,
    round(STDDEV(BC_PICE_MAR_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PICE_MAR
UNION ALL
SELECT
    'PINU_BAN' as species,
	round(AVG(BC_PINU_BAN_mean)) AS mean,
    round(STDDEV(BC_PINU_BAN_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PINU_BAN
UNION ALL
SELECT
    'PINU_CON' as species,
	round(AVG(BC_PINU_CON_mean)) AS mean,
    round(STDDEV(BC_PINU_CON_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PINU_CON
UNION ALL
SELECT
    'PINU_SPP' as species,
	round(AVG(BC_PINU_SPP_mean)) AS mean,
    round(STDDEV(BC_PINU_SPP_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PINU_SPP
UNION ALL
SELECT
    'POPU_BAL' as species,
	round(AVG(BC_POPU_BAL_mean)) AS mean,
    round(STDDEV(BC_POPU_BAL_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_POPU_BAL
UNION ALL
SELECT
    'POPU_TRE' as species,
	round(AVG(BC_POPU_TRE_mean)) AS mean,
    round(STDDEV(BC_POPU_TRE_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_POPU_TRE
UNION ALL
SELECT
    'ULMU_AME' as species,
	round(AVG(BC_ULMU_AME_mean)) AS mean,
    round(STDDEV(BC_ULMU_AME_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_ULMU_AME
UNION ALL
SELECT
    'PICE_HYB' as species,
	round(AVG(BC_PICE_HYB_mean)) AS mean,
    round(STDDEV(BC_PICE_HYB_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PICE_HYB
UNION ALL
SELECT
    'PICE_SPP' as species,
	round(AVG(BC_PICE_SPP_mean)) AS mean,
    round(STDDEV(BC_PICE_SPP_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PICE_SPP
ORDER BY species ASC
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

CREATE TABLE diego_test.FNBC_CASFRI_change_species_age_hemi AS

WITH BC_ABIE AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_ABIE_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'ABIE%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'), 
BC_ACER AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_ACER_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'ACER%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_BETU AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_BETU_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'BETU%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_LARI AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_LARI_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'LARI%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_PICE_ENG AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PICE_ENG_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PICE_ENG%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_PICE_GLA AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PICE_GLA_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PICE_GLA%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_PICE_MAR AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PICE_MAR_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PICE_MAR%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_PINU_BAN AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PINU_BAN_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PINU_BAN%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_PINU_CON AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PINU_CON_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PINU_CON%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_PINU_SPP AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PINU_SPP_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PINU_SPP%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_POPU_BAL AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_POPU_BAL_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'POPU_BAL%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_POPU_TRE AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_POPU_TRE_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'POPU_TRE%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_ULMU_AME AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_ULMU_AME_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'ULMU_AME%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_TSUG AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_TSUG_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'TSUG%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_PSEU AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PSEU_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PSEU%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_PICE_HYB AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PICE_HYB_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PICE_HYB%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL'),
BC_PICE_SPP AS (
SELECT CASE
            WHEN first_origin_lower < 0 THEN first_origin_upper
	        WHEN first_origin_upper < 0 THEN first_origin_lower
            ELSE (first_origin_upper + first_origin_lower) / 2.0
       END AS BC_PICE_SPP_mean
    FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z
    WHERE first_species_1 LIKE 'PICE_SPP%' AND first_origin_upper >0 AND bo_type LIKE 'HEMIBOREAL')


SELECT
    'ABIE' as species,
	round(AVG(BC_ABIE_mean)) AS mean,
    round(STDDEV(BC_ABIE_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_ABIE
UNION ALL
SELECT
    'ACER' as species,
	round(AVG(BC_ACER_mean)) AS mean,
    round(STDDEV(BC_ACER_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_ACER
UNION ALL
SELECT
    'BETU' as species,
	round(AVG(BC_BETU_mean)) AS mean,
    round(STDDEV(BC_BETU_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_BETU
UNION ALL
SELECT
    'LARI' as species,
	round(AVG(BC_LARI_mean)) AS mean,
    round(STDDEV(BC_LARI_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_LARI
UNION ALL
SELECT
    'PICE_ENG' as species,
	round(AVG(BC_PICE_ENG_mean)) AS mean,
    round(STDDEV(BC_PICE_ENG_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PICE_ENG
UNION ALL
SELECT
    'PICE_GLA' as species,
	round(AVG(BC_PICE_GLA_mean)) AS mean,
    round(STDDEV(BC_PICE_GLA_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PICE_GLA
UNION ALL
SELECT
    'PICE_MAR' as species,
	round(AVG(BC_PICE_MAR_mean)) AS mean,
    round(STDDEV(BC_PICE_MAR_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PICE_MAR
UNION ALL
SELECT
    'PINU_BAN' as species,
	round(AVG(BC_PINU_BAN_mean)) AS mean,
    round(STDDEV(BC_PINU_BAN_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PINU_BAN
UNION ALL
SELECT
    'PINU_CON' as species,
	round(AVG(BC_PINU_CON_mean)) AS mean,
    round(STDDEV(BC_PINU_CON_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PINU_CON
UNION ALL
SELECT
    'PINU_SPP' as species,
	round(AVG(BC_PINU_SPP_mean)) AS mean,
    round(STDDEV(BC_PINU_SPP_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PINU_SPP
UNION ALL
SELECT
    'POPU_BAL' as species,
	round(AVG(BC_POPU_BAL_mean)) AS mean,
    round(STDDEV(BC_POPU_BAL_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_POPU_BAL
UNION ALL
SELECT
    'POPU_TRE' as species,
	round(AVG(BC_POPU_TRE_mean)) AS mean,
    round(STDDEV(BC_POPU_TRE_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_POPU_TRE
UNION ALL
SELECT
    'ULMU_AME' as species,
	round(AVG(BC_ULMU_AME_mean)) AS mean,
    round(STDDEV(BC_ULMU_AME_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_ULMU_AME
UNION ALL
SELECT
    'TSUG' as species,
	round(AVG(BC_TSUG_mean)) AS mean,
    round(STDDEV(BC_TSUG_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_TSUG
UNION ALL
SELECT
    'PSEU' as species,
	round(AVG(BC_PSEU_mean)) AS mean,
    round(STDDEV(BC_PSEU_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PSEU
UNION ALL
SELECT
    'PICE_HYB' as species,
	round(AVG(BC_PICE_HYB_mean)) AS mean,
    round(STDDEV(BC_PICE_HYB_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PICE_HYB
UNION ALL
SELECT
    'PICE_SPP' as species,
	round(AVG(BC_PICE_SPP_mean)) AS mean,
    round(STDDEV(BC_PICE_SPP_mean)) AS stddev,
	COUNT(*) AS count
FROM BC_PICE_SPP
ORDER BY species ASC
--------------------------------------------------------------------------------------------------------------------------


