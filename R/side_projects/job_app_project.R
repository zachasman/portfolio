##This was a project I did for another job. While I ultimately ended up not taking the role, it was still an informative project that required a good deal of work.

library(gdata)
library(plyr)
library(dplyr)
library(ggplot2)
library(reshape2)
library(ggcorrplot)
library(stringr)

HDL<-read.csv("C:/Users/c02716a/Documents/R/da_reporting_project_dataset.csv")

############################################################################
### Report Number of Teams that convert to a paid subscription each week ###
############################################################################
#1. Group data by week
summary(HDL$trial_start)
arrange(HDL, trial_start)
now <- as.Date("2017-05-02")
dates <- seq(now, now + 365, by = "1 day") 
HDL2 <- data.frame(Dates = dates, Week = format(dates, format = "%W"))
names(HDL2) <- sub('Dates','trial_start',names(HDL2))
glimpse(HDL2)
combineHDL <- join(HDL, HDL2, by='trial_start', type='left', match='all')
combineHDL[is.na(combineHDL)] <- 0
summary(combineHDL$Week)
#2. Examine outliers and decide how to handle them (got rid of Week 46 and 50)
test<-subset(combineHDL, Week==50 | Week==46)

refineHDL<-subset(combineHDL, Week==18| Week==19 | Week==20 | Week==21
               | Week==22 | Week==23 | Week==24 | Week==25 | Week==26 | Week==27
               | Week==28 | Week==29 | Week==30 | Week==31 | Week==32 | Week==33
               | Week==34 | Week==35 | Week==36 | Week==37 | Week==38 | Week==39
               | Week==40 | Week==41 | Week==42 | Week==43 | Week==44 | Week==45)
summary(refineHDL$Week)
#Number of Teams Converting Each Week
df_HDL<- ddply(refineHDL, "Week",
                   transform, Count_Conversions_per_Week=sum(didconvert=="True"), Count_Teams_per_Week=sum(didconvert=="True" | didconvert=="False"))
df_HDL1<-mutate(df_HDL, prct_cnvrt=Count_Conversions_per_Week/Count_Teams_per_Week)
head(df_HDL1)
summary(df_HDL1)

#Report
ggplot(df_HDL1, aes(x=Week, fill =didconvert))+
  geom_bar(position = "dodge")+
  labs(title=centerText("Conversion of Teams"), x="Weeks", y="Total Teams with Free Trials")+ ylim(0, 600) 

################################################################################################
### Report Percentage of teams that convert to a paid subscription by week the trial started ###
################################################################################################
summary(refineHDL$days_to_convert)
refineHDL$didconvert <- as.integer(refineHDL$didconvert == "True")
summary(refineHDL)
cnvrtwk1<- ddply(refineHDL, "Week",
                 mutate,  Number_Teams=sum(didconvert))
summary(cnvrtwk1)
cnvrtwk2<-subset(cnvrtwk1, days_to_convert <= 7)
summary(cnvrtwk2)
#reset outliers that have negative value
cnvrtwk2$days_to_convert[cnvrtwk2$days_to_convert < 0] <- 0
summary(cnvrtwk2)
cnvrtwk3<- ddply(cnvrtwk2, "Week",
                   mutate, ttl_wk_cnvrsion=sum(didconvert))
cnvrtwk4<-subset(cnvrtwk3, select = c("Teamid","ttl_wk_cnvrsion"))
jnbck<-left_join(cnvrtwk1, cnvrtwk4, by="Teamid" )
jnbck1<-subset(jnbck, select = c("Teamid","ttl_wk_cnvrsion", "Number_Teams"))
jnbck2<-left_join(refineHDL, jnbck1, by="Teamid" )
head(jnbck2)
prcnt_tms_wk_cnvsn<-mutate(jnbck2, prcnt_wk_cnvsn=ttl_wk_cnvrsion/Number_Teams)
prcnt_tms_wk_cnvsn[is.na(prcnt_tms_wk_cnvsn)] <- 0
summary(prcnt_tms_wk_cnvsn$prcnt_wk_cnvsn)

#Report
report<-prcnt_tms_wk_cnvsn[!duplicated(prcnt_tms_wk_cnvsn[,c('Week')]),]
ggplot(report,aes(x = Week, fill = Number_Teams, y =prcnt_wk_cnvsn)) +
       geom_bar(stat="identity")+ ylim(0, 1) +
       labs(title=centerText(("Conversion by Week")), x="Weeks", y="Percent Converted by End of Week")+
       theme(axis.text.x= element_text(angle=80, hjust = -.5, vjust = -.2))
#############################################################################################
### Report Percentage of teams doing each of the engagement activities                    ###
### (uploading video, viewing video, creating highlights, and adding teammates to roster) ###
### by week the trial started                                                             ###
#############################################################################################
nonzero <- function(x) sum(x != 0)
summary(prcnt_tms_wk_cnvsn)
engage_HDL<- ddply(prcnt_tms_wk_cnvsn, "Week",
               mutate, prct_upload=nonzero(uploads)/nonzero(Teamid),
                       prct_views=nonzero(viewers)/nonzero(Teamid),
                       prct_hghlts=nonzero(highlights)/nonzero(Teamid),
                       prct_roster=(nonzero(athletes))/nonzero(Teamid))
head(engage_HDL)
summary(engage_HDL)

#Report
report1<-engage_HDL[!duplicated(engage_HDL[,c('Week')]),]
#percent Uploaded
ggplot(report1,aes(x = Week, fill = Number_Teams, 
                  y =prct_upload)) +
  geom_bar(stat="identity")+ ylim(0, 1) +
  labs(title="Percentage Uploading Videos", x="Weeks", y="Percentage")+
  theme(axis.text.x= element_text(angle=80, hjust = -.5, vjust = -.2))

#Viewing Videos
ggplot(report1,aes(x = Week, fill = Number_Teams, 
                   y =prct_views)) +
  geom_bar(stat="identity")+ ylim(0, 1) +
  labs(title="Percentage Viewing Videos", x="Weeks", y="Percentage")+
  theme(axis.text.x= element_text(angle=80, hjust = -.5, vjust = -.2))

#creating highlights
ggplot(report1,aes(x = Week, fill = Number_Teams, 
                   y =prct_hghlts)) +
  geom_bar(stat="identity")+ ylim(0, 1) +
  labs(title=("Percentage Creating Highlights"), x="Weeks", y="Percentage")+
  theme(axis.text.x= element_text(angle=80, hjust = -.5, vjust = -.2))

#adding rosters
ggplot(report1,aes(x = Week, fill = Number_Teams, 
                   y =prct_roster)) +
  geom_bar(stat="identity")+ ylim(0, 1) +
  labs(title=("Percentage Adding Teammates to the Roster"), x="Weeks", y="Percentage")+
  theme(axis.text.x= element_text(angle=80, hjust = -.5, vjust = -.2))

##############################################################################################
##  Report Funnel analysis of adding users to a roster (three variables), uploading video, ###
### and watching video                                                                     ###
##############################################################################################

summary(engage_HDL)
colSums(engage_HDL != 0)
df.total<-data.frame(content = c('Total', 'Athlete_Roster', 'Coach_Roster', 'Admin_Roster', 'Upload_Roster',
                                'Viewers', 'Did_Convert'),
                     step = c('awareness', 'interest', 'interest', 'interest', 'desire', 'desire',
                             'action'),
                     number = c(7734, 1384, 1079, 4952, 2215, 2069, 2797)) 

# calculating dummies, max and min values of X for plotting
df.total <- df.total %>%
  group_by(step) %>%
  mutate(totnum = sum(number)) %>%
  ungroup() %>%
  mutate(dum = (max(totnum) - totnum)/2,
         maxx = totnum + dum,
         minx = dum)

# data frame for plotting funnel lines
df.lines <- df.total %>%
  distinct(step, maxx, minx)

# data frame with dummies
df.dum <- df.total %>%
  distinct(step, dum) %>%
  mutate(content = 'dummy',
         number = dum) %>%
  select(content, step, number)

# data frame with rates
conv <- df.total$totnum[df.total$step == 'action']

df.rates <- df.total %>%
  distinct(step, totnum) %>%
  mutate(prevnum = lag(totnum),
         rate = ifelse(step == 'new' | step == 'engaged' | step == 'loyal',
                       round(totnum / conv, 3),
                       round(totnum / prevnum, 3))) %>%
  select(step, rate)
df.rates <- na.omit(df.rates)

# creting final data frame
df.total <- df.total %>%
  select(content, step, number)

df.total <- rbind(df.total, df.dum)

# defining order of steps
df.total$step <- factor(df.total$step, levels = c('action','desire', 'interest', 'awareness'))
df.total <- df.total %>%
  arrange(desc(step))
list1 <- df.total %>% distinct(content) %>%
  filter(content != 'dummy')
df.total$content <- factor(df.total$content, levels = c(as.character(list1$content), 'dummy'))

# calculating position of labels
df.total <- df.total %>%
  arrange(step, desc(content)) %>%
  group_by(step) %>%
  mutate(pos = cumsum(number) - 0.5*number) %>%
  ungroup()

# creating custom palette with 'white' color for dummies
cols <- c( "#fdbb84", "#a1d99b", "#fee0d2",
          "#2ca25f", "#8856a7","#fc9272", "#2E8B57", "#F5F5F5")

# plotting chart
ggplot() +
  theme_minimal() +
  coord_flip() +
  scale_fill_manual(values=cols) +
  geom_bar(data=df.total, aes(x=step, y=number, fill=content), stat="identity", width=1) +
  geom_text(data=df.total[df.total$content!='dummy', ],
            aes(x=step, y=pos, label=paste0(content, '-', number/1000, 'K')),
            size=2, color='black', fontface="bold") +
  geom_ribbon(data=df.lines, aes(x=step, ymax=max(maxx), ymin=maxx, group=1), fill='white') +
  geom_line(data=df.lines, aes(x=step, y=maxx, group=1), color='darkred', size=1) +
  geom_ribbon(data=df.lines, aes(x=step, ymax=minx, ymin=min(minx), group=1), fill='white') +
  geom_line(data=df.lines, aes(x=step, y=minx, group=1), color='darkred', size=1) +
  geom_text(data=df.rates, aes(x=step, y=(df.lines$minx[-1]), label=paste0(rate*100, '%')), hjust=.5,
            color='darkblue', fontface="bold") +
  theme(legend.position='none', axis.ticks=element_blank(), axis.text.x=element_blank(), 
        axis.title.x=element_blank())

###############################################################################################
### Report Analysis of activities and attributes that are most commonly associated with     ###
### converting to a paid subscription                                                       ###
###############################################################################################

summary(engage_HDL$country)
unique(engage_HDL$country)

engage_HDL[,5] <-ifelse(engage_HDL[,5] == "United States", 1, ifelse(engage_HDL[,5] == "United Kingdom", 2, 
                 ifelse(engage_HDL[,5] == "Germany", 3, ifelse(engage_HDL[,5] == "Ireland", 4, 
                 ifelse(engage_HDL[,5] == "France", 5, ifelse(engage_HDL[,5] == "Canada", 6,
                 ifelse(engage_HDL[,5] == "Spain", 5, 99)))))))

engage_HDLc<-subset(engage_HDL, select = c("didconvert","sport", "organizationtype",
                                           "trial_length", "highlights",
                                           "athletes", "coaches", "admins", "uploads", "viewers",
                                           "Week", "country"))
engage_HDLc$Week<-as.integer(engage_HDLc$Week)
glimpse(engage_HDLc)
corr <- round(cor(engage_HDLc), 2)
head(corr[, 1:12])
ggcorrplot(corr, method = "circle")

model1<-step(lm(didconvert~Week+viewers+uploads+athletes+organizationtype+sport+country,data=engage_HDLc),direction="both")
summary(model1)

#####################################################################################################
### Report Any other interesting trends or tracking you feel are relevant to the team's objective ###
#####################################################################################################


#Teamid: a unique identifier for a team
#Datecreated: date the team's GoSports account was created
#Sport: Enumerator, each number represents a certain sport 
#Country: Country in which the team originates
#OrganizationType: Enumerator, each number represents a particular type of organization to which the team belongs
#Trial_start: the date the team began their free trial
#Trial_length: the number of days that the team's free trial was set to
#Days_to_convert: the number of days it took a team to convert to a paid subscription (will be null if the team did not convert)
#DidConvert: Boolean, did the team convert to a paid subscription
#Highlights: Number of highlights created by the team during the trial period
#Athletes: Number of athletes added to the team roster during the trial period
#Coaches: Number of coaches added to the team roster during the trial period
#Admins: Number of admins added to the team roster during the trial period
#Uploads: Number of videos uploaded during the trial period
#Viewers: Number of user that viewed video during the trial period
