#!/usr/bin/env Rscript
library(rvest)
library(httr)
library(dplyr)
library(stringr)
library(purrr)
library(urltools)
library(jsonlite)
library(lubridate)
library(googledrive)
library(googlesheets4)
source('helpers.R')

uprn <- Sys.getenv('UPRN')
request_url <- Sys.getenv('API_URL')
asset_url <- Sys.getenv('ASSET_URL')
gc_sa <- Sys.getenv('GC_SA')
gs_key <- Sys.getenv('GS_KEY')

ua_strings <- getUA()
calendar_df <- getCal(
  request_url, uprn,
  ua_strings, asset_url)

# Authenticate
gs4_auth(
  path = gc_sa,
  scopes = c(
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive'))

'GS_KEY' %>%
  Sys.getenv() %>%
  gs4_get() %>%
  sheet_write(
    calendar_df, ss = ., sheet = 'Sheet1')
