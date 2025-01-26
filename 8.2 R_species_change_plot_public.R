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
###### Module 8.2 
###### Sample R command for generating species change plots
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
resultAB <- resultAB %>%
  arrange(desc(percentage)) %>%
  mutate(cumulative_pct = cumsum(percentage))  

# Create the plot with bars arranged from highest (left) to lowest (right) and using cumulative percentage
pAB <- ggplot(resultAB, aes(x = reorder(species_change, -percentage), y = cumulative_pct)) +  # Use reorder to arrange bars in descending order and plot cumulative_pct
  geom_bar(stat = "identity", fill = "palegreen4", color = "black", size = 0.1) +
  geom_text(aes(label = paste0(round(percentage, 2), "%"), y = cumulative_pct + 1), size = 3, hjust = 0.5, vjust = 0) +  # Display percentage value on top of the bar
  scale_y_continuous(
    name = "Cumulative Percentage (%)",
    limits = c(0, max(resultAB$cumulative_pct) + 5)  
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  
    axis.title.x = element_text(color = "black"),
    axis.title.y = element_text(color = "black")
  ) +
  labs(
    x = NULL,  
    title = "in Alberta (AB)"  
  )
# Print the modified plot
print(pAB)

#############################################################################################
Saskatchewan (SK) below
#############################################################################################
resultSK <- resultSK %>%
  arrange(desc(percentage)) %>%
  mutate(cumulative_pct = cumsum(percentage))  

# Create the plot with bars arranged from highest (left) to lowest (right) and using cumulative percentage
pSK <- ggplot(resultSK, aes(x = reorder(species_change, -percentage), y = cumulative_pct)) +  # Use reorder to arrange bars in descending order and plot cumulative_pct
  geom_bar(stat = "identity", fill = "palegreen4", color = "black", size = 0.1) +
  geom_text(aes(label = paste0(round(percentage, 2), "%"), y = cumulative_pct + 1), size = 3, hjust = 0.5, vjust = 0) +  # Display percentage value on top of the bar
  scale_y_continuous(
    name = "Cumulative Percentage (%)",
    limits = c(0, max(resultAB$cumulative_pct) + 5)  
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  
    axis.title.x = element_text(color = "black"),
    axis.title.y = element_text(color = "black")
  ) +
  labs(
    x = NULL,  
    title = "in Saskatchewan (SK)"  
  )
# Print the modified plot
print(pSK)
#############################################################################################
Manitoba (MB) below
#############################################################################################
resultMB <- resultMB %>%
  arrange(desc(percentage)) %>%
  mutate(cumulative_pct = cumsum(percentage)) 

# Create the plot with bars arranged from highest (left) to lowest (right) and using cumulative percentage
pMB <- ggplot(resultMB, aes(x = reorder(species_change, -percentage), y = cumulative_pct)) +  # Use reorder to arrange bars in descending order and plot cumulative_pct
  geom_bar(stat = "identity", fill = "palegreen4", color = "black", size = 0.1) +
  geom_text(aes(label = paste0(round(percentage, 2), "%"), y = cumulative_pct + 1), size = 3, hjust = 0.5, vjust = 0) +  # Display percentage value on top of the bar
  scale_y_continuous(
    name = "Cumulative Percentage (%)",
    limits = c(0, max(resultAB$cumulative_pct) + 5)  
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  
    axis.title.x = element_text(color = "black"),
    axis.title.y = element_text(color = "black")
  ) +
  labs(
    x = NULL,  
    title = "in Manitoba (MB)"  
  )
# Print the modified plot
print(pMB)


#############################################################################################
Hemiboreal (BC) below
#############################################################################################
resultBC_hemi <- resultBC_hemi %>%
  arrange(desc(percentage)) %>%
  mutate(cumulative_pct = cumsum(percentage))  

# Create the plot with bars arranged from highest (left) to lowest (right) and using cumulative percentage
pBC_hemi <- ggplot(resultBC_hemi, aes(x = reorder(species_change, -percentage), y = cumulative_pct)) +  
  geom_bar(stat = "identity", fill = "palegreen4", color = "black", size = 0.1) +
  geom_text(aes(label = paste0(round(percentage, 2), "%"), y = cumulative_pct + 1), size = 3, hjust = 0.5, vjust = 0) +  
  scale_y_continuous(
    name = "Cumulative Percentage (%)",
    limits = c(0, max(resultBC_hemi$cumulative_pct) + 5)  
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12), 
    axis.title.x = element_text(color = "black"),
    axis.title.y = element_text(color = "black")
  ) +
  labs(
    x = NULL, 
    title = "Hemiboreal region in British Columbia (BC_hemi)" 
  )
# Print the modified plot
print(pBC_hemi)

#############################################################################################
Boreal East (BC) below
#############################################################################################
resultBC_boreE <- resultBC_boreE %>%
  arrange(desc(percentage)) %>%
  mutate(cumulative_pct = cumsum(percentage))  

# Create the plot with bars arranged from highest (left) to lowest (right) and using cumulative percentage
pBC_boreE <- ggplot(resultBC_boreE, aes(x = reorder(species_change, -percentage), y = cumulative_pct)) +  
  geom_bar(stat = "identity", fill = "palegreen4", color = "black", size = 0.1) +
  geom_text(aes(label = paste0(round(percentage, 2), "%"), y = cumulative_pct + 1), size = 3, hjust = 0.5, vjust = 0) +  
  scale_y_continuous(
    name = "Cumulative Percentage (%)",
    limits = c(0, max(resultBC_boreE$cumulative_pct) + 5)  
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  
    axis.title.x = element_text(color = "black"),
    axis.title.y = element_text(color = "black")
  ) +
  labs(
    x = NULL,  
    title = "Boreal region, East in British Columbia (BC_boreE)"  
  )
# Print the modified plot
print(pBC_boreE)
#############################################################################################
Boreal West (BC) below
#############################################################################################
resultBC_boreW <- resultBC_boreW %>%
  arrange(desc(percentage)) %>%
  mutate(cumulative_pct = cumsum(percentage)) 

# Create the plot with bars arranged from highest (left) to lowest (right) and using cumulative percentage
pBC_boreW <- ggplot(resultBC_boreW, aes(x = reorder(species_change, -percentage), y = cumulative_pct)) + 
  geom_bar(stat = "identity", fill = "palegreen4", color = "black", size = 0.1) +
  geom_text(aes(label = paste0(round(percentage, 2), "%"), y = cumulative_pct + 1), size = 3, hjust = 0.5, vjust = 0) +  
  scale_y_continuous(
    name = "Cumulative Percentage (%)",
    limits = c(0, max(resultBC_boreW$cumulative_pct) + 5)  
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  
    axis.title.x = element_text(color = "black"),
    axis.title.y = element_text(color = "black")
  ) +
  labs(
    x = NULL,  
    title = "Boreal region, West in British Columbia (BC_boreW)"  
  )
# Print the modified plot
print(pBC_boreW)
#############################################################################################
All plots below
#############################################################################################
pAB + pSK + pMB + pBC_hemi + pBC_boreE + pBC_boreW
#############################################################################################