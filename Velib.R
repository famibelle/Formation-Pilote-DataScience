library("dplyr")
library(httr)
library(googleVis)
library(ggplot2)
# Recupere les données contractuelles depuis l'API JCDecaux https://developer.jcdecaux.com/#/opendata/vls?page=dynamic
ContractsGET <- httr::GET(
    sprintf(
        "https://api.jcdecaux.com/vls/v1/contracts?apiKey=%s",
        DecauxKey)
    )

# Parse les données récupérées par l'API et force les données en UTF8 
Contracts <- jsonlite::fromJSON(
    txt = httr::content(ContractsGET, "text", encoding  = "utf8"), 
    flatten = TRUE)



# Filtre les données par dénomination commerciale
filter(Contracts, commercial_name == "Velib")

DecauxContractName <- filter(Contracts, commercial_name == "Velib")[["name"]]

# On récupère toutes les stations Vélib sous contract avec Paris.
Stations <- jsonlite::fromJSON(sprintf("https://api.jcdecaux.com/vls/v1/stations?contract=%s&apiKey=%s", 
                                       DecauxContractName,
                                       DecauxKey), 
                               flatten = TRUE)

# On affiche les stations dans un tableau
StationsTable <- gvisTable(Stations)
plot(StationsTable)

options <- list({
    icons: {
        default: {
            normal:   '/path/to/marker/image',
            selected: '/path/to/marker/image'
        }
    })

# 
StationsMap <- Stations
StationsMap$locationvar <- paste(StationsMap$position.lat,StationsMap$position.lng, sep=":")

StationsMap$name <- 
    paste(
    StationsMap$name, "<p>",
    "attaches disponible(s)", StationsMap$bike_stands, "<p>",
    "Vélo(s) disponible(s)", StationsMap$available_bike_stands, sep=" "
    )

StationsMap <- gvisMap(StationsMap, "locationvar" , "name", 
                     options=list(showTip=TRUE, 
                                  showLine=TRUE, 
                                  enableScrollWheel=TRUE,
                                  mapType='terrain', 
                                  useMapTypeControl=TRUE))
plot(StationsMap)

