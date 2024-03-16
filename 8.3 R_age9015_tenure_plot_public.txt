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
###### Module 8.3 
###### Sample R command for generating forest age structure 1990 and 2015 stratified with tenure data set plots
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

# Filter out negative values, then bin 'age_1990' into decades using cut() for 2015
age_counts_2015 <- resultAB %>%
  filter(age_2015 >= 0 & (tenuretype == 'long_term_tenure' | tenuretype == 'short_term_tenure')) %>%
  mutate(age_bin_2015 = cut(age_2015, breaks = breaks_2015, labels = labels_2015, include.lowest = TRUE)) %>%
  group_by(age_bin_2015) %>%
  summarise(count_2015 = n(), .groups = 'drop')

# Calculate the proportion for each age group for 2015
age_counts_2015 <- age_counts_2015 %>%
  mutate(proportion_2015 = count_2015 / sum(count_2015))

visible_labels_2015 <- labels_2015[seq(1, length(labels_2015), by = 5)]

# Assuming age_counts for age_1990 and age_2015 are already calculated and contain 'proportion' column
max_proportion_1990 <- max(age_counts_1990$proportion_1990 * 100, na.rm = TRUE)
max_proportion_2015 <- max(age_counts_2015$proportion_2015 * 100, na.rm = TRUE)
max_proportion <- max(max_proportion_1990, max_proportion_2015)

# Adding a little extra space for the top of the y-axis
y_axis_limit <- max_proportion + 5 

# Create the plot for 1990
pAB90 <- ggplot(age_counts_1990, aes(x = age_bin_1990, y = proportion_1990 * 100)) +
  geom_bar(stat = "identity", fill = "grey45", color = "black") + 
  scale_y_continuous(
    name = "Proportion of sample (%)",
    limits = c(0, y_axis_limit),
    sec.axis = sec_axis(~ . * sum(age_counts_1990$count_1990) / 100, name = "Sample size")
  ) +
  scale_x_discrete(breaks = visible_labels_1990) + 
  theme_minimal() +
  theme(
    axis.text.x = element_text(hjust = 0.5, angle = 0, size = 10), 
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"),
    legend.position = "none"
  ) +
  labs(
    x = "Age in 1990 (in decades)",
    title = "Alberta in 1990"
  )

# Total counts for 2015 including both long and short term tenure
total_counts_2015 <- sum(age_counts_2015$count_2015)

pAB15ten <- ggplot(age_counts_2015, aes(x = age_bin_2015, y = proportion_2015 * 100)) +
  geom_bar(stat = "identity", fill = "chocolate3", color = "black") + 
  scale_y_continuous(
    name = "Proportion of sample (%)",
    limits = c(0, y_axis_limit),
    sec.axis = sec_axis(~ . * total_counts_2015 / 100, name = "Sample size", labels = scales::comma)
  ) +
  scale_x_discrete(breaks = visible_labels_2015) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(hjust = 0.5, angle = 0, size = 10), 
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"),
    legend.position = "none"
  ) +
  labs(
    x = "Age in 2015 (in decades)",
    title = "Tenure Area in 2020"
  )

# Print the adjusted plot
print(pAB15ten)


# Define breaks and labels for the age bins again for clarity for 2015
breaks_2015 <- seq(from = 0, to = max(resultAB$age_2015, na.rm = TRUE) + 10, by = 10)
labels_2015 <- sprintf("%d", breaks_2015[-length(breaks_2015)] + 5) 

# Filter out negative values, then bin 'age_1990' into decades using cut() for 2015
age_counts_2015 <- resultAB %>%
  filter(age_2015 >= 0 & (tenuretype == 'protected_area')) %>%
  mutate(age_bin_2015 = cut(age_2015, breaks = breaks_2015, labels = labels_2015, include.lowest = TRUE)) %>%
  group_by(age_bin_2015) %>%
  summarise(count_2015 = n(), .groups = 'drop')

# Calculate the proportion for each age group for 2015
age_counts_2015 <- age_counts_2015 %>%
  mutate(proportion_2015 = count_2015 / sum(count_2015))

visible_labels_2015 <- labels_2015[seq(1, length(labels_2015), by = 5)]

# Total counts for 2015 including both long and short term tenure
total_counts_2015_pro <- sum(age_counts_2015$count_2015)

# Adjusting the secondary axis to accurately reflect sample size
pAB15pro <- ggplot(age_counts_2015, aes(x = age_bin_2015, y = proportion_2015 * 100)) +
  geom_bar(stat = "identity", fill = "dodgerblue3", color = "black") +
  scale_y_continuous(
    name = "Proportion of sample (%)",
    limits = c(0, max(age_counts_2015$proportion_2015 * 100) + 5), 
    sec.axis = sec_axis(trans = ~ . * total_counts_2015_pro / 100, name = "Sample size", labels = scales::comma)
  ) +
  scale_x_discrete(breaks = visible_labels_2015) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(hjust = 0.5, angle = 0, size = 10),
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"),
    legend.position = "none"
  ) +
  labs(
    x = "Age in 2015 (in decades)",
    title = "Protected Area in 2020"
  )

# Print the plot
print(pAB15pro)

pAB90 + pAB15ten + pAB15pro + plot_layout(ncol = 3)

#############################################################################################
Manitoba (MB) below
#############################################################################################

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

# Filter out negative values, then bin 'age_1990' into decades using cut() for 2015
age_counts_2015 <- resultMB %>%
  filter(age_2015 >= 0 & (tenuretype == 'long_term_tenure' | tenuretype == 'short_term_tenure')) %>%
  mutate(age_bin_2015 = cut(age_2015, breaks = breaks_2015, labels = labels_2015, include.lowest = TRUE)) %>%
  group_by(age_bin_2015) %>%
  summarise(count_2015 = n(), .groups = 'drop')

# Calculate the proportion for each age group for 2015
age_counts_2015 <- age_counts_2015 %>%
  mutate(proportion_2015 = count_2015 / sum(count_2015))

visible_labels_2015 <- labels_2015[seq(1, length(labels_2015), by = 5)]


# Assuming age_counts for age_1990 and age_2015 are already calculated and contain 'proportion' column
max_proportion_1990 <- max(age_counts_1990$proportion_1990 * 100, na.rm = TRUE)
max_proportion_2015 <- max(age_counts_2015$proportion_2015 * 100, na.rm = TRUE)
max_proportion <- max(max_proportion_1990, max_proportion_2015)

# Adding a little extra space for the top of the y-axis
y_axis_limit <- max_proportion + 5


# Create the plot for 1990
pMB90 <- ggplot(age_counts_1990, aes(x = age_bin_1990, y = proportion_1990 * 100)) +
  geom_bar(stat = "identity", fill = "grey45", color = "black") + 
  scale_y_continuous(
    name = "Proportion of sample (%)",
    limits = c(0, y_axis_limit),
    sec.axis = sec_axis(~ . * sum(age_counts_1990$count_1990) / 100, name = "Sample size")
  ) +
  scale_x_discrete(breaks = visible_labels_1990) +  
  theme_minimal() +
  theme(
    axis.text.x = element_text(hjust = 0.5, angle = 0, size = 10), 
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"),
    legend.position = "none"
  ) +
  labs(
    x = "Age in 1990 (in decades)",
    title = "Manitoba in 1990"
  )

# Total counts for 2015 including both long and short term tenure
total_counts_2015 <- sum(age_counts_2015$count_2015)

pMB15ten <- ggplot(age_counts_2015, aes(x = age_bin_2015, y = proportion_2015 * 100)) +
  geom_bar(stat = "identity", fill = "chocolate3", color = "black") + 
  scale_y_continuous(
    name = "Proportion of sample (%)",
    limits = c(0, y_axis_limit),
    sec.axis = sec_axis(~ . * total_counts_2015 / 100, name = "Sample size", labels = scales::comma)
  ) +
  scale_x_discrete(breaks = visible_labels_2015) +  
  theme_minimal() +
  theme(
    axis.text.x = element_text(hjust = 0.5, angle = 0, size = 10), 
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"),
    legend.position = "none"
  ) +
  labs(
    x = "Age in 2015 (in decades)",
    title = "Tenure Area in 2020"
  )

# Print the adjusted plot
print(pMB15ten)


# Define breaks and labels for the age bins again for clarity for 2015
breaks_2015 <- seq(from = 0, to = max(resultMB$age_2015, na.rm = TRUE) + 10, by = 10)
labels_2015 <- sprintf("%d", breaks_2015[-length(breaks_2015)] + 5) 

# Filter out negative values, then bin 'age_1990' into decades using cut() for 2015
age_counts_2015 <- resultMB %>%
  filter(age_2015 >= 0 & (tenuretype == 'protected_area')) %>%
  mutate(age_bin_2015 = cut(age_2015, breaks = breaks_2015, labels = labels_2015, include.lowest = TRUE)) %>%
  group_by(age_bin_2015) %>%
  summarise(count_2015 = n(), .groups = 'drop')

# Calculate the proportion for each age group for 2015
age_counts_2015 <- age_counts_2015 %>%
  mutate(proportion_2015 = count_2015 / sum(count_2015))

visible_labels_2015 <- labels_2015[seq(1, length(labels_2015), by = 5)]

# Total counts for 2015 including both long and short term tenure
total_counts_2015_pro <- sum(age_counts_2015$count_2015)

# Adjusting the secondary axis to accurately reflect sample size
pMB15pro <- ggplot(age_counts_2015, aes(x = age_bin_2015, y = proportion_2015 * 100)) +
  geom_bar(stat = "identity", fill = "dodgerblue3", color = "black") +
  scale_y_continuous(
    name = "Proportion of sample (%)",
    limits = c(0, max(age_counts_2015$proportion_2015 * 100) + 5), 
    sec.axis = sec_axis(trans = ~ . * total_counts_2015_pro / 100, name = "Sample size", labels = scales::comma)
  ) +
  scale_x_discrete(breaks = visible_labels_2015) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(hjust = 0.5, angle = 0, size = 10),
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"),
    legend.position = "none"
  ) +
  labs(
    x = "Age in 2015 (in decades)",
    title = "Protected Area in 2020"
  )

# Print the plot
print(pMB15pro)

pMB90 + pMB15ten + pMB15pro + plot_layout(ncol = 3)

#############################################################################################
Saskatchewan (SK) below
#############################################################################################
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
labels_2015 <- sprintf("%d", breaks_2015[-length(breaks_2015)] + 5)  # Create labels that are the midpoints of the bins

# Filter out negative values, then bin 'age_1990' into decades using cut() for 2015
age_counts_2015 <- resultSK %>%
  filter(age_2015 >= 0 & (tenuretype == 'long_term_tenure' | tenuretype == 'short_term_tenure')) %>%
  mutate(age_bin_2015 = cut(age_2015, breaks = breaks_2015, labels = labels_2015, include.lowest = TRUE)) %>%
  group_by(age_bin_2015) %>%
  summarise(count_2015 = n(), .groups = 'drop')

# Calculate the proportion for each age group for 2015
age_counts_2015 <- age_counts_2015 %>%
  mutate(proportion_2015 = count_2015 / sum(count_2015))

visible_labels_2015 <- labels_2015[seq(1, length(labels_2015), by = 5)]


# Assuming age_counts for age_1990 and age_2015 are already calculated and contain 'proportion' column
max_proportion_1990 <- max(age_counts_1990$proportion_1990 * 100, na.rm = TRUE)
max_proportion_2015 <- max(age_counts_2015$proportion_2015 * 100, na.rm = TRUE)
max_proportion <- max(max_proportion_1990, max_proportion_2015)

# Adding a little extra space for the top of the y-axis
y_axis_limit <- max_proportion + 5 


# Create the plot for 1990
pSK90 <- ggplot(age_counts_1990, aes(x = age_bin_1990, y = proportion_1990 * 100)) +
  geom_bar(stat = "identity", fill = "grey45", color = "black") + 
  scale_y_continuous(
    name = "Proportion of sample (%)",
    limits = c(0, y_axis_limit),
    sec.axis = sec_axis(~ . * sum(age_counts_1990$count_1990) / 100, name = "Sample size")
  ) +
  scale_x_discrete(breaks = visible_labels_1990) + 
  theme_minimal() +
  theme(
    axis.text.x = element_text(hjust = 0.5, angle = 0, size = 10),
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"),
    legend.position = "none"
  ) +
  labs(
    x = "Age in 1990 (in decades)",
    title = "Saskatchewan in 1990")

# Total counts for 2015 including both long and short term tenure
total_counts_2015 <- sum(age_counts_2015$count_2015)

pSK15ten <- ggplot(age_counts_2015, aes(x = age_bin_2015, y = proportion_2015 * 100)) +
  geom_bar(stat = "identity", fill = "chocolate3", color = "black") + 
  scale_y_continuous(
    name = "Proportion of sample (%)",
    limits = c(0, y_axis_limit),
    sec.axis = sec_axis(~ . * total_counts_2015 / 100, name = "Sample size", labels = scales::comma)
  ) +
  scale_x_discrete(breaks = visible_labels_2015) + 
  theme_minimal() +
  theme(
    axis.text.x = element_text(hjust = 0.5, angle = 0, size = 10),
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"),
    legend.position = "none"
  ) +
  labs(
    x = "Age in 2015 (in decades)",
    title = "Tenure Area in 2020"
  )

# Print the adjusted plot
print(pSK15ten)


# Define breaks and labels for the age bins again for clarity for 2015
breaks_2015 <- seq(from = 0, to = max(resultSK$age_2015, na.rm = TRUE) + 10, by = 10)
labels_2015 <- sprintf("%d", breaks_2015[-length(breaks_2015)] + 5) 

# Filter out negative values, then bin 'age_1990' into decades using cut() for 2015
age_counts_2015 <- resultSK %>%
  filter(age_2015 >= 0 & (tenuretype == 'protected_area')) %>%
  mutate(age_bin_2015 = cut(age_2015, breaks = breaks_2015, labels = labels_2015, include.lowest = TRUE)) %>%
  group_by(age_bin_2015) %>%
  summarise(count_2015 = n(), .groups = 'drop')

# Calculate the proportion for each age group for 2015
age_counts_2015 <- age_counts_2015 %>%
  mutate(proportion_2015 = count_2015 / sum(count_2015))

visible_labels_2015 <- labels_2015[seq(1, length(labels_2015), by = 5)]

# Total counts for 2015 including both long and short term tenure
total_counts_2015_pro <- sum(age_counts_2015$count_2015)

# Adjusting the secondary axis to accurately reflect sample size
pSK15pro <- ggplot(age_counts_2015, aes(x = age_bin_2015, y = proportion_2015 * 100)) +
  geom_bar(stat = "identity", fill = "dodgerblue3", color = "black") +
  scale_y_continuous(
    name = "Proportion of sample (%)",
    limits = c(0, max(age_counts_2015$proportion_2015 * 100) + 5),
    sec.axis = sec_axis(trans = ~ . * total_counts_2015_pro / 100, name = "Sample size", labels = scales::comma)
  ) +
  scale_x_discrete(breaks = visible_labels_2015) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(hjust = 0.5, angle = 0, size = 10),
    axis.title.y = element_text(color = "black"),
    axis.title.y.right = element_text(color = "black"),
    legend.position = "none"
  ) +
  labs(
    x = "Age in 2015 (in decades)",
    title = "Protected Area in 2020"
  )

# Print the plot
print(pSK15pro)

pSK90 + pSK15ten + pSK15pro + plot_layout(ncol = 3)

#############################################################################################