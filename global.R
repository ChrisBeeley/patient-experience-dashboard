
############################################
# this is the old version of the dashboard #
############################################

library(shinydashboard)
library(scales)
library(knitr)
library(tidyverse)
library(rmarkdown)
library(DT)
library(lubridate)
library(magrittr)
library(tidytext)
library(igraph)
library(ggraph)
library(stringi)
library(stringr)
library(shinyWidgets)
library(urltools)
library(pins)
library(plumber)

board_register_rsconnect("SPACED",
                         server = "https://involve.nottshc.nhs.uk:8443",
                         key = Sys.getenv("CONNECT_API_KEY"))

trustData <- pin_get("trustData", board = "SPACED") %>% 
  mutate(across(all_of(c("Imp1", "Imp2", "Best1", "Best2")), as.character))

questionFrame <- pin_get("questionFrame", board = "SPACED")

counts <- pin_get("counts", board = "SPACED")

dirTable <- pin_get("dirTable", board = "SPACED")

date_update <- max(trustData$Date)

date_update <- format(date_update, "%d/%m/%Y")

# recode new criticality

trustData <- trustData %>% 
  mutate(ImpCrit = case_when(
    Date >= "2020-10-01" & ImpCrit %in% 0:1 ~ 1L,
    Date >= "2020-10-01" & ImpCrit %in% 2:3 ~ 2L,
    Date >= "2020-10-01" & ImpCrit %in% 4:5 ~ 3L,
    TRUE ~ ImpCrit
  ))

# add the new codes to the bottom of the old codes

trustData <- trustData %>% 
  mutate(Imp1 = case_when(
    Date >= "2020-10-01" ~ Imp_N1,
    TRUE ~ Imp1
  )) %>% 
  mutate(Imp2 = case_when(
    Date >= "2020-10-01" ~ Imp_N2,
    TRUE ~ Imp2
  ))

trustData <- trustData %>% 
  mutate(Best1 = case_when(
    Date >= "2020-10-01" ~ Best_N1,
    TRUE ~ Best1
  )) %>% 
  mutate(Best2 = case_when(
    Date >= "2020-10-01" ~ Best_N2,
    TRUE ~ Best2
  ))


# filter out the staff teams from the counts object

counts <- counts %>% 
  filter(Division < 3)

enableBookmarking(store = "server")
