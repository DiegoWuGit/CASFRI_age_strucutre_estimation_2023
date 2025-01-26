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
###### Module 8.4 
###### Sample R command for generating forest age structure 1990 and 2015 under nologging scenrio plots
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
# create the age bar chart of age_1990, age_2015 for Alberta

breaks_1990 <- seq(from = 0, to = max(resultAB$age_1990, na.rm = TRUE) + 10, by = 10)
labels_1990 <- sprintf("%d", breaks_1990[-length(breaks_1990)] + 5)  

# Filter out negative values, then bin 'age_1990' into decades using cut() for 1990
age_counts_1990 <- resultAB %>%
  filter(age_1990 >= 0) %>%
  mutate(age_bin_1990 = cut(age_1990, breaks = breaks_1990, labels = labels_1990, include.lowest = TRUE)) %>%
  group_by(age_bin_1990) %>%
  summarise(count_1990 = n(), .groups = 'drop')

# Calculate the proportion for each age group for 1990
age_counts_1990 <- age_counts_1990 %>%
  mutate(proportion_1990 = count_1990 / sum(count_1990))

visible_labels_1990 <- labels_1990[seq(1, length(labels_1990), by = 5)]

# Define breaks and labels for the age bins again for clarity for 2015
breaks_2015 <- seq(from = 0, to = max(resultAB$age_2015, na.rm = TRUE) + 10, by = 10)
labels_2015 <- sprintf("%d", breaks_2015[-length(breaks_2015)] + 5) 

# Filter out negative values, then bin 'age_2015' into decades using cut() for 2015
age_counts_2015 <- resultAB %>%
  filter(age_2015 >= 0) %>%
  mutate(age_bin_2015 = cut(age_2015, breaks = breaks_2015, labels = labels_2015, include.lowest = TRUE)) %>%
  group_by(age_bin_2015) %>%
  summarise(count_2015 = n(), .groups = 'drop')

# Calculate the proportion for each age group for 2015
age_counts_2015 <- age_counts_2015 %>%
  mutate(proportion_2015 = count_2015 / sum(count_2015))

visible_labels_2015 <- labels_2015[seq(1, length(labels_2015), by = 5)]


# Define breaks and labels for the age bins again for clarity for 2015_nologging
breaks_2015_nologging <- seq(from = 0, to = max(resultAB$age_2015_nologging, na.rm = TRUE) + 10, by = 10)
labels_2015_nologging <- sprintf("%d", breaks_2015[-length(breaks_2015_nologging)] + 5)  # Create labels that are the midpoints of the bins

# Filter out negative values, then bin 'age_2015_nologging' into decades using cut() for 2015_nologging
age_counts_2015_nologging <- resultAB %>%
  filter(age_2015_nologging >= 0) %>%
  mutate(age_bin_2015 = cut(age_2015_nologging, breaks = breaks_2015_nologging, labels = labels_2015_nologging, include.lowest = TRUE)) %>%
  group_by(age_bin_2015) %>%
  summarise(count_2015_nologging = n(), .groups = 'drop')

# Calculate the proportion for each age group for 2015
age_counts_2015_nologging <- age_counts_2015_nologging %>%
  mutate(proportion_2015_nologging = count_2015_nologging / sum(count_2015_nologging))

visible_labels_2015_nologging <- labels_2015_nologging[seq(1, length(labels_2015_nologging), by = 5)]


# Keeping both original and adjusted counts
adjusted_counts_AB <- left_join(age_counts_2015, age_counts_2015_nologging, by = "age_bin_2015", suffix = c("_2015", "_2015_nolog")) %>%
  mutate(adjusted_count_2015_nologging = ifelse(count_2015_nologging - count_2015 < 0, 0, count_2015_nologging - count_2015),
         distribution_pct_2015 = count_2015 / sum(count_2015) * 100,  # Recalculate to ensure accuracy
         distribution_pct_2015_nologging = adjusted_count_2015_nologging / sum(adjusted_count_2015_nologging) * 100) %>%
  # Spread data for stacking
  select(age_bin_2015, count_2015, distribution_pct_2015, adjusted_count_2015_nologging, distribution_pct_2015_nologging) %>%
  pivot_longer(cols = c(count_2015, adjusted_count_2015_nologging), names_to = "category", values_to = "count") %>%
  mutate(category = recode(category, count_2015 = "age_2015", adjusted_count_2015_nologging = "adjusted_age_2015_nologging"),
         distribution_pct = if_else(category == "age_2015", distribution_pct_2015, distribution_pct_2015_nologging))


# Calculate the proportion for each age group for adjusted_counts_AB
adjusted_counts_AB <- adjusted_counts_AB %>%
  mutate(proportion_adjusted = count / sum(count))


# Assuming age_counts for age_1990 and age_2015 are already calculated and contain 'proportion' column
max_proportion_1990 <- max(age_counts_1990$proportion_1990 * 100, na.rm = TRUE)
max_proportion_2015 <- max(age_counts_2015$proportion_2015 * 100, na.rm = TRUE)
max_proportion <- max(max_proportion_1990, max_proportion_2015)

# Adding a little extra space for the top of the y-axis
y_axis_limit <- max_proportion + 5  

pAB_15 <- ggplot(adjusted_counts_AB, aes(x = age_bin_2015, y = proportion_adjusted* 100, fill = category)) +
  geom_bar(stat = "identity", position = "stack", color = "black", size = 0.25) +
    scale_y_continuous(
    name = "Proportion of sample (%)",
    limits = c(0, y_axis_limit),
    sec.axis = sec_axis(~ . * sum(adjusted_counts_AB$count) / 100, name = "Sample size")
    ) +
    scale_x_discrete(breaks = visible_labels_2015)+
    scale_fill_manual(values = c("age_2015" = "orange2", "adjusted_age_2015_nologging" = "grey55")) +
    theme_minimal() +
    theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.title.x = element_text(color = "black"),
    axis.title.y = element_text(color = "black"),
    panel.spacing = unit(0, "lines") 
  ) +
  labs(x = "Age Medium", y = "Count", fill = "Category") +
  guides(fill = "none")

# Now you can create your plot
pAB_90 <- ggplot(age_counts_1990, aes(x = age_bin_1990, y = proportion_1990* 100)) +
  geom_bar(stat = "identity", color = "black", size = 0.25) +
  scale_y_continuous(
  name = "Proportion of sample (%)",
  limits = c(0, y_axis_limit),
  sec.axis = sec_axis(~ . * sum(age_counts_1990$count_1990) / 100, name = "Sample size")
  ) +
  scale_x_discrete(breaks = visible_labels_1990) +
  scale_fill_manual(values = c("age_1990 AB" = "grey55")) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.title.x = element_text(color = "black"),
    axis.title.y = element_text(color = "black"),
    panel.spacing = unit(0, "lines")
  ) +
  labs(x = "Age Medium", y = "Count", fill = "Category") +
  guides(fill = "none")

pAB_90 + pAB_15

#############################################################################################
Saskatchewan (SK) below
#############################################################################################
# For resultSK DataFrame
# Count occurrences of each year for the first photo year, and add distribution percentage for SK
# create the age bar chart of age_1990, age_2015 for Saskatchewan

breaks_1990 <- seq(from = 0, to = max(resultSK$age_1990, na.rm = TRUE) + 10, by = 10)
labels_1990 <- sprintf("%d", breaks_1990[-length(breaks_1990)] + 5)  

# Filter out negative values, then bin 'age_1990' into decades using cut() for 1990
age_counts_1990 <- resultSK %>%
  filter(age_1990 >= 0) %>%
  mutate(age_bin_1990 = cut(age_1990, breaks = breaks_1990, labels = labels_1990, include.lowest = TRUE)) %>%
  group_by(age_bin_1990) %>%
  summarise(count_1990 = n(), .groups = 'drop')

# Calculate the proportion for each age group for 1990
age_counts_1990 <- age_counts_1990 %>%
  mutate(proportion_1990 = count_1990 / sum(count_1990))

visible_labels_1990 <- labels_1990[seq(1, length(labels_1990), by = 5)]

# Define breaks and labels for the age bins again for clarity for 2015
breaks_2015 <- seq(from = 0, to = max(resultSK$age_2015, na.rm = TRUE) + 10, by = 10)
labels_2015 <- sprintf("%d", breaks_2015[-length(breaks_2015)] + 5) 

# Filter out negative values, then bin 'age_2015' into decades using cut() for 2015
age_counts_2015 <- resultSK %>%
  filter(age_2015 >= 0) %>%
  mutate(age_bin_2015 = cut(age_2015, breaks = breaks_2015, labels = labels_2015, include.lowest = TRUE)) %>%
  group_by(age_bin_2015) %>%
  summarise(count_2015 = n(), .groups = 'drop')

# Calculate the proportion for each age group for 2015
age_counts_2015 <- age_counts_2015 %>%
  mutate(proportion_2015 = count_2015 / sum(count_2015))

visible_labels_2015 <- labels_2015[seq(1, length(labels_2015), by = 5)]


# Define breaks and labels for the age bins again for clarity for 2015_nologging
breaks_2015_nologging <- seq(from = 0, to = max(resultSK$age_2015_nologging, na.rm = TRUE) + 10, by = 10)
labels_2015_nologging <- sprintf("%d", breaks_2015[-length(breaks_2015_nologging)] + 5)  

# Filter out negative values, then bin 'age_2015_nologging' into decades using cut() for 2015_nologging
age_counts_2015_nologging <- resultSK %>%
  filter(age_2015_nologging >= 0) %>%
  mutate(age_bin_2015 = cut(age_2015_nologging, breaks = breaks_2015_nologging, labels = labels_2015_nologging, include.lowest = TRUE)) %>%
  group_by(age_bin_2015) %>%
  summarise(count_2015_nologging = n(), .groups = 'drop')

# Calculate the proportion for each age group for 2015
age_counts_2015_nologging <- age_counts_2015_nologging %>%
  mutate(proportion_2015_nologging = count_2015_nologging / sum(count_2015_nologging))

visible_labels_2015_nologging <- labels_2015_nologging[seq(1, length(labels_2015_nologging), by = 5)]


# Keeping both original and adjusted counts
adjusted_counts_SK <- left_join(age_counts_2015, age_counts_2015_nologging, by = "age_bin_2015", suffix = c("_2015", "_2015_nolog")) %>%
  mutate(adjusted_count_2015_nologging = ifelse(count_2015_nologging - count_2015 < 0, 0, count_2015_nologging - count_2015),
         distribution_pct_2015 = count_2015 / sum(count_2015) * 100,  # Recalculate to ensure accuracy
         distribution_pct_2015_nologging = adjusted_count_2015_nologging / sum(adjusted_count_2015_nologging) * 100) %>%
  # Spread data for stacking
  select(age_bin_2015, count_2015, distribution_pct_2015, adjusted_count_2015_nologging, distribution_pct_2015_nologging) %>%
  pivot_longer(cols = c(count_2015, adjusted_count_2015_nologging), names_to = "category", values_to = "count") %>%
  mutate(category = recode(category, count_2015 = "age_2015", adjusted_count_2015_nologging = "adjusted_age_2015_nologging"),
         distribution_pct = if_else(category == "age_2015", distribution_pct_2015, distribution_pct_2015_nologging))


# Calculate the proportion for each age group for adjusted_counts_SK
adjusted_counts_SK <- adjusted_counts_SK %>%
  mutate(proportion_adjusted = count / sum(count))


# Assuming age_counts for age_1990 and age_2015 are already calculated and contain 'proportion' column
max_proportion_1990 <- max(age_counts_1990$proportion_1990 * 100, na.rm = TRUE)
max_proportion_2015 <- max(age_counts_2015$proportion_2015 * 100, na.rm = TRUE)
max_proportion <- max(max_proportion_1990, max_proportion_2015)

# Adding a little extra space for the top of the y-axis
y_axis_limit <- max_proportion + 5  # Adjust the '5' as needed for spacing

pSK_15 <- ggplot(adjusted_counts_SK, aes(x = age_bin_2015, y = proportion_adjusted* 100, fill = category)) +
  geom_bar(stat = "identity", position = "stack", color = "black", size = 0.25) +
  scale_y_continuous(
    name = "Proportion of sample (%)",
    limits = c(0, y_axis_limit),
    sec.axis = sec_axis(~ . * sum(adjusted_counts_SK$count) / 100, name = "Sample size")
  ) +
  scale_x_discrete(breaks = visible_labels_2015)+
scale_fill_manual(values = c("age_2015" = "orange2", "adjusted_age_2015_nologging" = "grey55")) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.title.x = element_text(color = "black"),
    axis.title.y = element_text(color = "black"),
    panel.spacing = unit(0, "lines") 
  ) +
  labs(x = "Age Medium", y = "Count", fill = "Category") +
  guides(fill = "none")

# Now you can create your plot
pSK_90 <- ggplot(age_counts_1990, aes(x = age_bin_1990, y = proportion_1990* 100)) +
  geom_bar(stat = "identity", color = "black", size = 0.25) +
  scale_y_continuous(
    name = "Proportion of sample (%)",
    limits = c(0, y_axis_limit),
    sec.axis = sec_axis(~ . * sum(age_counts_1990$count_1990) / 100, name = "Sample size")
  ) +
  scale_x_discrete(breaks = visible_labels_1990) +
scale_fill_manual(values = c("age_1990 SK" = "grey55")) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.title.x = element_text(color = "black"),
    axis.title.y = element_text(color = "black"),
    panel.spacing = unit(0, "lines")
  ) +
  labs(x = "Age Medium", y = "Count", fill = "Category") +
  guides(fill = "none")

pSK_90 + pSK_15

#############################################################################################
Manitoba (MB) below
#############################################################################################
# For resultMB DataFrame
# Count occurrences of each year for the first photo year, and add distribution percentage for MB
# create the age bar chart of age_1990, age_2015 for Manitoba

breaks_1990 <- seq(from = 0, to = max(resultMB$age_1990, na.rm = TRUE) + 10, by = 10)
labels_1990 <- sprintf("%d", breaks_1990[-length(breaks_1990)] + 5) 

# Filter out negative values, then bin 'age_1990' into decades using cut() for 1990
age_counts_1990 <- resultMB %>%
  filter(age_1990 >= 0) %>%
  mutate(age_bin_1990 = cut(age_1990, breaks = breaks_1990, labels = labels_1990, include.lowest = TRUE)) %>%
  group_by(age_bin_1990) %>%
  summarise(count_1990 = n(), .groups = 'drop')

# Calculate the proportion for each age group for 1990
age_counts_1990 <- age_counts_1990 %>%
  mutate(proportion_1990 = count_1990 / sum(count_1990))

visible_labels_1990 <- labels_1990[seq(1, length(labels_1990), by = 5)]

# Define breaks and labels for the age bins again for clarity for 2015
breaks_2015 <- seq(from = 0, to = max(resultMB$age_2015, na.rm = TRUE) + 10, by = 10)
labels_2015 <- sprintf("%d", breaks_2015[-length(breaks_2015)] + 5) 

# Filter out negative values, then bin 'age_2015' into decades using cut() for 2015
age_counts_2015 <- resultMB %>%
  filter(age_2015 >= 0) %>%
  mutate(age_bin_2015 = cut(age_2015, breaks = breaks_2015, labels = labels_2015, include.lowest = TRUE)) %>%
  group_by(age_bin_2015) %>%
  summarise(count_2015 = n(), .groups = 'drop')

# Calculate the proportion for each age group for 2015
age_counts_2015 <- age_counts_2015 %>%
  mutate(proportion_2015 = count_2015 / sum(count_2015))

visible_labels_2015 <- labels_2015[seq(1, length(labels_2015), by = 5)]


# Define breaks and labels for the age bins again for clarity for 2015_nologging
breaks_2015_nologging <- seq(from = 0, to = max(resultMB$age_2015_nologging, na.rm = TRUE) + 10, by = 10)
labels_2015_nologging <- sprintf("%d", breaks_2015[-length(breaks_2015_nologging)] + 5)  # Create labels that are the midpoints of the bins

# Filter out negative values, then bin 'age_2015_nologging' into decades using cut() for 2015_nologging
age_counts_2015_nologging <- resultMB %>%
  filter(age_2015_nologging >= 0) %>%
  mutate(age_bin_2015 = cut(age_2015_nologging, breaks = breaks_2015_nologging, labels = labels_2015_nologging, include.lowest = TRUE)) %>%
  group_by(age_bin_2015) %>%
  summarise(count_2015_nologging = n(), .groups = 'drop')

# Calculate the proportion for each age group for 2015
age_counts_2015_nologging <- age_counts_2015_nologging %>%
  mutate(proportion_2015_nologging = count_2015_nologging / sum(count_2015_nologging))

visible_labels_2015_nologging <- labels_2015_nologging[seq(1, length(labels_2015_nologging), by = 5)]


# Keeping both original and adjusted counts
adjusted_counts_MB <- left_join(age_counts_2015, age_counts_2015_nologging, by = "age_bin_2015", suffix = c("_2015", "_2015_nolog")) %>%
  mutate(adjusted_count_2015_nologging = ifelse(count_2015_nologging - count_2015 < 0, 0, count_2015_nologging - count_2015),
         distribution_pct_2015 = count_2015 / sum(count_2015) * 100,  # Recalculate to ensure accuracy
         distribution_pct_2015_nologging = adjusted_count_2015_nologging / sum(adjusted_count_2015_nologging) * 100) %>%
  # Spread data for stacking
  select(age_bin_2015, count_2015, distribution_pct_2015, adjusted_count_2015_nologging, distribution_pct_2015_nologging) %>%
  pivot_longer(cols = c(count_2015, adjusted_count_2015_nologging), names_to = "category", values_to = "count") %>%
  mutate(category = recode(category, count_2015 = "age_2015", adjusted_count_2015_nologging = "adjusted_age_2015_nologging"),
         distribution_pct = if_else(category == "age_2015", distribution_pct_2015, distribution_pct_2015_nologging))


# Calculate the proportion for each age group for adjusted_counts_SK
adjusted_counts_MB <- adjusted_counts_MB %>%
  mutate(proportion_adjusted = count / sum(count))


# Assuming age_counts for age_1990 and age_2015 are already calculated and contain 'proportion' column
max_proportion_1990 <- max(age_counts_1990$proportion_1990 * 100, na.rm = TRUE)
max_proportion_2015 <- max(age_counts_2015$proportion_2015 * 100, na.rm = TRUE)
max_proportion <- max(max_proportion_1990, max_proportion_2015)

# Adding a little extra space for the top of the y-axis
y_axis_limit <- max_proportion + 5

pMB_15 <- ggplot(adjusted_counts_MB, aes(x = age_bin_2015, y = proportion_adjusted* 100, fill = category)) +
  geom_bar(stat = "identity", position = "stack", color = "black", size = 0.25) +
  scale_y_continuous(
    name = "Proportion of sample (%)",
    limits = c(0, y_axis_limit),
    sec.axis = sec_axis(~ . * sum(adjusted_counts_MB$count) / 100, name = "Sample size")
  ) +
  scale_x_discrete(breaks = visible_labels_2015)+
  scale_fill_manual(values = c("age_2015" = "orange2", "adjusted_age_2015_nologging" = "grey55")) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.title.x = element_text(color = "black"),
    axis.title.y = element_text(color = "black"),
    panel.spacing = unit(0, "lines") 
  ) +
  labs(x = "Age Medium", y = "Count", fill = "Category") +
  guides(fill = "none")

# Now you can create your plot
pMB_90 <- ggplot(age_counts_1990, aes(x = age_bin_1990, y = proportion_1990* 100)) +
  geom_bar(stat = "identity", color = "black", size = 0.25) +
  scale_y_continuous(
    name = "Proportion of sample (%)",
    limits = c(0, y_axis_limit),
    sec.axis = sec_axis(~ . * sum(age_counts_1990$count_1990) / 100, name = "Sample size")
  ) +
  scale_x_discrete(breaks = visible_labels_1990) +
  scale_fill_manual(values = c("age_1990 MB" = "grey55")) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.title.x = element_text(color = "black"),
    axis.title.y = element_text(color = "black"),
    panel.spacing = unit(0, "lines")
  ) +
  labs(x = "Age Medium", y = "Count", fill = "Category") +
  guides(fill = "none")

pMB_90 + pMB_15