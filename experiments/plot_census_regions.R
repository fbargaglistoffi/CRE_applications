rm(list=ls())
library(ggplot2)
library(ggmap)
library(datasets)
library(dplyr)
library(usmapdata)
library(RColorBrewer)

centroid_labels <- usmapdata::centroid_labels("states")
centroid_labels$full <- tolower(centroid_labels$full)
state_data <- map_data("state")

state_centers <- as.data.frame(matrix(c(
  "Alabama", 32.806671, -86.791130,
  "Alaska", 63.5887, -154.4931,
  "Arizona", 34, -111.5,
  "Arkansas", 34.969704, -92.373123,
  "California", 36.2, -119.5,
  "Colorado", 39.059811, -105.311104,
  "Connecticut", 41.597782, -72.755371,
  "Delaware", 38.8, -75.507141,
  "District of Columbia", 38.75, -77.0365, # 38.8977,
  "Florida", 27.766279, -81.5,
  "Georgia", 33.040619, -83.643074,
  "Hawaii", 19.8968, -155.5828,
  "Idaho", 44, -114.6,
  "Illinois", 40.349457, -88.986137,
  "Indiana", 39.849426, -86.258278,
  "Iowa", 42.011539, -93.210526,
  "Kansas", 38.526600, -98,
  "Kentucky", 37.668140, -84.670067,
  "Louisiana", 31.169546, -92.4,
  "Maine", 45, -69.381927,
  "Maryland",  39.2, -76.802101,
  "Massachusetts", 42.28, -71.530106,
  "Michigan", 43.326618, -84.536095,
  "Minnesota", 45.694454, -93.900192,
  "Mississippi", 32.741646, -89.678696,
  "Missouri", 38.456085, -92.288368,
  "Montana", 46.921925, -110.454353,
  "Nebraska", 41.125370, -99.2,
  "Nevada", 39, -116.5,
  "New Hampshire", 43.452492, -71.563896,
  "New Jersey", 40.298904, -74.521011,
  "New Mexico", 34.840515, -106.248482,
  "New York", 43, -74.948051,
  "North Carolina", 35.630066, -79.806419,
  "North Dakota", 47.528912, -100.3,
  "Ohio", 40.388783, -82.764915,
  "Oklahoma", 35.565342, -96.928917,
  "Oregon", 44, -121,
  "Pennsylvania", 41, -77.209755,
  "Rhode Island", 41.680893, -71.511780,
  "South Carolina", 33.856892, -80.945007,
  "South Dakota", 44.299782, -100,
  "Tennessee", 35.747845, -86.692345,
  "Texas", 31.054487, -99,
  "Utah", 39.1, -111.862434,
  "Vermont", 44.045876, -72.710686,
  "Virginia", 37.769337, -78.169968,
  "Washington", 47.4165, -119.5,
  "West Virginia", 38.4912, -80.9545,
  "Wisconsin", 44.6243, -89.9941,
  "Wyoming", 42.9957, -107.5512), ncol = 3, byrow = TRUE))


centroid_labels$y <- as.double(state_centers$V2)
centroid_labels$x <- as.double(state_centers$V3)



state_data <- left_join(state_data, centroid_labels, by = c("region" = "full"))

state <- data.frame(state.name = tolower(c("Alabama", "Arizona", "Arkansas", "California", "Colorado",
                                           "Connecticut", "Delaware", "Florida", "Georgia", "Idaho",
                                           "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana",
                                           "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
                                           "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
                                           "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina",
                                           "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
                                           "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas",
                                           "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin",
                                           "Wyoming")),
                    census_region = c("South", "West", "South", "West", "West",
                                      "Northeast", "South", "South", "South", "West",
                                      "Midwest", "Midwest", "Midwest", "Midwest", "South", "South",
                                      "Northeast", "South", "Northeast", "Midwest", "Midwest",
                                      "South", "Midwest", "West", "Midwest", "West",
                                      "Northeast", "Northeast", "West", "Northeast", "South",
                                      "Midwest", "Midwest", "South", "West", "Northeast",
                                      "Northeast", "South", "Midwest", "South", "South",
                                      "West", "Northeast", "South", "West", "South", "Midwest", "West"),
                    stringsAsFactors = F)



# Join the state_data with the region_data by state name
merged_data <- left_join(state_data, state, by = c("region" = "state.name"))

# Create a new column in the merged data for the region color
merged_data$region_color <- factor(
  merged_data$census_region,
  levels = c("Northeast", "South", "Midwest", "West")
)

gg1 <- ggplot(merged_data[!is.na(merged_data$region_color),], aes(long, lat, map_id = region)) +
  geom_map(aes(fill = region_color), map = merged_data[!is.na(merged_data$region_color),], color = "white", size = 0.2) +
  scale_fill_brewer(palette = "RdYlBu",
                    guide = guide_legend(title = "", position = "bottom")) +
  labs(title = NULL) +
  theme_void() +
  theme(legend.position = "bottom",
        legend.box.background = element_blank(),
        legend.margin = margin(t = 0, r = 0, b = 10, l = 0),
        legend.text = element_text(size = 10),
        legend.title = element_text(size = 10, face = "bold")) +
  geom_text(data = merged_data, aes(x = x, y = y, label = abbr), size = 2, color = "black")

pdf("census_regions.pdf", width = 8, height = 5)
print(gg1)
dev.off()
