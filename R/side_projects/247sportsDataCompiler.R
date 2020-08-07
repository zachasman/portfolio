library(tidyverse)
library(rvest)
library(magrittr)
library(dplyr)

all_urls <- paste0("https://247sports.com/Season/2021-Football/CompositeRecruitRankings/?Page=", 1:41)

rankings <- map_df(all_urls, ~.x %>% read_html %>%
                  html_nodes(".meta , .rankings-page__star-and-score .score , .position , .rankings-page__name-link") %>%
                  html_text() %>% 
                  str_trim %>% 
                  str_split("   ") %>% 
                  matrix(ncol = 4, byrow = T) %>% 
                  as.data.frame)

df <- apply(rankings,2,as.character)

df_players <- as.data.frame(df) 

write.csv(df_players, '2021_rankings.csv')

commits <- paste0("https://247sports.com/Season/2021-Football/Commits/?Page=", 1:38)

all_data <- map_df(commits, ~{
  webpage <- .x %>% read_html
  df1 <-  webpage %>%
    html_nodes(".ri-page__star-and-score .score ,.position ,.ri-page__name-link") %>%
    html_text() %>% 
    str_trim %>% 
    str_split("   ") %>% 
    matrix(ncol = 3, byrow = T) %>% 
    as.data.frame
  df1$title <- webpage %>%
    html_nodes('div.status img') %>%
    html_attr('title') %>%
    .[c(TRUE, FALSE)]
  df1
})

all_data <- as.data.frame(all_data)

all_df <- apply(all_data,2,as.character)

write.csv(all_df, 'commits.csv')
