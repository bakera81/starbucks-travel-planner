library(dplyr)
library(jsonlite)
library(ggmap)
library(yaml)

key <- read_yaml("secret/google_place_search_api.yml")$key
url <- paste0("https://maps.googleapis.com/maps/api/place/nearbysearch/json?",
              "location=40.7484,-73.9857&radius=20000", # 20,000 m radius from Empire State Building
              "&keyword=starbucks",
              "&key=", key)
req <-  fromJSON(url, flatten = T)
sbux <- req$results

while(!is.null(req$next_page_token)){
  url <- paste0("https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=",
                req$next_page_token,
                "&key=", key)
  req <-  fromJSON(url, flatten = T)
  if(req$status == "OK"){
    sbux <- bind_rows(sbux, req$results)
    print("Sleeping...")
    Sys.sleep(10) # You have to wait for the next_page_token to become available
  } else{
    print("Exiting...")
  }
}

# Get full data from 
# https://opendata.socrata.com/Business/All-Starbucks-Locations-in-the-World-Point-Map/7sg8-44ed?_ga=1.93541853.1197251441.1365557881

sbux <- read.csv("data/All_Starbucks_Locations_in_the_World.csv", stringsAsFactors = F)

qmplot(geometry.location.lng, geometry.location.lat, data = sbux, maptype = "toner-lite", color = I("red")) + 
  stat_density_2d(aes(fill = ..level..), geom = "polygon", alpha = .3, color = NA) #+
  # scale_fill_gradient2("Starbux\nDensity", low = "white", mid = "yellow", high = "red", midpoint = 650)
