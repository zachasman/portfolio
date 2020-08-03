ui <- dashboardPage(
  dashboardHeader(titleWidth = 200, title = 'Silver State'),
  dashboardSidebar(width = 200,
                   sidebarMenu(id = 'sb_dataset', 
                               menuItem('Home', tabName = 'home_page', icon = icon('home')),
                               menuItem(
                                 text = "Universe Builder",
                                 menuSubItem(text = "Build Universe", tabName = "universe_builder", icon = icon('toolbox'), selected = TRUE),
                                 menuSubItem(text = "Explore Universe", tabName = "pivot_table", icon = icon('search-plus')),
                                 menuSubItem(text = "Compare Universe", tabName = "comparison_tool", icon = icon('images')),
                                 menuSubItem(text = "Map Universe", tabName = "map_universe", icon = icon('map'))
                               ))),
  dashboardBody(
    shinyjs::useShinyjs(), 
    id = "input-panel",
    tags$head(tags$style("section.content { overflow-y: hidden; }")),
    tabItems(
      tabItem(tabName = "universe_builder",  
              tabBox(width = 12, 
                     title = h5('Select Attributes'),
                     tabPanel(h5("Support & Turnout"),
                              fluidRow(
                                column(6,
                                       sliderInput("support", "Support",min = 0, max = 100, value = 0),
                                       sliderInput("turnout", "Turnout",min = 0, max = 100, value = 0),
                                       sliderTextInput(
                                         inputId = "threshold",
                                         label = "Choose your support threshold",
                                         choices = list("No Threshold"=0, "25"=25,"30"=30,"35"=35,"40"=40,"41"=41,"42"=42,"43"=43,"44"=44,"45"=45,"50"=50,"55"=55,"60"=60,"65"=65,"70"=70,"75"=75),
                                         selected = 0,
                                         dragRange = FALSE),
                                       selectizeInput("targets", "Target Categories", multiple = TRUE, choices = c(unique(sort(df_sample$target_categories))))
                                ))
                     ), #End S&T Panel
                     tabPanel(h5("Demographics"),
                              wellPanel(sliderInput("age", "Select Age Range",min = 17,max = 110,value = c(17,110))),
                              fluidRow(
                                column(2, prettyCheckboxGroup("gender", h3("Gender"), choices = list("Female" = "F", "Male" = "M", "Unknown/Other" = "U"))),
                                column(2, prettyCheckboxGroup("ethnicity", h3("Ethnicity"), choices = list("Caucasian" = "W", "African-American" = "B", "Hispanic" = "H","Asian" = "A","Native" = "N"))),
                                column(2, prettyCheckboxGroup("college", h3("Education"), choices = list("College" = "College", "Non-College" = "Non-College", "Unknown" = "Unknown"))),
                                column(2, prettyCheckboxGroup("income", h3("Income"), choices = list("Under $40K" = "Under $40k", "$40K-$60K " = "$40k-$60k", "$60K-$80K" = "$60k-$80k", "$80K-$100K" = "$80k-$100k", "Over $100K" = "Over $100k"))),
                                column(2, prettyCheckboxGroup("party", h3("Party"), choices = list("Democrat" = "Democratic", "NPP" = "Nonpartisan","Independent" = "Independent","Green" = "Green", "Libertarian" = "Libertarian","Republican" = "Republican","Other" = "Other"))))
                     ), #End Demo Panel
                     tabPanel(h5("Geography"),
                              fluidRow(
                                column(width = 2, selectizeInput("senate", "State Senate", multiple = TRUE, choices = c(unique(sort(df_sample$state_senate))))),
                                column(width = 2, selectizeInput("house", "State House", multiple = TRUE, choices = c(unique(sort(df_sample$state_house))))),
                                column(width = 3, prettyCheckboxGroup("congdistrict", "Congressional District", inline = TRUE, choices = list("1" = 1, "2"=2, "3"=3, "4"=4)))
                              ),
                              fluidRow(
                                column(width = 2, selectizeInput("city", "City", multiple = TRUE, choices = c(unique(sort(df_sample$city))))),
                                column(width = 2, selectizeInput("county", "County", multiple = TRUE, choices = c(unique(sort(df_sample$county))))),
                                column(width = 2, selectizeInput("zip", "Zip Code", multiple = TRUE, choices = c(unique(sort(df_sample$zip))))),
                                column(width = 2, selectizeInput("region", "Region", multiple = TRUE, choices = c(unique(sort(df_sample$region))))),
                                column(width = 2, uiOutput("turfs")),
                                column(width = 2, uiOutput("precincts"))),
                              fluidRow(
                                column(width = 12, prettyCheckboxGroup("density", "Density", inline = TRUE, choices = list("Undefined" = "", "Urban"="Urban", "Rural"="Rural", "Suburban"="Suburban")))
                              )  
                     ), #End Geo Panel
                     tabPanel(h5("Scores/Metrics/KPIs"),
                              fluidRow(
                                column(4,
                                       h4(tags$b("Supporters")),
                                       prettyCheckboxGroup("supportint", "ID's", inline = TRUE, choices = list("1"=1,"2")),
                                       prettyCheckboxGroup("ctc", "CTC Collected", inline = TRUE, choices = list("Include" = 1)),
                                       prettyCheckboxGroup("legacy", "Legacy Supporter", inline = TRUE, choices = list("Include" = 1)),
                                       h4(tags$b("Engagement & History")),
                                       prettyCheckboxGroup("donor", "Previous Donor", inline = TRUE, choices = list("Include" = 1)),
                                       prettyCheckboxGroup("attend", "Attended Event", inline = TRUE, choices = list("Include" = 1)),
                                       prettyCheckboxGroup("rsvp", "RSVP'd to Event", inline = TRUE, choices = list("Include" = 1)),
                                       prettyCheckboxGroup("contact", "Contact Made (Penetration)", inline = TRUE, choices = list("Yes" = 1, "No" = 0)),
                                       numericInput("dials", "Dial Attempts ", value = 0),
                                       numericInput("knocks", "Knock Attempts ", value = 0)
                                ),
                                column(4,
                                       h4(tags$b("Potential Support")),
                                       prettyCheckboxGroup("nonsupportint", "ID's", inline = TRUE, choices = list("3"=3,"4"=4,"5"=5)),
                                       prettyCheckboxGroup("donut", "Donut Segment", inline = TRUE, choices = list("No Segment" = "", "Core Bernie"="1_core_bernie","Soft Support"="2_soft_support","Shifter"="3_shifter","Potential Support"="4_potential_support","No Opinion"="5_no_opinion")),
                                       sliderInput("veryexcited", "Sanders Very Excited Score", min = 0, max = 100, value = c(0,0)),
                                       sliderInput("strongsupport", "Sanders Strong Support Score", min = 0, max = 100, value = c(0,0)),
                                       h4(tags$b("Targeting")),
                                       prettyCheckboxGroup("union", "Union", inline = TRUE, choices = list("Modeled" = "Modeled", "Commercial" = "Commercial")),
                                       prettyCheckboxGroup("workingclass", "Working Class Score (Top Decile)", inline = TRUE, choices = list("Include" = 1))
                                ),
                                column(4,
                                       br(),
                                       br(),
                                       prettyCheckboxGroup("mail", "Frequent Mail Reader", inline = TRUE, choices = list("Yes" = 1)),
                                       br(),
                                       sliderInput("television", "TV Viewer Score",min = 0, max = 100, value = 0),
                                       br(),
                                       sliderInput("social", "Social Media User Score",min = 0, max = 100, value = 0),
                                       prettyCheckboxGroup("phone", "Phone Number Available", inline = TRUE, choices = list("Only include those with phone number" = 1,
                                                                                                                            "Include all" = 0))
                                )
                              )
                     ), #End Score Pane
                     tabPanel(h5("Opponents"),
                              fluidRow(
                                column(6,
                                       sliderInput("biden", "Biden Score",min = 0, max = 100, value = c(0,0)),
                                       sliderInput("buttigieg", "Buttigieg Score",min = 0, max = 100, value = c(0,0)),
                                       sliderInput("warren", "Warren Score",min = 0, max = 100, value = c(0,0)),
                                       sliderInput("yang", "Yang Score",min = 0, max = 100, value = c(0,0))
                                ),
                                column(4,
                                       selectizeInput("tp_first", "Third Party (First Choice)", multiple = TRUE, choices = c(unique(df_sample %>% filter(third_party_first_choice != "") %>% select(third_party_first_choice)))),
                                       selectizeInput("tp_second", "Third Party (Second Choice)", multiple = TRUE, choices = c(unique(df_sample %>% filter(third_party_second_choice != "") %>% select(third_party_second_choice))))
                                )
                              )
                     ), #End Opponents Panel
                     tabPanel(h5("Customize"),
                              div(style="display:inline-block", textInput(('name_universe'), label = 'Name Universe')),
                              div(style="display:inline-block", actionButton(('save_universe'),icon = icon('save'), label = 'Save Universe')),
                              panel(h2("Previous Universes"),
                                    uiOutput("checkboxes")
                              )
                     ) #End Customize Box
              ), #End Select Box
              textOutput("countSelection"),
              br(),
              tags$head(tags$style("#countSelection{color: black; font-size: 20px;font-style: bold;}")),
              br(),
              column(12,
                     fluidRow(
                       actionButton("build", "Add to Universe"),
                       actionButton("reset", "Reset Universe"),
                       downloadButton("download", "Download Universe"))),
              br(),
              tags$style(type="text/css",
                         ".shiny-output-error { visibility: hidden; }",
                         ".shiny-output-error:before { visibility: hidden; }"),
              br(),
              br(),
              tabBox(width = 12, title = "Analysis",
                     tabPanel("Overview",
                              fluidRow(
                                column(4,
                                       wellPanel(
                                         textOutput("countUniverse"),
                                         tags$head(tags$style("#countUniverse{color: green; font-size: 20px;font-style: bold;}")),
                                         textOutput("countDoors"),
                                         tags$head(tags$style("#countDoors{color: green; font-size: 16px;font-style: italic;}")),
                                         textOutput("countPhones"),
                                         tags$head(tags$style("#countPhones{color: green; font-size: 16px;font-style: italic;}")))),
                                fluidRow(
                                  column(6,
                                         panel(
                                           tableOutput("view"))))
                              )
                     ),
                     tabPanel("Crosstabs",
                              pivottablerOutput("pvt")
                     ),
                     tabPanel("Target Categories",
                              highchartOutput("heatmap")),
                     tabPanel("Distribution",
                              fluidRow(
                                highchartOutput("supportdist")),
                              fluidRow(
                                highchartOutput("turnoutdist"))),
                     tabPanel("Visualization",
                              column(width = 12,
                                     fluidRow(
                                       column(width = 6,
                                              highchartOutput("donut_breakdown")),
                                       column(6,
                                              plotlyOutput("contact_breakdown"))))
                     )
              ) #End Analysis Box
      ), #End Universe Builder Tab
      tabItem(tabName = "map_universe",
              h2("Map Universe")
      ),
      tabItem(tabName = "pivot_table",
              h2("Explore Universe"),
              rpivotTableOutput("pivotUniverse"), width = "100%", height = "500px"),
      tabItem(tabName = "comparison_tool",
              h2("Compare Universe"),
              uiOutput("checkboxes2"),
              column(width = 12,
                     column(width = 6, offset = 3,
                            box(width = NULL, solidHeader = TRUE, status = "primary",
                                title = "Current Universe", height = 300,
                                tableOutput("viewCurrent")))),
              
              column(width = 12,
                     column(width = 6,
                            box(width = NULL, solidHeader = TRUE, status = "primary",
                                title = textOutput("univ1"), height = 500,
                                tableOutput("view1")
                                
                            ),
                            box(width = NULL, solidHeader = TRUE, status = "primary",
                                title = textOutput("univ2"), height = 500,
                                tableOutput("view2")
                            )
                     ),
                     column(width = 6,
                            box(width = NULL, solidHeader = TRUE, status = "primary",
                                title = textOutput("univ3"), height = 500,
                                tableOutput("view3")
                                
                            ),
                            box(width = NULL, solidHeader = TRUE, status = "primary",
                                title = textOutput("univ4"), height = 500,
                                tableOutput("view4")
                            )
                     )
              )
      )
    ) #End TabItems
  ) #End DashboardBody
) #End DashboardPage
