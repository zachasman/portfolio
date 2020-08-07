#Script used to calculate key delegate acquisition metrics

library(civis)
library(dplyr)
library(tidyr)
library(tidyverse)
library(stringr)
library(dbplyr)

delegates <- sql("SELECT
van_precinct_id,
                 precinct_name,
                 county,
                 congressional_district,
                 total_participants,
                 delegates,
                 viability_threshold,
                 CEILING(preference_threshold) preference_threshold,
                 bennet_total_realignment,
                 CASE WHEN bennet_total_realignment >= CEILING(preference_threshold) THEN 1 ELSE 0 END bennet_viable,
                 biden_total_realignment,
                 CASE WHEN biden_total_realignment >= CEILING(preference_threshold) THEN 1 ELSE 0 END biden_viable,
                 buttigieg_total_realignment,
                 CASE WHEN buttigieg_total_realignment >= CEILING(preference_threshold) THEN 1 ELSE 0 END buttigieg_viable,
                 delaney_total_realignment,
                 CASE WHEN delaney_total_realignment >= CEILING(preference_threshold) THEN 1 ELSE 0 END delaney_viable,
                 gabbard_total_realignment,
                 CASE WHEN gabbard_total_realignment >= CEILING(preference_threshold) THEN 1 ELSE 0 END gabbard_viable,
                 klobuchar_total_realignment,
                 CASE WHEN klobuchar_total_realignment >= CEILING(preference_threshold) THEN 1 ELSE 0 END klobuchar_viable,
                 patrick_total_realignment,
                 CASE WHEN patrick_total_realignment >= CEILING(preference_threshold) THEN 1 ELSE 0 END patrick_viable,
                 sanders_total_realignment,
                 CASE WHEN sanders_total_realignment >= CEILING(preference_threshold) THEN 1 ELSE 0 END sanders_viable,
                 steyer_total_realignment,
                 CASE WHEN steyer_total_realignment >= CEILING(preference_threshold) THEN 1 ELSE 0 END steyer_viable,
                 warren_total_realignment,
                 CASE WHEN warren_total_realignment >= CEILING(preference_threshold) THEN 1 ELSE 0 END warren_viable,
                 yang_total_realignment,
                 CASE WHEN yang_total_realignment >= CEILING(preference_threshold) THEN 1 ELSE 0 END yang_viable,
                 uncommitted_total_realignment,
                 CASE WHEN uncommitted_total_realignment >= CEILING(preference_threshold) THEN 1 ELSE 0 END uncommitted_viable
                 FROM
                 nv_caucus_night.caucus_day_reporting_valid cdrv") %>% read_civis()

df_delegates <- delegates %>% select(van_precinct_id, total_participants, preference_threshold, viability_threshold, delegates, bennet_total_realignment, biden_total_realignment, buttigieg_total_realignment, delaney_total_realignment, gabbard_total_realignment,
                                     klobuchar_total_realignment, patrick_total_realignment, sanders_total_realignment, steyer_total_realignment, warren_total_realignment, 
                                     yang_total_realignment, uncommitted_total_realignment) %>% replace(is.na(.), 0) 

df_math <- df_delegates %>% rename(Bennet = bennet_total_realignment, 
                        Biden = biden_total_realignment,
                        Buttigieg = buttigieg_total_realignment,
                        Delaney = delaney_total_realignment,
                        Gabbard = gabbard_total_realignment,
                        Klobuchar = klobuchar_total_realignment,
                        Patrcik = patrick_total_realignment,
                        Sanders = sanders_total_realignment,
                        Steyer = steyer_total_realignment,
                        Warren = warren_total_realignment,
                        Yang = yang_total_realignment,
                        Uncommitted = uncommitted_total_realignment) %>%
  pivot_longer(cols = -c(van_precinct_id, total_participants, preference_threshold, viability_threshold, delegates),
               names_to = 'candidate', values_to = 'votes') %>% as.data.frame() %>% select(van_precinct_id,delegates,total_participants,candidate,votes,preference_threshold,viability_threshold)


# Single Delegates --------------------------------------------------------

df_math_calc1 <- df_math %>% filter(delegates == 1) %>% mutate(VotesRank = rank(-votes),
                                                                Viable = 0,
                                                                TotalViable = 0,
                                                                Formula = 0.00,
                                                                Number = 0,
                                                                Decimal = 0.00,
                                                                FormulaDecimalRank = 0,
                                                                Rounding = 0.00,
                                                                InitialDelegates = 0,
                                                                NextRounding = 0.00,
                                                                RoundRankUp = 0,
                                                                RoundRankDown = 0,
                                                                TotalInitialDelegates = 0,
                                                                RemainingDelegates = 0,
                                                                ToAdd = 0,
                                                                TotalDelegatesAdd = 0,
                                                                ToSubstract = 0,
                                                                TotalDelegatesSubtract = 0,
                                                                FinalDelegates = case_when(VotesRank == 1 ~ 1, VotesRank == 1.5 ~ 0.5, VotesRank > 1.5 ~ 0))

# 2 Delegates --------------------------------------------------------

df_math_calc2 <- df_math %>% filter(delegates == 2) %>% group_by(van_precinct_id) %>% mutate(VotesRank = min_rank(-votes),
                                                               Viable = case_when(votes >= preference_threshold ~ 1, votes < preference_threshold ~ 0),
                                                               TotalViable = sum(Viable),
                                                               Formula = case_when(Viable == 1 ~ round((delegates * votes)/total_participants,4), Viable == 0 ~ 0.00),
                                                               Number = str_extract(Formula, '^(\\d+)'),
                                                               Number = as.numeric(Number),
                                                               Decimal = str_extract(Formula, '\\.\\d+'),
                                                               Decimal = as.numeric(Decimal),
                                                               FormulaDecimalRank = case_when(!is.na(Decimal) ~ rank(Decimal), is.na(Decimal) ~ 0),
                                                               Rounding = case_when(Decimal >= .5 ~ ceiling(Decimal), Decimal < .5 ~ floor(Decimal)),
                                                               InitialDelegates = case_when(Rounding == 1 ~ Number + 1, Rounding == 0 ~ Number),
                                                               NextRounding = round(InitialDelegates + 0.5 - Formula, 4),
                                                               RoundRankUp = case_when(!is.na(NextRounding) ~ rank(NextRounding), is.na(NextRounding) ~ 0),
                                                               RoundRankDown = case_when(!is.na(NextRounding) ~ rank(-NextRounding), is.na(NextRounding) ~ 0),
                                                               InitialDelegates = if_else(is.na(InitialDelegates), 0, InitialDelegates),
                                                               TotalInitialDelegates = sum(InitialDelegates),
                                                               RemainingDelegates = delegates - TotalInitialDelegates)

if(df_math_calc2$RemainingDelegates == 0) {
  
  df_math_delegates2 <- df_math_calc2 %>% group_by(van_precinct_id) %>% mutate(ExtraDelegatesCheck = 0,
                                                                               ToAdd = 0,
                                                                               TotalDelegatesAdd = 0,
                                                                               ToSubtract = 0,
                                                                               TotalDelegatesSubtract = 0,
                                                                               FinalDelegates = InitialDelegates)
  
} else if(df_math_calc2$RemainingDelegates < 0) {
  
  df_math_delegates2 <- df_math_calc2 %>% group_by(van_precinct_id) %>% mutate(ExtraDelegatesCheck = 0,
                                                                               ToAdd = 0,
                                                                               TotalDelegatesAdd = 0,
                                                                               ToSubtract = 0,
                                                                               TotalDelegatesSubtract = 0,
                                                                               FinalDelegates = InitialDelegates)
}

# 3 Delegates --------------------------------------------------------

df_math_calc3 <- df_math %>% filter(delegates == 3) %>% group_by(van_precinct_id) %>% mutate(VotesRank = min_rank(-votes),
                                                                                             Viable = case_when(votes >= preference_threshold ~ 1, votes < preference_threshold ~ 0),
                                                                                             TotalViable = sum(Viable),
                                                                                             Formula = case_when(Viable == 1 ~ round((delegates * votes)/total_participants,4), Viable == 0 ~ 0.00),
                                                                                             Number = str_extract(Formula, '^(\\d+)'),
                                                                                             Number = as.numeric(Number),
                                                                                             Decimal = str_extract(Formula, '\\.\\d+'),
                                                                                             Decimal = as.numeric(Decimal),
                                                                                             FormulaDecimalRank = case_when(!is.na(Decimal) ~ rank(Decimal), is.na(Decimal) ~ 0),
                                                                                             Rounding = case_when(Decimal >= .5 ~ ceiling(Decimal), Decimal < .5 ~ floor(Decimal)),
                                                                                             InitialDelegates = case_when(Rounding == 1 ~ Number + 1, Rounding == 0 ~ Number),
                                                                                             NextRounding = round(InitialDelegates + 0.5 - Formula, 4),
                                                                                             RoundRankUp = case_when(!is.na(NextRounding) ~ rank(NextRounding), is.na(NextRounding) ~ 0),
                                                                                             RoundRankDown = case_when(!is.na(NextRounding) ~ rank(-NextRounding), is.na(NextRounding) ~ 0),
                                                                                             InitialDelegates = if_else(is.na(InitialDelegates), 0, InitialDelegates),
                                                                                             TotalInitialDelegates = sum(InitialDelegates),
                                                                                             RemainingDelegates = delegates - TotalInitialDelegates)

                                                               
                                                               # ToAdd = ifelse(Viable == 1, ifelse(RemainingDelegates>0, floor(RemainingDelegates/TotalViable)
                                                               #                                    + (RoundRankUp<=(RemainingDelegates%%TotalViable)), 0),0),
                                                               # TotalDelegatesAdd = InitialDelegates + ToAdd,
                                                               # ToSubstract = case_when(RemainingDelegates < 0 & FormulaDecimalRank == 1 ~ RemainingDelegates, RemainingDelegates < 0 & FormulaDecimalRank > 1 ~ 0),
                                                               # TotalDelegatesSubtract = InitialDelegates + ToSubstract,
                                                               # FinalDelegates = case_when(ExtraDelegatesCheck == 0 ~ TotalInitialDelegates, ExtraDelegatesCheck == 1)) %>% replace(is.na(.), 0) 


df_math_calc <- df_math %>% filter(delegates > 3) %>% group_by(van_precinct_id) %>% mutate(VotesRank = rank(-votes),
                                   Viable = case_when(votes >= preference_threshold ~ 1, votes < preference_threshold ~ 0),
                                   TotalViable = sum(Viable),
                                   Formula = case_when(Viable == 1 ~ round((delegates * votes)/total_participants,4), Viable == 0 ~ 0.00),
                                   Number = str_extract(Formula, '^(\\d+)'),
                                   Number = as.numeric(Number),
                                   Decimal = str_extract(Formula, '\\.\\d+'),
                                   Decimal = as.numeric(Decimal),
                                   FormulaDecimalRank = case_when(!is.na(Decimal) ~ rank(Decimal), is.na(Decimal) ~ 0),
                                   Rounding = case_when(Decimal >= .5 ~ ceiling(Decimal), Decimal < .5 ~ floor(Decimal)),
                                   InitialDelegates = case_when(Rounding == 1 ~ Number + 1, Rounding == 0 ~ Number),
                                   NextRounding = round(InitialDelegates + 0.5 - Formula, 4),
                                   RoundRankUp = case_when(!is.na(NextRounding) ~ rank(NextRounding), is.na(NextRounding) ~ 0),
                                   RoundRankDown = case_when(!is.na(NextRounding) ~ rank(-NextRounding), is.na(NextRounding) ~ 0),
                                   InitialDelegates = if_else(is.na(InitialDelegates), 0, InitialDelegates),
                                   TotalInitialDelegates = sum(InitialDelegates),
                                   RemainingDelegates = delegates - TotalInitialDelegates,
                                   ToAdd = ifelse(Viable == 1, ifelse(RemainingDelegates>0, floor(RemainingDelegates/TotalViable)
                                                                      + (RoundRankUp<=(RemainingDelegates%%TotalViable)), 0),0),
                                   TotalDelegatesAdd = InitialDelegates + ToAdd,
                                   ToSubstract = case_when(RemainingDelegates < 0 & FormulaDecimalRank == 1 ~ RemainingDelegates, RemainingDelegates < 0 & FormulaDecimalRank > 1 ~ 0),
                                   TotalDelegatesSubtract = InitialDelegates + ToSubstract,
                                   FinalDelegates = case_when(RemainingDelegates < 0 ~ TotalDelegatesSubtract, RemainingDelegates >= 0 ~ TotalDelegatesAdd)) %>% replace(is.na(.), 0) 
                                   

#Adjust for under four scenario
#Principle 2
