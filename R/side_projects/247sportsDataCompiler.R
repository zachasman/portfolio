library(tidyverse)
library(rvest)
library(magrittr)
library(dplyr)

all_urls <- paste0("https://247sports.com/Season/2021-Football/CompositeRecruitRankings/?Page=", 1:40)

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

current_rankings <- paste0("https://247sports.com/Season/2021-Football/CompositeTeamRankings/")

team_rankings <- map_df(current_rankings, ~.x %>% read_html %>%
                     html_nodes(".number , .wrapper .avg , .star-commits-list div , .wrapper .team , .total a") %>%
                     html_text() %>% 
                     str_trim %>% 
                     str_split("   ") %>% 
                     matrix(ncol = 7, byrow = T) %>% 
                     as.data.frame)

df_teams <- apply(team_rankings,2,as.character)

write.csv(df_teams, 'df_teams.csv')
