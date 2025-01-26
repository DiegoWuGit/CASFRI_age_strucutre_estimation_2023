##############################################################################################################################
##### Project Name:
######Assessing change in forest age structure in the western boreal forest using CASFRI and remote sensing products
#####
##### Author:
######Siu Chung Wu (Diego)
#####
##### Date:
######2024 Mar 1
##############################################################################################################################
###### Module 8.1 
###### Sample R command for generating photo year plots
##############################################################################################################################


# connect CASFRI database and load library
library(DBI)
library(RPostgreSQL)
library(ggplot2)
library(hexbin)
library(tidyverse)
library(patchwork)


#clean when necessary
#rm(list = ls())


# input the resulting, tenure stratified tables
# table names example:
# diego_test.FNmb_CASFRI_changedscas_fullf_age9015 (or changing MB to AB/SK)
# diego_test.FNab_CASFRI_changedscas_fullf_bore_age9015 (or changing bore to hemi)

result <- dbGetQuery(conn,"SELECT * FROM diego_test.FNbc_CASFRI_changedscas_fullf_bore_age9015")

#############################################################################################
Alberta (AB) below
#############################################################################################
# For resultAB DataFrame
# Count occurrences of each year for the first photo year, and add distribution percentage for AB
first_photo_counts_AB <- resultAB %>%
  filter(first_stand_photo_year +5 < second_stand_photo_year) %>%
  count(first_stand_photo_year) %>%
  mutate(distribution_pct = n / sum(n) * 100, photo_type = "First Stand Photo AB")

# Count occurrences of each year for the second photo year, and add distribution percentage for AB
second_photo_counts_AB <- resultAB %>%
  filter(first_stand_photo_year + 5 < second_stand_photo_year) %>%
  count(second_stand_photo_year) %>%
  mutate(distribution_pct = n / sum(n) * 100, photo_type = "Second Stand Photo AB")

# Combine both sets for AB
photo_counts_combined_AB <- bind_rows(first_photo_counts_AB, second_photo_counts_AB) %>%
  mutate(year = if_else(!is.na(first_stand_photo_year), as.character(first_stand_photo_year), as.character(second_stand_photo_year)))

# Ensure all years from 1970 to 2020 are present in the data for plotting for AB
all_years_AB <- data.frame(year = as.character(1970:2020))
photo_counts_combined_AB <- full_join(all_years_AB, photo_counts_combined_AB, by = "year")

# Replace NAs with zeros after the join for AB
photo_counts_combined_AB$n[is.na(photo_counts_combined_AB$n)] <- 0
photo_counts_combined_AB$distribution_pct[is.na(photo_counts_combined_AB$distribution_pct)] <- 0

# Calculate the total count of all photo years for AB
total_count_AB <- sum(photo_counts_combined_AB$n)

# Create the plot with both sets of data stacked for AB
pAB <- ggplot(photo_counts_combined_AB, aes(x = year, y = distribution_pct, fill = photo_type)) +
  geom_bar(stat = "identity", position = "stack", color = "black", size = 0.1) +
  scale_fill_manual(values = c("First Stand Photo AB" = "turquoise1", "Second Stand Photo AB" = "violet")) +
  scale_y_continuous(
    name = "Distribution (%)",
    sec.axis = sec_axis(~ . / 100 * total_count_AB, name = "Count")
  ) +
  scale_x_discrete(
    name = "Year",
    breaks = as.character(seq(1970, 2020, by = 10)),  
    labels = seq(1970, 2020, by = 10)
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom", 
    legend.title = element_blank(),  
    legend.box = "horizontal",  
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"),
    plot.margin = margin(b = 10)  
  ) +
  labs(
    x = "Years",
    fill = "Photo Type" 
  ) 
#############################################################################################
Saskatchewan (SK) below
#############################################################################################
# For resultSK DataFrame
first_photo_counts_SK <- resultSK %>%
  filter(first_stand_photo_year +5 < second_stand_photo_year) %>%
  count(first_stand_photo_year) %>%
  mutate(distribution_pct = n / sum(n) * 100, photo_type = "First Stand Photo SK")

second_photo_counts_SK <- resultSK %>%
  filter(first_stand_photo_year + 5 < second_stand_photo_year) %>%
  count(second_stand_photo_year) %>%
  mutate(distribution_pct = n / sum(n) * 100, photo_type = "Second Stand Photo SK")

photo_counts_combined_SK <- bind_rows(first_photo_counts_SK, second_photo_counts_SK) %>%
  mutate(year = if_else(!is.na(first_stand_photo_year), as.character(first_stand_photo_year), as.character(second_stand_photo_year)))

all_years_SK <- data.frame(year = as.character(1970:2020))
photo_counts_combined_SK <- full_join(all_years_SK, photo_counts_combined_SK, by = "year")

photo_counts_combined_SK$n[is.na(photo_counts_combined_SK$n)] <- 0
photo_counts_combined_SK$distribution_pct[is.na(photo_counts_combined_SK$distribution_pct)] <- 0

total_count_SK <- sum(photo_counts_combined_SK$n)

pSK <- ggplot(photo_counts_combined_SK, aes(x = year, y = distribution_pct, fill = photo_type)) +
  geom_bar(stat = "identity", position = "stack", color = "black", size = 0.1) +
  scale_fill_manual(values = c("First Stand Photo SK" = "turquoise1", "Second Stand Photo SK" = "violet")) +
  scale_y_continuous(
    name = "Distribution (%)",
    sec.axis = sec_axis(
      trans = ~ . / 100 * total_count_SK,
      name = "Count",
      labels = label_number() 
    )
  ) +
  scale_x_discrete(
    name = "Year",
    breaks = as.character(seq(1970, 2020, by = 10)),
    labels = seq(1970, 2020, by = 10)
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom", 
    legend.title = element_blank(), 
    legend.box = "horizontal",
    axis.text.x = element_text(angle = 90, hjust = 1), 
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"), 
    plot.margin = margin(b = 10)
  ) +
  labs(x = "Years", fill = "Photo Type")

# Print the plot
print(pSK)
#############################################################################################
Manitoba (MB) below
#############################################################################################
# For resultMB DataFrame
# Count occurrences of each year for the first photo year in Manitoba, and Add distribution percentage
first_photo_counts_MB <- resultMB %>%
  filter(first_stand_photo_year +5 < second_stand_photo_year) %>%
  count(first_stand_photo_year) %>%
  mutate(distribution_pct = n / sum(n) * 100, photo_type = "First Stand Photo MB")

# Count occurrences of each year for the second photo year in Manitoba, and Add distribution percentage
second_photo_counts_MB <- resultMB %>%
  filter(first_stand_photo_year + 5 < second_stand_photo_year) %>%
  count(second_stand_photo_year) %>%
  mutate(distribution_pct = n / sum(n) * 100, photo_type = "Second Stand Photo MB")

# Combine both sets for Manitoba
photo_counts_combined_MB <- bind_rows(first_photo_counts_MB, second_photo_counts_MB) %>%
  mutate(year = if_else(!is.na(first_stand_photo_year), as.character(first_stand_photo_year), as.character(second_stand_photo_year)))

# Ensure all years from 1970 to 2020 are present in the data for plotting for Manitoba
all_years_MB <- data.frame(year = as.character(1970:2020))
photo_counts_combined_MB <- full_join(all_years_MB, photo_counts_combined_MB, by = "year")

# Replace NAs with zeros after the join for Manitoba
photo_counts_combined_MB$n[is.na(photo_counts_combined_MB$n)] <- 0
photo_counts_combined_MB$distribution_pct[is.na(photo_counts_combined_MB$distribution_pct)] <- 0

# Calculate the total count of all photo years for Manitoba
total_count_MB <- sum(photo_counts_combined_MB$n)

# Create the plot with both sets of data stacked for Manitoba
pMB <- ggplot(photo_counts_combined_MB, aes(x = year, y = distribution_pct, fill = photo_type)) +
  geom_bar(stat = "identity", position = "stack", color = "black", size = 0.1) +
  scale_fill_manual(values = c("First Stand Photo MB" = "turquoise1", "Second Stand Photo MB" = "violet")) +
  scale_y_continuous(
    name = "Distribution (%)",
    sec.axis = sec_axis(
      trans = ~ . / 100 * total_count_MB,
      name = "Count",
      labels = label_number()  
    )
  ) +
  scale_x_discrete(
    name = "Year",
    breaks = as.character(seq(1970, 2020, by = 10)), 
    labels = seq(1970, 2020, by = 10)
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom", 
    legend.title = element_blank(), 
    legend.box = "horizontal", 
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"),
    plot.margin = margin(b = 10)  
  ) +
  labs(
    x = "Years",
    fill = "Photo Type"
  )

#############################################################################################
# Combine the plots side by side
pAB + pSK + pMB + plot_layout(ncol = 3)
#############################################################################################
Hemiboreal (BC) below
#############################################################################################
# Count occurrences of each year for the first photo year in Hemiboreal, and add distribution percentage
first_photo_counts_hemi <- resulthemi %>%
  filter(first_stand_photo_year + 5 < second_stand_photo_year) %>%
  count(first_stand_photo_year) %>%
  mutate(distribution_pct = n / sum(n) * 100, photo_type = "First Stand Photo hemi")

# Count occurrences of each year for the second photo year in Hemiboreal, and add distribution percentage
second_photo_counts_hemi <- resulthemi %>%
  filter(first_stand_photo_year + 5 < second_stand_photo_year) %>%
  count(second_stand_photo_year) %>%
  mutate(distribution_pct = n / sum(n) * 100, photo_type = "Second Stand Photo hemi")

# Combine both sets for Hemiboreal
photo_counts_combined_hemi <- bind_rows(first_photo_counts_hemi, second_photo_counts_hemi) %>%
  mutate(year = if_else(!is.na(first_stand_photo_year), as.character(first_stand_photo_year), as.character(second_stand_photo_year)))

# Ensure all years from 1970 to 2020 are present in the data for plotting for Hemiboreal
all_years_hemi <- data.frame(year = as.character(1950:2020))
photo_counts_combined_hemi <- full_join(all_years_hemi, photo_counts_combined_hemi, by = "year")

# Replace NAs with zeros after the join for Hemiboreal
photo_counts_combined_hemi$n[is.na(photo_counts_combined_hemi$n)] <- 0
photo_counts_combined_hemi$distribution_pct[is.na(photo_counts_combined_hemi$distribution_pct)] <- 0

# Calculate the total count of all photo years for Hemiboreal
total_count_hemi <- sum(photo_counts_combined_hemi$n)

# Create the plot with both sets of data stacked for Hemiboreal
pHemi <- ggplot(photo_counts_combined_hemi, aes(x = year, y = distribution_pct, fill = photo_type)) +
  geom_bar(stat = "identity", position = "stack", color = "black", size = 0.1) +
  scale_fill_manual(values = c("First Stand Photo hemi" = "turquoise1", "Second Stand Photo hemi" = "violet")) +
  scale_y_continuous(
    name = "Distribution (%)",
    sec.axis = sec_axis(
      trans = ~ . / 100 * total_count_hemi,
      name = "Count",
      labels = label_number()
    )
  ) +
  scale_x_discrete(
    name = "Year",
    breaks = as.character(seq(1950, 2020, by = 10)), 
    labels = seq(1950, 2020, by = 10)
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom", 
    legend.title = element_blank(), 
    legend.box = "horizontal", 
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"),
    plot.margin = margin(b = 10)  
  ) +
  labs(
    x = "Years",
    fill = "Photo Type"
  )

# Display the plot
print(pHemi)

#############################################################################################
Boreal West (BC) below
#############################################################################################
#Count occurrences of each year for the first photo year in Boreal West, and add distribution percentage
first_photo_counts_boreW <- resultbore %>%
  filter(first_stand_photo_year + 5 < second_stand_photo_year, rocky_side == 'WEST') %>%
  count(first_stand_photo_year) %>%
  mutate(distribution_pct = n / sum(n) * 100, photo_type = "First Stand Photo boreW")

# Count occurrences of each year for the second photo year in Boreal West, and add distribution percentage
second_photo_counts_boreW <- resultbore %>%
  filter(first_stand_photo_year + 5 < second_stand_photo_year, rocky_side == 'WEST') %>%
  count(second_stand_photo_year) %>%
  mutate(distribution_pct = n / sum(n) * 100, photo_type = "Second Stand Photo boreW")

# Combine both sets for Boreal West
photo_counts_combined_boreW <- bind_rows(first_photo_counts_boreW, second_photo_counts_boreW) %>%
  mutate(year = if_else(!is.na(first_stand_photo_year), as.character(first_stand_photo_year), as.character(second_stand_photo_year)))

# Ensure all years from 1970 to 2020 are present in the data for plotting for Boreal West
all_years_boreW <- data.frame(year = as.character(1950:2020))
photo_counts_combined_boreW <- full_join(all_years_boreW, photo_counts_combined_boreW, by = "year")

# Replace NAs with zeros after the join for Boreal West
photo_counts_combined_boreW$n[is.na(photo_counts_combined_boreW$n)] <- 0
photo_counts_combined_boreW$distribution_pct[is.na(photo_counts_combined_boreW$distribution_pct)] <- 0

# Calculate the total count of all photo years for Boreal West
total_count_boreW <- sum(photo_counts_combined_boreW$n)

# Create the plot with both sets of data stacked for Boreal West
pBoreW <- ggplot(photo_counts_combined_boreW, aes(x = year, y = distribution_pct, fill = photo_type)) +
  geom_bar(stat = "identity", position = "stack", color = "black", size = 0.1) +
  scale_fill_manual(values = c("First Stand Photo boreW" = "turquoise1", "Second Stand Photo boreW" = "violet")) +
  scale_y_continuous(
    name = "Distribution (%)",
    sec.axis = sec_axis(
      trans = ~ . / 100 * total_count_boreW,
      name = "Count",
      labels = label_number() 
    )
  ) +
  scale_x_discrete(
    name = "Year",
    breaks = as.character(seq(1950, 2020, by = 10)), 
    labels = seq(1950, 2020, by = 10)
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom", 
    legend.title = element_blank(), 
    legend.box = "horizontal", 
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"),
    plot.margin = margin(b = 10)
  ) +
  labs(
    x = "Years",
    fill = "Photo Type"
  )

# Display the plot
print(pBoreW)

#############################################################################################
Boreal East (BC) below
#############################################################################################
# Count occurrences of each year for the first photo year in Boreal East, and add distribution percentage
first_photo_counts_boreE <- resultbore %>%
  filter(first_stand_photo_year + 5 < second_stand_photo_year, rocky_side == 'EAST') %>%
  count(first_stand_photo_year) %>%
  mutate(distribution_pct = n / sum(n) * 100, photo_type = "First Stand Photo boreE")

# Count occurrences of each year for the second photo year in Boreal East, and add distribution percentage
second_photo_counts_boreE <- resultbore %>%
  filter(first_stand_photo_year + 5 < second_stand_photo_year, rocky_side == 'EAST') %>%
  count(second_stand_photo_year) %>%
  mutate(distribution_pct = n / sum(n) * 100, photo_type = "Second Stand Photo boreE")

# Combine both sets for Boreal East
photo_counts_combined_boreE <- bind_rows(first_photo_counts_boreE, second_photo_counts_boreE) %>%
  mutate(year = if_else(!is.na(first_stand_photo_year), as.character(first_stand_photo_year), as.character(second_stand_photo_year)))

# Ensure all years from 1970 to 2020 are present in the data for plotting for Boreal East
all_years_boreE <- data.frame(year = as.character(1950:2020))
photo_counts_combined_boreE <- full_join(all_years_boreE, photo_counts_combined_boreE, by = "year")

# Replace NAs with zeros after the join for Boreal East
photo_counts_combined_boreE$n[is.na(photo_counts_combined_boreE$n)] <- 0
photo_counts_combined_boreE$distribution_pct[is.na(photo_counts_combined_boreE$distribution_pct)] <- 0

# Calculate the total count of all photo years for Boreal East
total_count_boreE <- sum(photo_counts_combined_boreE$n)

# Create the plot with both sets of data stacked for Boreal East
pBoreE <- ggplot(photo_counts_combined_boreE, aes(x = year, y = distribution_pct, fill = photo_type)) +
  geom_bar(stat = "identity", position = "stack", color = "black", size = 0.1) +
  scale_fill_manual(values = c("First Stand Photo boreE" = "turquoise1", "Second Stand Photo boreE" = "violet")) +
  scale_y_continuous(
    name = "Distribution (%)",
    sec.axis = sec_axis(
      trans = ~ . / 100 * total_count_boreE,
      name = "Count",
      labels = label_number() 
    )
  ) +
  scale_x_discrete(
    name = "Year",
    breaks = as.character(seq(1950, 2020, by = 10)),  # Labels every 10 years
    labels = seq(1950, 2020, by = 10)
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom", 
    legend.title = element_blank(), 
    legend.box = "horizontal", 
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"),
    plot.margin = margin(b = 10) 
  ) +
  labs(
    x = "Years",
    fill = "Photo Type"
  )

# Display the plot
print(pBoreE)