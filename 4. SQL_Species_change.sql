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
------ Module 4 
------ analyse the change of the dominant species bewteen 2 FRIs
------ while grouping possible groups to show more useful insight
------------------------------------------------------------------------------------------------------------------------------

-- 4.1
--find explanation, for all records LYR -> NFL, following species, men cut trees

with forest_change as (
SELECT *
--FROM  diego_test.fnbc_CASFRI_changedscas_boj_1f
FROM diego_test.fnbc_CASFRI_changedscas_boj_1f
WHERE type LIKE 'BOREAL'
-- WHERE first_PRODUCTIVITY IS NOT NULL AND second_PRODUCTIVITY IS NULL
AND second_stand_photo_year > first_stand_photo_year +5
--WHERE second_stand_photo_year > dist_year_wnw AND first_stand_photo_year < dist_year_wnw AND dist_type_wnw LIKE 'CUT'
--WHERE second_stand_photo_year > dist_year_nfdb AND first_stand_photo_year < dist_year_nfdb
)
SELECT first_species_1, second_species_1, CONCAT(COALESCE(first_species_1, 'NULL_VALUE'),' -> ',COALESCE(second_species_1, 'NULL_VALUE')) AS concatenated_column,  count(*) , SUM(COUNT(*)) OVER ()
FROM forest_change
group by first_species_1, second_species_1
ORDER BY count(*) DESC
LIMIT 10



-- 4.2
--find explanation, for all records LYR -> NFL, following species, men cut trees, with %

with forest_change as (
SELECT *
--FROM  diego_test.fnbc_CASFRI_changedscas_boj_1f
FROM diego_test.fnbc_CASFRI_changedscas_boj_1f
WHERE type LIKE 'BOREAL'
-- WHERE first_PRODUCTIVITY IS NOT NULL AND second_PRODUCTIVITY IS NULL
AND second_stand_photo_year > first_stand_photo_year +5
--WHERE second_stand_photo_year > dist_year_wnw AND first_stand_photo_year < dist_year_wnw AND dist_type_wnw LIKE 'CUT'
--WHERE second_stand_photo_year > dist_year_nfdb AND first_stand_photo_year < dist_year_nfdb
)
SELECT first_species_1, second_species_1, CONCAT(COALESCE(first_species_1, 'NULL_VALUE'),' -> ',COALESCE(second_species_1, 'NULL_VALUE')) AS concatenated_column,  count(*),
ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER (), 2) AS percentage

FROM forest_change
group by first_species_1, second_species_1
ORDER BY count(*) DESC
LIMIT 20




-- 4.3
-- accumulated % in BC

CREATE TABLE diego_test.FNBC_CASFRI_species_change_bore_9015 AS
WITH forest_change AS (
    SELECT *
    FROM diego_test.FNBC_CASFRI_changedscas_fullf_bore_age9015
    WHERE second_stand_photo_year > first_stand_photo_year + 5 AND bo_type LIKE 'HEMIBOREAL'
    --WHERE second_stand_photo_year > first_stand_photo_year + 5 AND bo_type LIKE 'BOREAL' and rocky_side LIKE 'WEST'
    --WHERE second_stand_photo_year > first_stand_photo_year + 5 AND bo_type LIKE 'BOREAL' and rocky_side LIKE 'EAST'
),
species_grouping AS (
    SELECT
        CASE 
        WHEN first_species_1 LIKE 'PICE_GLA%' THEN 'PICE_GLA/ENG/SPP/HYB'
        WHEN first_species_1 LIKE 'PICE_ENG%' THEN 'PICE_GLA/ENG/SPP/HYB'
	    WHEN first_species_1 LIKE 'PICE_SPP%' THEN 'PICE_GLA/ENG/SPP/HYB'
	    WHEN first_species_1 LIKE 'PICE_HYB%' THEN 'PICE_GLA/ENG/SPP/HYB'
	    WHEN first_species_1 LIKE 'PICE_MAR%' THEN 'PICE_MAR/LARI'
        WHEN first_species_1 LIKE 'LARI%' THEN 'PICE_MAR/LARI'	
	    WHEN first_species_1 LIKE 'ABIE%' THEN 'ABIE'
	    WHEN first_species_1 LIKE 'ACER%' THEN 'ACER'
	    WHEN first_species_1 LIKE 'BETU%' THEN 'BERU'	
	    WHEN first_species_1 LIKE 'PINU%' THEN 'PINU'
	    WHEN first_species_1 LIKE 'POPU%' THEN 'POPU'
	    WHEN first_species_1 LIKE 'PSEU%' THEN 'PSEU'
	    WHEN first_species_1 LIKE 'PSEU%' THEN 'PSEU/TSUG'
	    WHEN first_species_1 LIKE 'TSUG%' THEN 'PSEU/TSUG'
	    WHEN first_species_1 LIKE 'ULMU%' THEN 'ULMU'
	    ELSE NULL
        END AS grouped_first_species_1,
        CASE 
        WHEN second_species_1 LIKE 'PICE_GLA%' THEN 'PICE_GLA/ENG/SPP/HYB'
        WHEN second_species_1 LIKE 'PICE_ENG%' THEN 'PICE_GLA/ENG/SPP/HYB'
	    WHEN second_species_1 LIKE 'PICE_SPP%' THEN 'PICE_GLA/ENG/SPP/HYB'
	    WHEN second_species_1 LIKE 'PICE_HYB%' THEN 'PICE_GLA/ENG/SPP/HYB'
	    WHEN second_species_1 LIKE 'PICE_MAR%' THEN 'PICE_MAR/LARI'
	    WHEN second_species_1 LIKE 'LARI%' THEN 'PICE_MAR/LARI'	
	    WHEN second_species_1 LIKE 'ABIE%' THEN 'ABIE'
	    WHEN second_species_1 LIKE 'ACER%' THEN 'ACER'
	    WHEN second_species_1 LIKE 'BETU%' THEN 'BERU'	
	    WHEN second_species_1 LIKE 'PINU%' THEN 'PINU'
	    WHEN second_species_1 LIKE 'POPU%' THEN 'POPU'
	    WHEN second_species_1 LIKE 'PSEU%' THEN 'PSEU'
	    WHEN second_species_1 LIKE 'PSEU%' THEN 'PSEU/TSUG'
	    WHEN second_species_1 LIKE 'TSUG%' THEN 'PSEU/TSUG'
	    WHEN second_species_1 LIKE 'ULMU%' THEN 'ULMU'
	    ELSE NULL
        END AS grouped_second_species_1,
        first_species_1,
        second_species_1
    FROM forest_change
),
ranked_species AS (
    SELECT 
        grouped_first_species_1,
        grouped_second_species_1,
        CONCAT(COALESCE(grouped_first_species_1, 'NULL'), ' -> ', COALESCE(grouped_second_species_1, 'NULL')) AS species_change,  
        COUNT(*) AS count,
        ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER (), 2) AS percentage
    FROM species_grouping
    GROUP BY grouped_first_species_1, grouped_second_species_1
),
cumulative_percentage AS (
    SELECT 
        *,
        SUM(percentage) OVER (ORDER BY count DESC, grouped_first_species_1, grouped_second_species_1 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_percentage
    FROM ranked_species
)
SELECT *
FROM cumulative_percentage
WHERE cumulative_percentage <= 95
ORDER BY count DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.3b
-- accumulated % other than BC

CREATE TABLE diego_test.FNMB_CASFRI_species_change_9015 AS
WITH forest_change AS (
    SELECT *
    FROM diego_test.FNMB_CASFRI_changedscas_fullf_age9015
    WHERE second_stand_photo_year > first_stand_photo_year + 5 AND (first_cat LIKE 'LYR' or second_cat LIKE 'LYR')
),
species_grouping AS (
    SELECT
        CASE 
        WHEN first_species_1 LIKE 'PICE_GLA%' THEN 'PICE_GLA/ENG/SPP/HYB'
        WHEN first_species_1 LIKE 'PICE_ENG%' THEN 'PICE_GLA/ENG/SPP/HYB'
	    WHEN first_species_1 LIKE 'PICE_SPP%' THEN 'PICE_GLA/ENG/SPP/HYB'
	    WHEN first_species_1 LIKE 'PICE_HYB%' THEN 'PICE_GLA/ENG/SPP/HYB'
	    WHEN first_species_1 LIKE 'PICE_MAR%' THEN 'PICE_MAR/LARI'
        WHEN first_species_1 LIKE 'LARI%' THEN 'PICE_MAR/LARI'	
	    WHEN first_species_1 LIKE 'ABIE%' THEN 'ABIE'
	    WHEN first_species_1 LIKE 'ACER%' THEN 'ACER'
	    WHEN first_species_1 LIKE 'BETU%' THEN 'BERU'	
	    WHEN first_species_1 LIKE 'PINU%' THEN 'PINU'
	    WHEN first_species_1 LIKE 'POPU%' THEN 'POPU'
	    WHEN first_species_1 LIKE 'PSEU%' THEN 'PSEU'
	    WHEN first_species_1 LIKE 'PSEU%' THEN 'PSEU/TSUG'
	    WHEN first_species_1 LIKE 'TSUG%' THEN 'PSEU/TSUG'
	    WHEN first_species_1 LIKE 'ULMU%' THEN 'ULMU'
	    ELSE NULL
        END AS grouped_first_species_1,
        CASE 
        WHEN second_species_1 LIKE 'PICE_GLA%' THEN 'PICE_GLA/ENG/SPP/HYB'
        WHEN second_species_1 LIKE 'PICE_ENG%' THEN 'PICE_GLA/ENG/SPP/HYB'
	    WHEN second_species_1 LIKE 'PICE_SPP%' THEN 'PICE_GLA/ENG/SPP/HYB'
	    WHEN second_species_1 LIKE 'PICE_HYB%' THEN 'PICE_GLA/ENG/SPP/HYB'
	    WHEN second_species_1 LIKE 'PICE_MAR%' THEN 'PICE_MAR/LARI'
	    WHEN second_species_1 LIKE 'LARI%' THEN 'PICE_MAR/LARI'	
	    WHEN second_species_1 LIKE 'ABIE%' THEN 'ABIE'
	    WHEN second_species_1 LIKE 'ACER%' THEN 'ACER'
	    WHEN second_species_1 LIKE 'BETU%' THEN 'BERU'	
	    WHEN second_species_1 LIKE 'PINU%' THEN 'PINU'
	    WHEN second_species_1 LIKE 'POPU%' THEN 'POPU'
	    WHEN second_species_1 LIKE 'PSEU%' THEN 'PSEU'
	    WHEN second_species_1 LIKE 'PSEU%' THEN 'PSEU/TSUG'
	    WHEN second_species_1 LIKE 'TSUG%' THEN 'PSEU/TSUG'
	    WHEN second_species_1 LIKE 'ULMU%' THEN 'ULMU'
	    ELSE NULL
        END AS grouped_second_species_1,
        first_species_1,
        second_species_1
    FROM forest_change
),
ranked_species AS (
    SELECT 
        grouped_first_species_1,
        grouped_second_species_1,
        CONCAT(COALESCE(grouped_first_species_1, 'NULL'), ' -> ', COALESCE(grouped_second_species_1, 'NULL')) AS species_change,  
        COUNT(*) AS count,
        ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER (), 2) AS percentage
    FROM species_grouping
    GROUP BY grouped_first_species_1, grouped_second_species_1
),
cumulative_percentage AS (
    SELECT 
        *,
        SUM(percentage) OVER (ORDER BY count DESC, grouped_first_species_1, grouped_second_species_1 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_percentage
    FROM ranked_species
)
SELECT *
FROM cumulative_percentage
WHERE cumulative_percentage <= 95
ORDER BY count DESC;
