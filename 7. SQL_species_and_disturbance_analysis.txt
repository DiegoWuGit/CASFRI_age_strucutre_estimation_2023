
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
------ Module 7 
------ Attributs disturbance to changes of states of forest
------ 1st analysis 7.1: 
-------             after knowing the categories of forest, we sort out the dominant species which experience the change
------ 2nd analysis 7.2:
-------             after knowing the categories of forest, we group different combination of disturbance which vitness the change

------------------------------------------------------------------------------------------------------------------------------


-- 1. find explanation, for all records LYR -> NFL, following species, men cut trees
with forest_change as (
SELECT *
FROM diego_test.FNab_CASFRI_changedscas_fullf_age9015
WHERE first_cat LIKE 'LYR' AND second_cat LIKE 'NFL'
AND second_stand_photo_year > first_stand_photo_year +5
AND dist_casfri_type_1 LIKE 'CUT' --AND dist_casfri_year_1 >= first_stand_photo_year AND dist_casfri_year_1 <second_stand_photo_year
AND dist_type_wnw LIKE 'CUT' --AND dist_year_wnw >= first_stand_photo_year AND dist_year_wnw <second_stand_photo_year
AND dist_type_canlad = 2 --AND dist_year_canlad >= first_stand_photo_year AND dist_year_canlad <second_stand_photo_year
)
SELECT first_species_1, second_species_1, CONCAT(COALESCE(first_species_1, 'NULL_VALUE'),' -> ',COALESCE(second_species_1, 'NULL_VALUE')) AS concatenated_column,  count(*) , SUM(COUNT(*)) OVER ()
FROM forest_change
group by first_species_1, second_species_1
ORDER BY count(*) DESC
LIMIT 10



-- 1.2 accumulated %
WITH forest_change AS (
    SELECT *
    FROM diego_test.fnmb_CASFRI_changedscas_1f
    WHERE second_stand_photo_year > first_stand_photo_year + 5
),
species_grouping AS (
    SELECT
        CASE 
            WHEN first_species_1 LIKE 'PICE%' THEN 'PICE'
			WHEN first_species_1 LIKE 'PINU%' THEN 'PINU'
			WHEN first_species_1 LIKE 'POPU%' THEN 'POPU'
			WHEN first_species_1 LIKE 'LARI%' THEN 'LARI'
			ELSE first_species_1 
        END AS grouped_first_species_1,
        CASE 
            WHEN second_species_1 LIKE 'PICE%' THEN 'PICE'
 			WHEN second_species_1 LIKE 'PINU%' THEN 'PINU'
			WHEN second_species_1 LIKE 'POPU%' THEN 'POPU'	
			WHEN second_species_1 LIKE 'LARI%' THEN 'LARI'
			ELSE second_species_1 
        END AS grouped_second_species_1,
        first_species_1,
        second_species_1
    FROM forest_change
),
ranked_species AS (
    SELECT 
        grouped_first_species_1,
        grouped_second_species_1,
        CONCAT(COALESCE(grouped_first_species_1, 'NULL_VALUE'), ' -> ', COALESCE(grouped_second_species_1, 'NULL_VALUE')) AS concatenated_column,  
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



--  2. for all unexplanable records of LYR -> NFL, OR, LYR -> Others, OR, NFL -> LYR, drilling following causes
WITH forest_change AS (
    SELECT *
    FROM diego_test.FNab_CASFRI_changedscas_fullf_age9015_ten
    WHERE first_cat LIKE 'LYR' AND second_cat LIKE 'NFL' AND second_stand_photo_year > first_stand_photo_year + 5
--  WHERE first_cat LIKE 'LYR' AND second_cat LIKE 'Others' AND second_stand_photo_year > first_stand_photo_year + 5 -- change to this line if we want to test this combination
--  WHERE first_cat LIKE 'NFL' AND second_cat LIKE 'LYR' AND second_stand_photo_year > first_stand_photo_year + 5    -- change to this line if we want to test this combination
),
aggregated AS (
    SELECT 
        dist_casfri_type_1, 
        CASE 
            WHEN dist_type_bead LIKE 'Cutblock' THEN 'CUT' 
            ELSE dist_type_bead::text
        END AS dist_type_bead, 
        CASE 
            WHEN dist_nfdb_year_1 IS NOT NULL THEN 'BURN'
            ELSE NULL -- or specify a default value for NULLs if needed
        END AS dist_type_nfdb, 
        dist_type_wnw, 
        CASE 
            WHEN dist_type_canlad = 1 THEN 'BURN' 
            WHEN dist_type_canlad = 2 THEN 'CUT' 
            ELSE dist_type_canlad::text
        END AS dist_type_canlad, 
        COUNT(*) AS group_count,
        SUM(COUNT(*)) OVER () AS total_count
    FROM forest_change
    GROUP BY 
        dist_casfri_type_1, 
        dist_type_bead, 
        CASE 
            WHEN dist_nfdb_year_1 IS NOT NULL THEN 'BURN'
            ELSE NULL
        END, 
        dist_type_wnw, 
        CASE 
            WHEN dist_type_canlad = 1 THEN 'BURN' 
            WHEN dist_type_canlad = 2 THEN 'CUT' 
            ELSE dist_type_canlad::text
        END
)
SELECT 
    *,
    round((group_count::decimal / total_count) * 100,2) AS percentage
FROM aggregated
ORDER BY group_count DESC
LIMIT 20;




