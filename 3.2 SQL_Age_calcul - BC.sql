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
------ Module 3.2 
------ Calculate age on each sampling points
------ 1st step: assigning categoies to each point (LYR / NFL / WaterAndRocks / Others)
------ 2nd step: based on the categories, apply age calculation algorithm to find age in 1990 / 2015:
-----------------i. by considering the first stand origin
-----------------ii. by considering them mean stand species age
-----------------iii. by dating-back the second stand origin / extending the age calculed by first stand origin
----- (this script is for BC region)
------------------------------------------------------------------------------------------------------------------------------

-- 3.1.1 Join species mean origin, and label each sampling points with LYR / NFL / WaterAndRocks / Others
-- Categorizing criteria:
-- LYR: productive forest
-- NFL: non-productive, with valid attributes in 'non-forest vegetation' field
-- WaterAndRocks: non-productive, with valid attributes in 'natural non-vegetation' field
-- Others: non-productive, with valid attributes in 'anthropogenic activities' field


CREATE TABLE diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015 AS
SELECT fullf.*, age.mean as species_mean,
CASE
    WHEN first_productivity IS NOT NULL THEN 'LYR'
    WHEN first_PRODUCTIVITY IS NULL AND first_non_for_veg IS NOT NULL AND first_non_for_veg NOT like 'NOT_APPLICABLE' THEN 'NFL'
    WHEN first_PRODUCTIVITY IS NULL AND first_nat_non_veg IS NOT NULL AND first_nat_non_veg NOT like 'NOT_APPLICABLE' THEN 'WaterAndRocks'
    WHEN first_PRODUCTIVITY IS NULL AND (first_non_for_veg like 'NOT_APPLICABLE' AND first_nat_non_veg like 'NOT_APPLICABLE' OR (first_non_for_veg IS NULL AND first_nat_non_veg IS NULL)) THEN 'Others'
    ELSE NULL
	END AS first_cat,
CASE
    WHEN second_productivity IS NOT NULL THEN 'LYR'
    WHEN second_PRODUCTIVITY IS NULL AND second_non_for_veg IS NOT NULL AND second_non_for_veg NOT like 'NOT_APPLICABLE' THEN 'NFL'
    WHEN second_PRODUCTIVITY IS NULL AND second_nat_non_veg IS NOT NULL AND second_nat_non_veg NOT like 'NOT_APPLICABLE' THEN 'WaterAndRocks'
    WHEN second_PRODUCTIVITY IS NULL AND (second_non_for_veg like 'NOT_APPLICABLE' AND second_nat_non_veg like 'NOT_APPLICABLE' OR (second_non_for_veg IS NULL AND second_nat_non_veg IS NULL)) THEN 'Others'	
    ELSE NULL
	END AS second_cat 	
FROM diego_test.FNBC_CASFRI_bojew_changedscas_fullf_3z as fullf
LEFT JOIN diego_test.FNBC_CASFRI_change_species_age_bore as age   
LEFT JOIN diego_test.FNBC_CASFRI_change_species_age_hemi as age                                   ----------change to this line for creating hemiboreal table
ON COALESCE(LEFT(fullf.first_species_1, 8), LEFT(fullf.second_species_1, 8)) = age.species   OR 
   COALESCE(LEFT(fullf.first_species_1, 4), LEFT(fullf.second_species_1, 4)) = age.species
WHERE fullf.bo_type LIKE 'BOREAL';
--WHERE fullf.bo_type LIKE 'HEMIBOREAL';                                                         ----------change to this line for creating hemiboreal table


--3.1.2
-- check category statistics
-- tabulate the categories changing statistics

SELECT first_cat, second_cat, count(*), round(count(*)/(sum(count(*)) over ())*100,2) as percentage
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
GROUP BY first_cat, second_cat
ORDER BY count(*) DESC


------------------------------------------------------------------------------------------------------
---3.2. add a column to hold age1990, and calculate it under 4 changing conditions 
------------------------------------------------------------------------------------------------------
-- add a column to hold age9015
ALTER TABLE
	diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
ADD
	COLUMN Age_1990 INTEGER;

ALTER TABLE
	diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
ADD
	COLUMN Age_2015 INTEGER;

ALTER TABLE
	diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
ADD
	COLUMN age_2015_noLogging INTEGER;

--calculate the age in 1990 

UPDATE diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
SET Age_1990 = 
  CASE
    -- LYR->LYR 
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND prov LIKE 'MB' AND first_origin_upper =-9999 AND (first_species_1 LIKE 'PICE_MAR%' OR first_species_1 LIKE 'PINU_BAN%') THEN 1990 - (second_origin_upper + second_origin_lower) / 2.0      ------ special treatment of missing data in MB
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND first_stand_photo_year >= 1990 AND first_origin_upper >1990 AND first_origin_lower >1990 THEN 1990 - species_mean                                                                          ------ very small amount of this criteria happened in AB and BC
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND first_stand_photo_year >= 1990 AND first_origin_upper >0 AND first_origin_lower >0 THEN 1990 - (first_origin_upper + first_origin_lower) / 2.0
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND first_stand_photo_year >= 1990 AND first_origin_upper <0 AND first_origin_lower <0 THEN 1990 - species_mean
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND first_stand_photo_year < 1990 THEN
	CASE 
		WHEN (dist_year_wnw IS NULL OR dist_year_wnw >1990 OR dist_year_wnw <first_stand_photo_year) AND (dist_year_canlad IS NULL OR dist_year_canlad >1990 OR dist_year_canlad < first_stand_photo_year) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 >1990 OR dist_casfri_year_1 < first_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN' AND dist_casfri_type_1 NOT LIKE 'CUT')) AND
		     (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 >1990 OR dist_nfdb_year_1 <first_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 >1990 OR dist_nfdb_year_2 <first_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 >1990 OR dist_nfdb_year_3 <first_stand_photo_year) AND
		     (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 >1990 OR dist_nfdb_year_4 <first_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 >1990 OR dist_nfdb_year_5 <first_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 >1990 OR dist_nfdb_year_6 <first_stand_photo_year) AND
		     (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 >1990 OR dist_nfdb_year_7 <first_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 >1990 OR dist_nfdb_year_7 <first_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 >1990 OR dist_nfdb_year_9 <first_stand_photo_year) THEN
				CASE WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND first_stand_photo_year <= 1980 AND (first_origin_upper = 1769 OR first_origin_upper = 1771 OR first_origin_upper = 1774) THEN 1990 - (second_origin_upper + second_origin_lower) / 2.0     ------ Old FRI estimations on oldest trees not used, it seriously affect estimation in BC, instead we use recent estimation on same area
 				     WHEN first_stand_photo_year < first_origin_upper AND first_origin_upper >0 THEN 1990 - species_mean                                                    ------ appear in some old inventories, especially in MB
                                     WHEN first_origin_upper >0 AND first_origin_lower >0 THEN 1990 - (first_origin_upper + first_origin_lower) / 2.0
                                     WHEN first_origin_upper <0 AND first_origin_lower <0 AND species_mean IS NULL AND second_origin_upper >0 AND second_origin_lower >0 THEN 1990 - (second_origin_upper + second_origin_lower) / 2.0                   
                                     WHEN first_origin_upper <0 AND first_origin_lower <0 AND species_mean IS NULL AND second_origin_upper <0 AND second_origin_lower <0 THEN NULL                                                                       
				     WHEN first_origin_upper <0 AND first_origin_lower <0 THEN 1990 - species_mean END
	        ELSE (1990 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 1990 THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 1990 THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 1990 AND (dist_casfri_type_1 LIKE 'BURN' OR dist_casfri_type_1 LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 1990 THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 1990 THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 1990 THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 1990 THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 1990 THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 1990 THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 1990 THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 1990 THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 1990 THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END

    -- NFL->NFL
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'NFL' THEN NULL

    -- NFL->LYR
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'LYR' AND first_stand_photo_year >= 1990 THEN 	                              ------ apply the disturbance record, age set as NULL if no disturbance record
	CASE 
		WHEN (dist_year_wnw IS NULL OR dist_year_wnw >1990) AND (dist_year_canlad IS NULL OR dist_year_canlad >1990) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 >1990 OR (dist_casfri_type_1 NOT LIKE 'BURN' AND dist_casfri_type_1 NOT LIKE 'CUT')) AND
		     (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 >1990) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 >1990) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 >1990) AND
		     (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 >1990) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 >1990) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 >1990) AND
		     (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 >1990) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 >1990) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 >1990) THEN 
				CASE WHEN species_mean IS NULL THEN NULL WHEN species_mean IS NOT NULL THEN 1990-species_mean END 
	        ELSE (1990 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 1990 THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 1990 THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 1990 AND (dist_casfri_type_1 LIKE 'BURN' OR dist_casfri_type_1 LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 1990 THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 1990 THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 1990 THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 1990 THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 1990 THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 1990 THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 1990 THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 1990 THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 1990 THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'LYR' AND first_stand_photo_year < 1990 THEN 	                              ------ apply the disturbance record, age set as NULL if no disturbance record
	CASE 
		WHEN (dist_year_wnw IS NULL OR dist_year_wnw >1990) AND (dist_year_canlad IS NULL OR dist_year_canlad >1990) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 >1990 OR (dist_casfri_type_1 NOT LIKE 'BURN' AND dist_casfri_type_1 NOT LIKE 'CUT')) AND
		     (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 >1990) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 >1990) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 >1990) AND
		     (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 >1990) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 >1990) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 >1990) AND
		     (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 >1990) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 >1990) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 >1990) THEN 
				CASE WHEN second_origin_upper <0 OR second_origin_lower <0 THEN 1990 - first_stand_photo_year
				     WHEN (second_origin_upper + second_origin_lower) / 2.0 <= 1990 THEN 1990 - (second_origin_upper + second_origin_lower) / 2.0 
				     WHEN (second_origin_upper + second_origin_lower) / 2.0 >= 1990 THEN 1990 - first_stand_photo_year END
	        ELSE (1990 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 1990 THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 1990 THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 1990 AND (dist_casfri_type_1 LIKE 'BURN' OR dist_casfri_type_1 LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 1990 THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 1990 THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 1990 THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 1990 THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 1990 THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 1990 THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 1990 THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 1990 THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 1990 THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END

     -- LYR->NFL
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'NFL' AND first_stand_photo_year >= 1990 AND first_origin_upper >0 AND first_origin_lower >0 THEN 1990 - (first_origin_upper + first_origin_lower) / 2.0
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'NFL' AND first_stand_photo_year >= 1990 AND first_origin_upper <0 AND first_origin_lower <0 THEN 1990 - species_mean
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'NFL' AND first_stand_photo_year < 1990 THEN
	CASE 
		WHEN (dist_year_wnw IS NULL OR dist_year_wnw >1990 OR dist_year_wnw <first_stand_photo_year) AND (dist_year_canlad IS NULL OR dist_year_canlad >1990 OR dist_year_canlad < first_stand_photo_year) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 >1990 OR dist_casfri_year_1 < first_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN' AND dist_casfri_type_1 NOT LIKE 'CUT')) AND
		     (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 >1990 OR dist_nfdb_year_1 <first_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 >1990 OR dist_nfdb_year_2 <first_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 >1990 OR dist_nfdb_year_3 <first_stand_photo_year) AND
		     (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 >1990 OR dist_nfdb_year_4 <first_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 >1990 OR dist_nfdb_year_5 <first_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 >1990 OR dist_nfdb_year_6 <first_stand_photo_year) AND
		     (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 >1990 OR dist_nfdb_year_7 <first_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 >1990 OR dist_nfdb_year_7 <first_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 >1990 OR dist_nfdb_year_9 <first_stand_photo_year) THEN
				CASE WHEN first_stand_photo_year < first_origin_upper AND first_origin_upper >0 THEN 1990 - species_mean                                                    ------ appear in some old inventories, especially in MB
                                     WHEN first_origin_upper >0 AND first_origin_lower >0 THEN 1990 - (first_origin_upper + first_origin_lower) / 2.0
                                     WHEN first_origin_upper <0 AND first_origin_lower <0 AND species_mean IS NULL AND second_origin_upper >0 AND second_origin_lower >0 THEN 1990 - (second_origin_upper + second_origin_lower) / 2.0                   
                                     WHEN first_origin_upper <0 AND first_origin_lower <0 AND species_mean IS NULL AND second_origin_upper <0 AND second_origin_lower <0 THEN NULL                                                                       
				     WHEN first_origin_upper <0 AND first_origin_lower <0 THEN 1990 - species_mean END
	        ELSE (1990 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 1990 THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 1990 THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 1990 AND (dist_casfri_type_1 LIKE 'BURN' OR dist_casfri_type_1 LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 1990 THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 1990 THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 1990 THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 1990 THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 1990 THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 1990 THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 1990 THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 1990 THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 1990 THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END

    -- Others->LYR
    WHEN first_cat LIKE 'Others' AND second_cat LIKE 'LYR' AND first_stand_photo_year >= 1990 THEN 	                              ------ apply the disturbance record, age set as NULL if no disturbance record
	CASE 
		WHEN (dist_year_wnw IS NULL OR dist_year_wnw >1990) AND (dist_year_canlad IS NULL OR dist_year_canlad >1990) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 >1990 OR (dist_casfri_type_1 NOT LIKE 'BURN' AND dist_casfri_type_1 NOT LIKE 'CUT')) AND
		     (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 >1990) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 >1990) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 >1990) AND
		     (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 >1990) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 >1990) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 >1990) AND
		     (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 >1990) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 >1990) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 >1990) THEN 
				CASE WHEN first_stand_photo_year < first_origin_upper AND first_origin_upper >0 THEN 1990 - species_mean                                                                                         ------ appear in some old inventories, especially in MB
				     WHEN species_mean IS NULL THEN NULL WHEN species_mean IS NOT NULL THEN 1990-species_mean END 
	        ELSE (1990 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 1990 THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 1990 THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 1990 AND (dist_casfri_type_1 LIKE 'BURN' OR dist_casfri_type_1 LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 1990 THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 1990 THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 1990 THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 1990 THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 1990 THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 1990 THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 1990 THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 1990 THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 1990 THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END
    WHEN first_cat LIKE 'Others' AND second_cat LIKE 'LYR' AND first_stand_photo_year < 1990 THEN 	                              ------ apply the disturbance record, age set as NULL if no disturbance record
	CASE 
		WHEN (dist_year_wnw IS NULL OR dist_year_wnw >1990) AND (dist_year_canlad IS NULL OR dist_year_canlad >1990) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 >1990 OR (dist_casfri_type_1 NOT LIKE 'BURN' AND dist_casfri_type_1 NOT LIKE 'CUT')) AND
		     (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 >1990) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 >1990) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 >1990) AND
		     (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 >1990) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 >1990) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 >1990) AND
		     (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 >1990) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 >1990) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 >1990) THEN 
				CASE WHEN second_origin_upper <0 OR second_origin_lower <0 THEN NULL
				     WHEN (second_origin_upper + second_origin_lower) / 2.0 <= 1990 THEN 1990 - (second_origin_upper + second_origin_lower) / 2.0 
				     WHEN (second_origin_upper + second_origin_lower) / 2.0 >= 1990 THEN 1990 - first_stand_photo_year END
	        ELSE (1990 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 1990 THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 1990 THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 1990 AND (dist_casfri_type_1 LIKE 'BURN' OR dist_casfri_type_1 LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 1990 THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 1990 THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 1990 THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 1990 THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 1990 THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 1990 THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 1990 THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 1990 THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 1990 THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END 

    -- LYR->Others
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'Others' AND first_stand_photo_year >= 1990 AND first_origin_upper >0 AND first_origin_lower >0 THEN 1990 - (first_origin_upper + first_origin_lower) / 2.0
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'Others' AND first_stand_photo_year >= 1990 AND first_origin_upper <0 AND first_origin_lower <0 THEN 1990 - species_mean
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'Others' AND first_stand_photo_year < 1990 THEN
	CASE 
		WHEN (dist_year_wnw IS NULL OR dist_year_wnw >1990 OR dist_year_wnw <first_stand_photo_year) AND (dist_year_canlad IS NULL OR dist_year_canlad >1990 OR dist_year_canlad < first_stand_photo_year) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 >1990 OR dist_casfri_year_1 < first_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN' AND dist_casfri_type_1 NOT LIKE 'CUT')) AND
		     (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 >1990 OR dist_nfdb_year_1 <first_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 >1990 OR dist_nfdb_year_2 <first_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 >1990 OR dist_nfdb_year_3 <first_stand_photo_year) AND
		     (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 >1990 OR dist_nfdb_year_4 <first_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 >1990 OR dist_nfdb_year_5 <first_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 >1990 OR dist_nfdb_year_6 <first_stand_photo_year) AND
		     (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 >1990 OR dist_nfdb_year_7 <first_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 >1990 OR dist_nfdb_year_7 <first_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 >1990 OR dist_nfdb_year_9 <first_stand_photo_year) THEN
				CASE WHEN first_stand_photo_year <= 1980 AND (first_origin_upper = 1769 OR first_origin_upper = 1771 OR first_origin_upper = 1774) THEN 1990 - (second_origin_upper + second_origin_lower) / 2.0           ------ Old FRI estimations on oldest trees not used, it seriously affect estimation in BC, instead we use recent estimation on same area
			             WHEN first_stand_photo_year < first_origin_upper AND first_origin_upper >0 THEN 1990 - species_mean                                                                                                   ------ appear in some old inventories, especially in MB
                                     WHEN first_origin_upper >0 AND first_origin_lower >0 THEN 1990 - (first_origin_upper + first_origin_lower) / 2.0
                                     WHEN first_origin_upper <0 AND first_origin_lower <0 AND species_mean IS NULL AND second_origin_upper >0 AND second_origin_lower >0 THEN 1990 - (second_origin_upper + second_origin_lower) / 2.0                   
                                     WHEN first_origin_upper <0 AND first_origin_lower <0 AND species_mean IS NULL AND second_origin_upper <0 AND second_origin_lower <0 THEN NULL                                                                       
				     WHEN first_origin_upper <0 AND first_origin_lower <0 THEN 1990 - species_mean END
	        ELSE (1990 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 1990 THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 1990 THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 1990 AND (dist_casfri_type_1 LIKE 'BURN' OR dist_casfri_type_1 LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 1990 THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 1990 THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 1990 THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 1990 THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 1990 THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 1990 THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 1990 THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 1990 THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 1990 THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END
  END
WHERE second_stand_photo_year > first_stand_photo_year +5; 


-- 3.2.1
-- check age based on changing categories

SELECT xy_id, first_cat, first_stand_photo_year, second_cat, second_stand_photo_year, first_origin_upper, first_origin_lower, second_origin_upper, second_origin_lower, species_mean, age_1990
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
where first_cat LIKE 'LYR' AND second_cat LIKE 'NFL'
AND second_stand_photo_year > first_stand_photo_year +5
ORDER BY age_1990 DESC
LIMIT 500


-- 3.2.2
-- check if disturbance successful deduct age

SELECT age_1990,species_mean, first_cat, first_stand_photo_year, second_cat, second_stand_photo_year, first_origin_upper, first_origin_lower, second_origin_upper, second_origin_lower,
	dist_year_wnw, dist_year_canlad, dist_casfri_year_1, dist_casfri_type_1, dist_nfdb_year_1, dist_nfdb_year_2, dist_nfdb_year_3, dist_nfdb_year_4, dist_nfdb_year_5
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
where first_cat LIKE 'LYR' AND second_cat LIKE 'NFL' AND first_stand_photo_year < 1990 AND age_1990 IS NULL
AND second_stand_photo_year > first_stand_photo_year +5
ORDER BY first_stand_photo_year ASC
LIMIT 500


--3.2.3
-- age structure check, counting valid, NULL, or negative age

SELECT age_1990, count(age_1990)
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
where second_stand_photo_year > first_stand_photo_year +5 AND Age_1990 IS NOT NULL
GROUP BY age_1990

------------------------------------------------------------------------------------------------------
---3.3 add a column to hold age2015, and calculate it under 4 changing conditions
------------------------------------------------------------------------------------------------------
-- calculate the age in 2015

UPDATE diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
SET Age_2015 = 
  CASE
    -- LYR->LYR 
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND second_stand_photo_year >= 2015 AND second_origin_upper >0 AND second_origin_lower >0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND second_stand_photo_year >= 2015 AND second_origin_upper <0 AND second_origin_lower <0 THEN 2015 - species_mean
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 THEN
	CASE 
	     WHEN (dist_year_wnw IS NULL OR dist_year_wnw > 2015 OR dist_year_wnw < second_stand_photo_year) AND (dist_year_canlad IS NULL OR dist_year_canlad > 2015 OR dist_year_canlad < second_stand_photo_year) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 > 2015 OR dist_casfri_year_1 < second_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN' AND dist_casfri_type_1 NOT LIKE 'CUT')) AND
		  (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 > 2015 OR dist_nfdb_year_1 < second_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 > 2015 OR dist_nfdb_year_2 < second_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 > 2015 OR dist_nfdb_year_3 < second_stand_photo_year) AND
		  (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 > 2015 OR dist_nfdb_year_4 < second_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 > 2015 OR dist_nfdb_year_5 < second_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 > 2015 OR dist_nfdb_year_6 < second_stand_photo_year) AND
		  (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 > 2015 OR dist_nfdb_year_7 < second_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 > 2015 OR dist_nfdb_year_8 < second_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 > 2015 OR dist_nfdb_year_9 < second_stand_photo_year) THEN
				CASE WHEN second_origin_upper>0 AND second_origin_lower>0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
				     WHEN second_origin_upper<0 AND second_origin_lower<0 AND first_origin_upper>0 AND first_origin_lower>0 THEN 2015 - (first_origin_upper + first_origin_lower) / 2.0
				     WHEN second_origin_upper<0 AND second_origin_lower<0 AND first_origin_upper<0 AND first_origin_lower<0 THEN NULL END
	     ELSE (2015 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 2015 AND dist_year_wnw >= second_stand_photo_year THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 2015 AND dist_year_canlad >= second_stand_photo_year THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 2015 AND dist_casfri_year_1 >= second_stand_photo_year AND (dist_casfri_type_1 LIKE 'BURN' OR dist_casfri_type_1 LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 2015 AND dist_nfdb_year_1 >= second_stand_photo_year THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 2015 AND dist_nfdb_year_2 >= second_stand_photo_year THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 2015 AND dist_nfdb_year_3 >= second_stand_photo_year THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 2015 AND dist_nfdb_year_4 >= second_stand_photo_year THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 2015 AND dist_nfdb_year_5 >= second_stand_photo_year THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 2015 AND dist_nfdb_year_6 >= second_stand_photo_year THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 2015 AND dist_nfdb_year_7 >= second_stand_photo_year THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 2015 AND dist_nfdb_year_8 >= second_stand_photo_year THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 2015 AND dist_nfdb_year_9 >= second_stand_photo_year THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 AND second_origin_upper >0 AND second_origin_lower >0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 AND second_origin_upper <0 AND second_origin_lower <0 THEN 2015 - species_mean

     -- NFL->NFL
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'NFL' THEN NULL

    -- NFL->LYR
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'LYR' AND second_stand_photo_year >= 2015 AND second_origin_upper >0 AND second_origin_lower >0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'LYR' AND second_stand_photo_year >= 2015 AND second_origin_upper <0 AND second_origin_lower <0 THEN 2015 - species_mean
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 THEN
	CASE 
	     WHEN (dist_year_wnw IS NULL OR dist_year_wnw > 2015 OR dist_year_wnw < second_stand_photo_year) AND (dist_year_canlad IS NULL OR dist_year_canlad > 2015 OR dist_year_canlad < second_stand_photo_year) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 > 2015 OR dist_casfri_year_1 < second_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN' AND dist_casfri_type_1 NOT LIKE 'CUT')) AND
		  (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 > 2015 OR dist_nfdb_year_1 < second_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 > 2015 OR dist_nfdb_year_2 < second_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 > 2015 OR dist_nfdb_year_3 < second_stand_photo_year) AND
		  (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 > 2015 OR dist_nfdb_year_4 < second_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 > 2015 OR dist_nfdb_year_5 < second_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 > 2015 OR dist_nfdb_year_6 < second_stand_photo_year) AND
		  (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 > 2015 OR dist_nfdb_year_7 < second_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 > 2015 OR dist_nfdb_year_8 < second_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 > 2015 OR dist_nfdb_year_9 < second_stand_photo_year) THEN
				CASE WHEN second_origin_upper>0 AND second_origin_lower>0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
				     WHEN second_origin_upper<0 AND second_origin_lower<0 AND first_origin_upper>0 AND first_origin_lower>0 THEN 2015 - (first_origin_upper + first_origin_lower) / 2.0
				     WHEN second_origin_upper<0 AND second_origin_lower<0 AND first_origin_upper<0 AND first_origin_lower<0 THEN NULL END
	     ELSE (2015 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 2015 AND dist_year_wnw >= second_stand_photo_year THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 2015 AND dist_year_canlad >= second_stand_photo_year THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 2015 AND dist_casfri_year_1 >= second_stand_photo_year AND (dist_casfri_type_1 LIKE 'BURN' OR dist_casfri_type_1 LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 2015 AND dist_nfdb_year_1 >= second_stand_photo_year THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 2015 AND dist_nfdb_year_2 >= second_stand_photo_year THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 2015 AND dist_nfdb_year_3 >= second_stand_photo_year THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 2015 AND dist_nfdb_year_4 >= second_stand_photo_year THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 2015 AND dist_nfdb_year_5 >= second_stand_photo_year THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 2015 AND dist_nfdb_year_6 >= second_stand_photo_year THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 2015 AND dist_nfdb_year_7 >= second_stand_photo_year THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 2015 AND dist_nfdb_year_8 >= second_stand_photo_year THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 2015 AND dist_nfdb_year_9 >= second_stand_photo_year THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 AND second_origin_upper >0 AND second_origin_lower >0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 AND second_origin_upper <0 AND second_origin_lower <0 THEN 2015 - species_mean

     -- LYR->NFL
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'NFL' AND second_stand_photo_year >= 2015 THEN 	                              ------ apply the disturbance record, age set as NULL if no disturbance record
	CASE 
		WHEN (dist_year_wnw IS NULL OR dist_year_wnw >2015 OR dist_year_wnw <=first_stand_photo_year) AND (dist_year_canlad IS NULL OR dist_year_canlad >2015 OR dist_year_canlad <=first_stand_photo_year) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 >2015 OR dist_casfri_year_1 <=first_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN' AND dist_casfri_type_1 NOT LIKE 'CUT')) AND
		     (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 >2015 OR dist_nfdb_year_1 <=first_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 >2015 OR dist_nfdb_year_2 <=first_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 >2015 OR dist_nfdb_year_3 <=first_stand_photo_year) AND
		     (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 >2015 OR dist_nfdb_year_4 <=first_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 >2015 OR dist_nfdb_year_5 <=first_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 >2015 OR dist_nfdb_year_6 <=first_stand_photo_year) AND
		     (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 >2015 OR dist_nfdb_year_7 <=first_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 >2015 OR dist_nfdb_year_8 <=first_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 >2015 OR dist_nfdb_year_9 <=first_stand_photo_year) THEN
		     CASE WHEN age_1990 IS NOT NULL THEN age_1990+25 ELSE NULL END
	        ELSE (2015 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 2015 THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 2015 THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 2015 AND (dist_casfri_type_1 LIKE 'BURN' OR dist_casfri_type_1 LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 2015 THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 2015 THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 2015 THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 2015 THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 2015 THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 2015 THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 2015 THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 2015 THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 2015 THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'NFL' AND second_stand_photo_year < 2015 THEN 	                              ------ apply the disturbance record, age set as NULL if no disturbance record
	CASE 
		WHEN (dist_year_wnw IS NULL OR dist_year_wnw >2015 OR dist_year_wnw <=first_stand_photo_year) AND (dist_year_canlad IS NULL OR dist_year_canlad >2015 OR dist_year_canlad <=first_stand_photo_year) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 >2015 OR dist_casfri_year_1 <=first_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN' AND dist_casfri_type_1 NOT LIKE 'CUT')) AND
		     (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 >2015 OR dist_nfdb_year_1 <=first_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 >2015 OR dist_nfdb_year_2 <=first_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 >2015 OR dist_nfdb_year_3 <=first_stand_photo_year) AND
		     (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 >2015 OR dist_nfdb_year_4 <=first_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 >2015 OR dist_nfdb_year_5 <=first_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 >2015 OR dist_nfdb_year_6 <=first_stand_photo_year) AND
		     (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 >2015 OR dist_nfdb_year_7 <=first_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 >2015 OR dist_nfdb_year_8 <=first_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 >2015 OR dist_nfdb_year_9 <=first_stand_photo_year) THEN
		     CASE WHEN age_1990 IS NOT NULL THEN 2015-second_stand_photo_year ELSE NULL END
	        ELSE (2015 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 2015 THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 2015 THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 2015 AND (dist_casfri_type_1 LIKE 'BURN' OR dist_casfri_type_1 LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 2015 THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 2015 THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 2015 THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 2015 THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 2015 THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 2015 THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 2015 THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 2015 THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 2015 THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END

    -- Others->LYR
    WHEN first_cat LIKE 'Others' AND second_cat LIKE 'LYR' AND second_stand_photo_year >= 2015 AND second_origin_upper >0 AND second_origin_lower >0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
    WHEN first_cat LIKE 'Others' AND second_cat LIKE 'LYR' AND second_stand_photo_year >= 2015 AND second_origin_upper <0 AND second_origin_lower <0 THEN 2015 - species_mean
    WHEN first_cat LIKE 'Others' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 THEN
	CASE 
	     WHEN (dist_year_wnw IS NULL OR dist_year_wnw > 2015 OR dist_year_wnw < second_stand_photo_year) AND (dist_year_canlad IS NULL OR dist_year_canlad > 2015 OR dist_year_canlad < second_stand_photo_year) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 > 2015 OR dist_casfri_year_1 < second_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN' AND dist_casfri_type_1 NOT LIKE 'CUT')) AND
		  (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 > 2015 OR dist_nfdb_year_1 < second_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 > 2015 OR dist_nfdb_year_2 < second_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 > 2015 OR dist_nfdb_year_3 < second_stand_photo_year) AND
		  (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 > 2015 OR dist_nfdb_year_4 < second_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 > 2015 OR dist_nfdb_year_5 < second_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 > 2015 OR dist_nfdb_year_6 < second_stand_photo_year) AND
		  (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 > 2015 OR dist_nfdb_year_7 < second_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 > 2015 OR dist_nfdb_year_8 < second_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 > 2015 OR dist_nfdb_year_9 < second_stand_photo_year) THEN
				CASE WHEN second_origin_upper>0 AND second_origin_lower>0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
				     WHEN second_origin_upper<0 AND second_origin_lower<0 AND first_origin_upper>0 AND first_origin_lower>0 THEN 2015 - (first_origin_upper + first_origin_lower) / 2.0
				     WHEN second_origin_upper<0 AND second_origin_lower<0 AND first_origin_upper<0 AND first_origin_lower<0 THEN NULL END
	     ELSE (2015 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 2015 AND dist_year_wnw >= second_stand_photo_year THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 2015 AND dist_year_canlad >= second_stand_photo_year THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 2015 AND dist_casfri_year_1 >= second_stand_photo_year AND (dist_casfri_type_1 LIKE 'BURN' OR dist_casfri_type_1 LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 2015 AND dist_nfdb_year_1 >= second_stand_photo_year THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 2015 AND dist_nfdb_year_2 >= second_stand_photo_year THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 2015 AND dist_nfdb_year_3 >= second_stand_photo_year THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 2015 AND dist_nfdb_year_4 >= second_stand_photo_year THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 2015 AND dist_nfdb_year_5 >= second_stand_photo_year THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 2015 AND dist_nfdb_year_6 >= second_stand_photo_year THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 2015 AND dist_nfdb_year_7 >= second_stand_photo_year THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 2015 AND dist_nfdb_year_8 >= second_stand_photo_year THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 2015 AND dist_nfdb_year_9 >= second_stand_photo_year THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END
    WHEN first_cat LIKE 'Others' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 AND second_origin_upper >0 AND second_origin_lower >0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
    WHEN first_cat LIKE 'Others' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 AND second_origin_upper <0 AND second_origin_lower <0 THEN 2015 - species_mean

     -- LYR->Others
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'Others' AND second_stand_photo_year >= 2015 THEN 	                              ------ apply the disturbance record, age set as NULL if no disturbance record
	CASE 
		WHEN (dist_year_wnw IS NULL OR dist_year_wnw >2015 OR dist_year_wnw <=first_stand_photo_year) AND (dist_year_canlad IS NULL OR dist_year_canlad >2015 OR dist_year_canlad <=first_stand_photo_year) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 >2015 OR dist_casfri_year_1 <=first_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN' AND dist_casfri_type_1 NOT LIKE 'CUT')) AND
		     (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 >2015 OR dist_nfdb_year_1 <=first_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 >2015 OR dist_nfdb_year_2 <=first_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 >2015 OR dist_nfdb_year_3 <=first_stand_photo_year) AND
		     (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 >2015 OR dist_nfdb_year_4 <=first_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 >2015 OR dist_nfdb_year_5 <=first_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 >2015 OR dist_nfdb_year_6 <=first_stand_photo_year) AND
		     (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 >2015 OR dist_nfdb_year_7 <=first_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 >2015 OR dist_nfdb_year_8 <=first_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 >2015 OR dist_nfdb_year_9 <=first_stand_photo_year) THEN
		     CASE WHEN age_1990 IS NOT NULL THEN age_1990+25 ELSE NULL END
	        ELSE (2015 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 2015 THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 2015 THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 2015 AND (dist_casfri_type_1 LIKE 'BURN' OR dist_casfri_type_1 LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 2015 THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 2015 THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 2015 THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 2015 THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 2015 THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 2015 THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 2015 THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 2015 THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 2015 THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'Others' AND second_stand_photo_year < 2015 THEN 	                              ------ apply the disturbance record, age set as NULL if no disturbance record
	CASE 
		WHEN (dist_year_wnw IS NULL OR dist_year_wnw >2015 OR dist_year_wnw <=first_stand_photo_year) AND (dist_year_canlad IS NULL OR dist_year_canlad >2015 OR dist_year_canlad <=first_stand_photo_year) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 >2015 OR dist_casfri_year_1 <=first_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN' AND dist_casfri_type_1 NOT LIKE 'CUT')) AND
		     (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 >2015 OR dist_nfdb_year_1 <=first_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 >2015 OR dist_nfdb_year_2 <=first_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 >2015 OR dist_nfdb_year_3 <=first_stand_photo_year) AND
		     (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 >2015 OR dist_nfdb_year_4 <=first_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 >2015 OR dist_nfdb_year_5 <=first_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 >2015 OR dist_nfdb_year_6 <=first_stand_photo_year) AND
		     (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 >2015 OR dist_nfdb_year_7 <=first_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 >2015 OR dist_nfdb_year_8 <=first_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 >2015 OR dist_nfdb_year_9 <=first_stand_photo_year) THEN
		     CASE WHEN age_1990 IS NOT NULL THEN 2015-second_stand_photo_year ELSE NULL END
	        ELSE (2015 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 2015 THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 2015 THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 2015 AND (dist_casfri_type_1 LIKE 'BURN' OR dist_casfri_type_1 LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 2015 THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 2015 THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 2015 THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 2015 THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 2015 THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 2015 THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 2015 THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 2015 THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 2015 THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END
  END
WHERE second_stand_photo_year > first_stand_photo_year +5; 
--AND bo_type LIKE 'BOREAL'; 

-- 3.3.1 disturbance age deduction check

SELECT age_1990, age_2015, first_cat, first_stand_photo_year, second_cat, second_stand_photo_year, first_origin_upper, first_origin_lower, second_origin_upper, second_origin_lower,
	dist_year_wnw, dist_year_canlad, dist_casfri_year_1, dist_casfri_type_1, dist_nfdb_year_1, dist_nfdb_year_2, dist_nfdb_year_3, dist_nfdb_year_4, dist_nfdb_year_5
	species_mean
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
where first_cat LIKE 'LYR' AND second_cat LIKE 'NFL' AND second_stand_photo_year > 2015
AND second_stand_photo_year > first_stand_photo_year +5
ORDER BY second_stand_photo_year ASC
LIMIT 500


-- 3.3.2 age reduction between 2 epoques

SELECT (age_1990-age_2015)as age_reduce, age_1990, age_2015, first_cat, first_stand_photo_year, second_cat, second_stand_photo_year, first_origin_upper, first_origin_lower, second_origin_upper, second_origin_lower,
	dist_year_wnw, dist_year_canlad, dist_casfri_year_1, dist_casfri_type_1, dist_nfdb_year_1, dist_nfdb_year_2, dist_nfdb_year_3, dist_nfdb_year_4, dist_nfdb_year_5
	species_mean
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
where first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND (age_1990-age_2015)> 0 
AND second_stand_photo_year > first_stand_photo_year +5 
ORDER BY (age_1990-age_2015) DESC
LIMIT 500

--
--3.3.3 age structure check

SELECT age_2015, count(age_2015)
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015 
where second_stand_photo_year > first_stand_photo_year +5 AND age_2015 >0
GROUP BY age_2015

--------------------------------------------------------------------------------------------------------------------------------------
---3.4 add a column to hold age_2015_noDist, using age_2015 calculating method, only without the interference of disturbance records 
--------------------------------------------------------------------------------------------------------------------------------------
UPDATE diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015 
SET age_2015_noLogging = 
  CASE
    -- LYR->LYR 
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND second_stand_photo_year >= 2015 AND second_origin_upper >0 AND second_origin_lower >0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND second_stand_photo_year >= 2015 AND second_origin_upper <0 AND second_origin_lower <0 THEN 2015 - species_mean
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 THEN
	CASE 
	     WHEN (dist_year_wnw IS NULL OR dist_year_wnw > 2015 OR dist_year_wnw < second_stand_photo_year OR dist_type_wnw LIKE 'CUT') AND (dist_year_canlad IS NULL OR dist_year_canlad > 2015 OR dist_year_canlad < second_stand_photo_year OR dist_year_canlad =2) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 > 2015 OR dist_casfri_year_1 < second_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN')) AND
		  (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 > 2015 OR dist_nfdb_year_1 < second_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 > 2015 OR dist_nfdb_year_2 < second_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 > 2015 OR dist_nfdb_year_3 < second_stand_photo_year) AND
		  (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 > 2015 OR dist_nfdb_year_4 < second_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 > 2015 OR dist_nfdb_year_5 < second_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 > 2015 OR dist_nfdb_year_6 < second_stand_photo_year) AND
		  (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 > 2015 OR dist_nfdb_year_7 < second_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 > 2015 OR dist_nfdb_year_8 < second_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 > 2015 OR dist_nfdb_year_9 < second_stand_photo_year) THEN
				CASE WHEN second_origin_upper>0 AND second_origin_lower>0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
				     WHEN second_origin_upper<0 AND second_origin_lower<0 AND first_origin_upper>0 AND first_origin_lower>0 THEN 2015 - (first_origin_upper + first_origin_lower) / 2.0
				     WHEN second_origin_upper<0 AND second_origin_lower<0 AND first_origin_upper<0 AND first_origin_lower<0 THEN NULL END
	     ELSE (2015 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 2015 AND dist_year_wnw >= second_stand_photo_year THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 2015 AND dist_year_canlad >= second_stand_photo_year THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 2015 AND dist_casfri_year_1 >= second_stand_photo_year AND (dist_casfri_type_1 NOT LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 2015 AND dist_nfdb_year_1 >= second_stand_photo_year THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 2015 AND dist_nfdb_year_2 >= second_stand_photo_year THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 2015 AND dist_nfdb_year_3 >= second_stand_photo_year THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 2015 AND dist_nfdb_year_4 >= second_stand_photo_year THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 2015 AND dist_nfdb_year_5 >= second_stand_photo_year THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 2015 AND dist_nfdb_year_6 >= second_stand_photo_year THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 2015 AND dist_nfdb_year_7 >= second_stand_photo_year THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 2015 AND dist_nfdb_year_8 >= second_stand_photo_year THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 2015 AND dist_nfdb_year_9 >= second_stand_photo_year THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 AND second_origin_upper >0 AND second_origin_lower >0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 AND second_origin_upper <0 AND second_origin_lower <0 THEN 2015 - species_mean

    -- NFL->NFL
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'NFL' THEN NULL

    -- NFL->LYR
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'LYR' AND second_stand_photo_year >= 2015 AND second_origin_upper >0 AND second_origin_lower >0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'LYR' AND second_stand_photo_year >= 2015 AND second_origin_upper <0 AND second_origin_lower <0 THEN 2015 - species_mean
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 THEN
	CASE 
	     WHEN (dist_year_wnw IS NULL OR dist_year_wnw > 2015 OR dist_year_wnw < second_stand_photo_year OR dist_type_wnw LIKE 'CUT') AND (dist_year_canlad IS NULL OR dist_year_canlad > 2015 OR dist_year_canlad < second_stand_photo_year OR dist_year_canlad =2) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 > 2015 OR dist_casfri_year_1 < second_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN')) AND
		  (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 > 2015 OR dist_nfdb_year_1 < second_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 > 2015 OR dist_nfdb_year_2 < second_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 > 2015 OR dist_nfdb_year_3 < second_stand_photo_year) AND
		  (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 > 2015 OR dist_nfdb_year_4 < second_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 > 2015 OR dist_nfdb_year_5 < second_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 > 2015 OR dist_nfdb_year_6 < second_stand_photo_year) AND
		  (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 > 2015 OR dist_nfdb_year_7 < second_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 > 2015 OR dist_nfdb_year_8 < second_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 > 2015 OR dist_nfdb_year_9 < second_stand_photo_year) THEN
				CASE WHEN second_origin_upper>0 AND second_origin_lower>0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
				     WHEN second_origin_upper<0 AND second_origin_lower<0 AND first_origin_upper>0 AND first_origin_lower>0 THEN 2015 - (first_origin_upper + first_origin_lower) / 2.0
				     WHEN second_origin_upper<0 AND second_origin_lower<0 AND first_origin_upper<0 AND first_origin_lower<0 THEN NULL END
	     ELSE (2015 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 2015 AND dist_year_wnw >= second_stand_photo_year THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 2015 AND dist_year_canlad >= second_stand_photo_year THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 2015 AND dist_casfri_year_1 >= second_stand_photo_year AND (dist_casfri_type_1 NOT LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 2015 AND dist_nfdb_year_1 >= second_stand_photo_year THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 2015 AND dist_nfdb_year_2 >= second_stand_photo_year THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 2015 AND dist_nfdb_year_3 >= second_stand_photo_year THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 2015 AND dist_nfdb_year_4 >= second_stand_photo_year THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 2015 AND dist_nfdb_year_5 >= second_stand_photo_year THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 2015 AND dist_nfdb_year_6 >= second_stand_photo_year THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 2015 AND dist_nfdb_year_7 >= second_stand_photo_year THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 2015 AND dist_nfdb_year_8 >= second_stand_photo_year THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 2015 AND dist_nfdb_year_9 >= second_stand_photo_year THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 AND second_origin_upper >0 AND second_origin_lower >0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
    WHEN first_cat LIKE 'NFL' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 AND second_origin_upper <0 AND second_origin_lower <0 THEN 2015 - species_mean

     -- LYR->NFL
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'NFL' THEN 
	CASE 
		WHEN (dist_year_wnw IS NULL OR dist_year_wnw >2015 OR dist_year_wnw <=first_stand_photo_year OR dist_type_wnw LIKE 'CUT') AND (dist_year_canlad IS NULL OR dist_year_canlad >2015 OR dist_year_canlad <=first_stand_photo_year OR dist_year_canlad =2) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 >2015 OR dist_casfri_year_1 <=first_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN')) AND
		     (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 >2015 OR dist_nfdb_year_1 <=first_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 >2015 OR dist_nfdb_year_2 <=first_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 >2015 OR dist_nfdb_year_3 <=first_stand_photo_year) AND
		     (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 >2015 OR dist_nfdb_year_4 <=first_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 >2015 OR dist_nfdb_year_5 <=first_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 >2015 OR dist_nfdb_year_6 <=first_stand_photo_year) AND
		     (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 >2015 OR dist_nfdb_year_7 <=first_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 >2015 OR dist_nfdb_year_8 <=first_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 >2015 OR dist_nfdb_year_9 <=first_stand_photo_year) THEN
		     CASE WHEN age_1990 IS NOT NULL THEN age_1990+25 ELSE NULL END
	        ELSE (2015 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 2015 THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 2015 THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 2015 AND (dist_casfri_type_1 NOT LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 2015 THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 2015 THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 2015 THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 2015 THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 2015 THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 2015 THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 2015 THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 2015 THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 2015 THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END

    -- Others->LYR
    WHEN first_cat LIKE 'Others' AND second_cat LIKE 'LYR' AND second_stand_photo_year >= 2015 AND second_origin_upper >0 AND second_origin_lower >0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
    WHEN first_cat LIKE 'Others' AND second_cat LIKE 'LYR' AND second_stand_photo_year >= 2015 AND second_origin_upper <0 AND second_origin_lower <0 THEN 2015 - species_mean
    WHEN first_cat LIKE 'Others' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 THEN
	CASE 
	     WHEN (dist_year_wnw IS NULL OR dist_year_wnw > 2015 OR dist_year_wnw < second_stand_photo_year OR dist_type_wnw LIKE 'CUT') AND (dist_year_canlad IS NULL OR dist_year_canlad > 2015 OR dist_year_canlad < second_stand_photo_year OR dist_year_canlad =2) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 > 2015 OR dist_casfri_year_1 < second_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN')) AND
		  (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 > 2015 OR dist_nfdb_year_1 < second_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 > 2015 OR dist_nfdb_year_2 < second_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 > 2015 OR dist_nfdb_year_3 < second_stand_photo_year) AND
		  (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 > 2015 OR dist_nfdb_year_4 < second_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 > 2015 OR dist_nfdb_year_5 < second_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 > 2015 OR dist_nfdb_year_6 < second_stand_photo_year) AND
		  (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 > 2015 OR dist_nfdb_year_7 < second_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 > 2015 OR dist_nfdb_year_8 < second_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 > 2015 OR dist_nfdb_year_9 < second_stand_photo_year) THEN
				CASE WHEN second_origin_upper>0 AND second_origin_lower>0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
				     WHEN second_origin_upper<0 AND second_origin_lower<0 AND first_origin_upper>0 AND first_origin_lower>0 THEN 2015 - (first_origin_upper + first_origin_lower) / 2.0
				     WHEN second_origin_upper<0 AND second_origin_lower<0 AND first_origin_upper<0 AND first_origin_lower<0 THEN NULL END
	     ELSE (2015 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 2015 AND dist_year_wnw >= second_stand_photo_year THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 2015 AND dist_year_canlad >= second_stand_photo_year THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 2015 AND dist_casfri_year_1 >= second_stand_photo_year AND (dist_casfri_type_1 NOT LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 2015 AND dist_nfdb_year_1 >= second_stand_photo_year THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 2015 AND dist_nfdb_year_2 >= second_stand_photo_year THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 2015 AND dist_nfdb_year_3 >= second_stand_photo_year THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 2015 AND dist_nfdb_year_4 >= second_stand_photo_year THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 2015 AND dist_nfdb_year_5 >= second_stand_photo_year THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 2015 AND dist_nfdb_year_6 >= second_stand_photo_year THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 2015 AND dist_nfdb_year_7 >= second_stand_photo_year THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 2015 AND dist_nfdb_year_8 >= second_stand_photo_year THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 2015 AND dist_nfdb_year_9 >= second_stand_photo_year THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END
    WHEN first_cat LIKE 'Others' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 AND second_origin_upper >0 AND second_origin_lower >0 THEN 2015 - (second_origin_upper + second_origin_lower) / 2.0
    WHEN first_cat LIKE 'Others' AND second_cat LIKE 'LYR' AND second_stand_photo_year < 2015 AND second_origin_upper <0 AND second_origin_lower <0 THEN 2015 - species_mean

     -- LYR->Others
    WHEN first_cat LIKE 'LYR' AND second_cat LIKE 'Others' THEN 
	CASE 
		WHEN (dist_year_wnw IS NULL OR dist_year_wnw >2015 OR dist_year_wnw <=first_stand_photo_year OR dist_type_wnw LIKE 'CUT') AND (dist_year_canlad IS NULL OR dist_year_canlad >2015 OR dist_year_canlad <=first_stand_photo_year OR dist_year_canlad =2) AND (dist_casfri_year_1 IS NULL OR dist_casfri_year_1 >2015 OR dist_casfri_year_1 <=first_stand_photo_year OR (dist_casfri_type_1 NOT LIKE 'BURN')) AND
		     (dist_nfdb_year_1 IS NULL OR dist_nfdb_year_1 >2015 OR dist_nfdb_year_1 <=first_stand_photo_year) AND (dist_nfdb_year_2 IS NULL OR dist_nfdb_year_2 >2015 OR dist_nfdb_year_2 <=first_stand_photo_year) AND (dist_nfdb_year_3 IS NULL OR dist_nfdb_year_3 >2015 OR dist_nfdb_year_3 <=first_stand_photo_year) AND
		     (dist_nfdb_year_4 IS NULL OR dist_nfdb_year_4 >2015 OR dist_nfdb_year_4 <=first_stand_photo_year) AND (dist_nfdb_year_5 IS NULL OR dist_nfdb_year_5 >2015 OR dist_nfdb_year_5 <=first_stand_photo_year) AND (dist_nfdb_year_6 IS NULL OR dist_nfdb_year_6 >2015 OR dist_nfdb_year_6 <=first_stand_photo_year) AND
		     (dist_nfdb_year_7 IS NULL OR dist_nfdb_year_7 >2015 OR dist_nfdb_year_7 <=first_stand_photo_year) AND (dist_nfdb_year_8 IS NULL OR dist_nfdb_year_8 >2015 OR dist_nfdb_year_8 <=first_stand_photo_year) AND (dist_nfdb_year_9 IS NULL OR dist_nfdb_year_9 >2015 OR dist_nfdb_year_9 <=first_stand_photo_year) THEN
		     CASE WHEN age_1990 IS NOT NULL THEN age_1990+25 ELSE NULL END
	        ELSE (2015 - COALESCE(
	   	   GREATEST(
   		   CASE WHEN dist_year_wnw <= 2015 THEN dist_year_wnw ELSE NULL END,
    		   CASE WHEN dist_year_canlad <= 2015 THEN dist_year_canlad ELSE NULL END,
   		   CASE WHEN dist_casfri_year_1 <= 2015 AND (dist_casfri_type_1 NOT LIKE 'CUT') THEN dist_casfri_year_1 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_1 <= 2015 THEN dist_nfdb_year_1 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_2 <= 2015 THEN dist_nfdb_year_2 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_3 <= 2015 THEN dist_nfdb_year_3 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_4 <= 2015 THEN dist_nfdb_year_4 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_5 <= 2015 THEN dist_nfdb_year_5 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_6 <= 2015 THEN dist_nfdb_year_6 ELSE NULL END,
   		   CASE WHEN dist_nfdb_year_7 <= 2015 THEN dist_nfdb_year_7 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_8 <= 2015 THEN dist_nfdb_year_8 ELSE NULL END,
    		   CASE WHEN dist_nfdb_year_9 <= 2015 THEN dist_nfdb_year_9 ELSE NULL END
 		   ),0))
	 END	 
  END
WHERE second_stand_photo_year > first_stand_photo_year +5; 

------------------------------------------------------------------------------------------------------
---3.5 making plots on age_1990, age_2015, and age_2015_noDist
------------------------------------------------------------------------------------------------------

--3.3 two ages of different epoques overlay by decades, not finished -- the third CTE should use a new column

WITH Age_1990 AS
(SELECT FLOOR(age_1990 / 10)*10 as age_group_1990, count(*) as count_1990
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015  
where second_stand_photo_year > first_stand_photo_year +5
GROUP BY age_group_1990
),
Age_2015 AS
(SELECT FLOOR(age_2015 / 10)*10 as age_group_2015, count(*) as count_2015
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015 
where second_stand_photo_year > first_stand_photo_year +5
GROUP BY age_group_2015
),
Age_2015_noLogging AS
(SELECT FLOOR(age_2015_noLogging / 10)*10 as age_group_2015_noLogging, count(*) as count_2015_noLogging
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015 
where second_stand_photo_year > first_stand_photo_year +5
GROUP BY age_group_2015_noLogging
)
SELECT COALESCE(Age_1990.age_group_1990, Age_2015.age_group_2015, Age_2015_noLogging.age_group_2015_noLogging) AS year, *
FROM Age_1990
full join Age_2015 on Age_1990.age_group_1990 = Age_2015.age_group_2015
full join Age_2015_noLogging on Age_1990.age_group_1990 = Age_2015_noLogging.age_group_2015_noLogging
WHERE age_1990 IS NOT NULL AND age_2015 Is NOT NULL
ORDER BY year ASC

------------------------------------------------------------------------------------------------------
--3.5 two ages of different epopues overlay (EAST side)

WITH Age_1990 AS
(SELECT age_1990, count(*) as count_1990
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015 
where second_stand_photo_year > first_stand_photo_year +5 AND rocky_side LIKE 'EAST'
GROUP BY age_1990
),
Age_2015 AS
(SELECT age_2015, count(*) as count_2015
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015 
where second_stand_photo_year > first_stand_photo_year +5 AND rocky_side LIKE 'EAST'
GROUP BY age_2015
)
SELECT COALESCE(Age_1990.age_1990, Age_2015.age_2015) AS year, *
FROM Age_1990
full join Age_2015 on Age_1990.age_1990 = Age_2015.age_2015
WHERE age_1990 IS NOT NULL AND age_2015 Is NOT NULL
ORDER BY year ASC


--3.5 two ages of different epopues overlay (WEST side)

WITH Age_1990 AS
(SELECT age_1990, count(*) as count_1990
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015 
where second_stand_photo_year > first_stand_photo_year +5 AND rocky_side LIKE 'WEST'
GROUP BY age_1990
),
Age_2015 AS
(SELECT age_2015, count(*) as count_2015
FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015 
where second_stand_photo_year > first_stand_photo_year +5 AND rocky_side LIKE 'WEST'
GROUP BY age_2015
)
SELECT COALESCE(Age_1990.age_1990, Age_2015.age_2015) AS year, *
FROM Age_1990
full join Age_2015 on Age_1990.age_1990 = Age_2015.age_2015
WHERE age_1990 IS NOT NULL AND age_2015 Is NOT NULL
ORDER BY year ASC


--3.6 show the historical inventory origin problem

SELECT
    FLOOR(second_origin_upper / 10) * 10 AS decade,
    COUNT(*) AS count_per_decade
FROM
    diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015
WHERE
    first_stand_photo_year + 5 < second_stand_photo_year
    AND (first_origin_upper = 1769 OR first_origin_upper = 1771 OR first_origin_upper = 1774)
    AND second_origin_upper IS NOT NULL AND  second_origin_upper >=1700
GROUP BY
    FLOOR(second_origin_upper / 10) * 10
ORDER BY
    decade;
