server <- function(input,output,session){
  
  output$turfs <- renderUI({
    selectizeInput("turf", "Turf", multiple = TRUE, c(unique(sort(df_sample$turf[df_sample$region == input$region]))))
  })

  output$precincts <- renderUI({
    selectizeInput("precinct", "Precinct", multiple = TRUE, c(unique(sort(df_sample$precinct[df_sample$turf == input$turfs]))))
  })

  output$checkboxes <- renderUI({
    checkboxGroupInput("checkboxes", "Filters:", inline = TRUE, choices = unique(sort(foo$filters$id)), selected = NULL)
  })

  output$checkboxes2 <- renderUI({
    checkboxGroupInput("checkboxes2", "Filters:", inline = TRUE, choices = unique(sort(foo$filters$id)), selected = NULL)
  })

  filterData = reactiveVal(df_sample %>% mutate(key = 1:nrow(df_sample), key = as.character(key)))

  addedToList = reactiveVal(data.frame())

  foo <- reactiveValues(filters = data.frame(id = character(),person_id = character()))

  gatherData <- reactive({
    filterData() %>% filter(current_support_raw >= input$support  &
                              turnout_current >= input$turnout  &
                              max_threshold >= input$threshold &
                              (target_categories %in% input$targets | is.null(input$targets)) &
                              (gender %in% input$gender | is.null(input$gender))  &
                              (ethnicity %in% input$ethnicity | is.null(input$ethnicity))  &
                              (college_status %in% input$college | is.null(input$college))  &
                              (income %in% input$income | is.null(input$income))   &
                              (party %in% input$party | is.null(input$party)) &
                              (congressional_district %in% input$cd | is.null(input$cd))   &
                              (city %in% input$city | is.null(input$city))   &
                              (county %in% input$county | is.null(input$county))  &
                              (zip %in% input$zip | is.null(input$zip))  &
                              (region %in% input$region | is.null(input$region))  &
                              (turf %in% input$turf | is.null(input$turf))  &
                              (precinct %in% input$precinct | is.null(input$precinct)) &
                              (density %in% density | is.null(input$density)) &
                              (support_int %in% input$supportint | is.null(input$supportint))  &
                              (support_int %in% input$nonsupportint | is.null(input$nonsupportint)) &
                              (ctc %in% input$ctc | is.null(input$ctc)) &
                              (legacy_support %in% input$legacy | is.null(input$legacy)) &
                              (donated %in% input$donor | is.null(input$donor)) &
                              (attended_1_event %in% input$attend | is.null(input$attend)) &
                              (rsvpd_1_event %in% input$rsvp | is.null(input$rsvp)) &
                              (contact_made %in% input$contact | is.null(input$contact)) &
                              total_dials >= input$dials &
                              total_knocks >= input$knocks &
                              (donut_segment %in% input$donut | is.null(input$donut)) &
                              sanders_very_excited_score >= input$veryexcited &
                              sanders_strong_support_score >= input$strongsupport &
                              (union_flag %in% input$union | is.null(input$union)) &
                              (working_class_score %in% input$workingclass | is.null(input$workingclass)) &
                              (mail_reader_frequent %in% input$mail | is.null(input$mail)) &
                              social_media_user_score >= input$social &
                              tv_viewer_watch_live_score >= input$television &
                              biden_support >= input$biden &
                              buttigieg_support >= input$buttigieg &
                              warren_support >= input$warren &
                              yang_support >= input$yang &
                              (third_party_first_choice %in% input$tp_first | is.null(input$tp_first)) &
                              (third_party_second_choice %in% input$tp_second | is.null(input$tp_second))) %>%
      filter(phone %in% input$phone | is.null(input$phone))
  })

  savedData <- reactive({
    if (is.null(input$checkboxes)) {
      gatherData()
    } else {
      foo$filters %>% filter(id == input$checkboxes) %>% select(person_id, id)
    }
  })

  observeEvent(input$save_universe, ignoreInit = FALSE, {
    if(nrow(addedToList()) > 0) {
      foo$filters <- rbind(foo$filters, data.frame(id = input$name_universe, person_id = addedToList()$person_id))
    } else{
      foo$filters <- rbind(foo$filters, data.frame(id = input$name_universe,person_id = savedData()$person_id))
    }
  })

  observeEvent(input$build, {
    addedToList(rbind(addedToList(),
                      filterData() %>% filter(key %in% gatherData()$key) %>%
                        select_all() %>% distinct()))

    filterData(filterData() %>% filter(!key %in% gatherData()$key))

    shinyjs::reset("input-panel")
  })

  output$countSelection <-renderText({
    res <- gatherData() %>% select(person_id) %>% n_distinct()
    paste("Current Selection Size:",res)
  })

  output$countUniverse <- renderText({
    res <- addedToList() %>% select(person_id) %>% n_distinct()
    paste("Current Universe Size:",res)
  })

  output$countDoors <- renderText({
    res <- addedToList() %>% select(voting_address_id) %>% n_distinct()
    paste("Total Doors:",res)
  })

  output$countPhones <- renderText({
    res <- addedToList() %>% filter(phone == 1) %>% select(person_id) %>% n_distinct()
    paste("Total Phone Numbers",res)
  })

  output$univ1 <- renderText({
    if (is.null(input$checkboxes2[1])) {
      paste("Awaiting Inputs")
    } else {
      res <- foo$filters %>% filter(id == input$checkboxes2[1])
      res <- res$id[1]
      paste("Universe:", res)
    }
  })

  output$univ2 <- renderText({
    if (is.null(input$checkboxes2[2])) {
      paste("Awaiting Inputs")
    } else {
      res <- foo$filters %>% filter(id == input$checkboxes2[2])
      res <- res$id[1]
      paste("Universe:", res)
    }
  })

  output$univ3 <- renderText({
    if (is.null(input$checkboxes2[3])) {
      paste("Awaiting Inputs")
    } else {
      res <- foo$filters %>% filter(id == input$checkboxes2[3])
      res <- res$id[1]
      paste("Universe:", res)
    }
  })

  output$univ4 <- renderText({
    if (is.null(input$checkboxes2[4])) {
      paste("Awaiting Inputs")
    } else {
      res <- foo$filters %>% filter(id == input$checkboxes2[4])
      res <- res$id[1]
      paste("Universe:", res)
    }
  })

  output$view <- renderTable({
    res <- req(addedToList())
    res1 <- res %>% mutate(target=1, support_ids = case_when(support_int %in% c(1,2) ~ 1, !support_int %in% c(3,4,5,6) ~ 0),  support_ids = tidyr::replace_na(support_ids,0)) %>% select(region, target, turnout_current, current_support_raw, support_ids, ctc) %>%
      group_by(region) %>% summarise(`Total Targets` = sum(as.integer(target)), `Average Turnout` = mean(turnout_current), `Average Support` = mean(turnout_current), `Current Support IDs` = sum(as.integer(support_ids)), CTCs = sum(ctc)) %>% rename(Region = region)
    resTotal <- res %>% mutate(Region = 'All') %>% mutate(target=1, support_ids = case_when(support_int %in% c(1,2) ~ 1, !support_int %in% c(3,4,5,6) ~ 0),  support_ids = tidyr::replace_na(support_ids,0)) %>% select(Region, target, turnout_current, current_support_raw, support_ids, ctc) %>%
      group_by(Region) %>% summarise(`Total Targets` = sum(as.integer(target)), `Average Turnout` = mean(turnout_current), `Average Support` = mean(turnout_current), `Current Support IDs` = sum(as.integer(support_ids)), CTCs = sum(ctc))
    rbind(res1,resTotal)
  },  striped = TRUE, bordered = TRUE,  hover = TRUE,  align = 'c')

  output$viewCurrent <- renderTable({
    res <- req(addedToList())
    res1 <- res %>% mutate(target=1, support_ids = case_when(support_int %in% c(1,2) ~ 1, !support_int %in% c(3,4,5,6) ~ 0),  support_ids = tidyr::replace_na(support_ids,0)) %>% select(region, target, turnout_current, current_support_raw, support_ids) %>%
      group_by(region) %>% summarise(`Total Targets` = sum(as.integer(target)), `Average Turnout` = mean(turnout_current), `Average Support` = mean(turnout_current), `Current Support IDs` = sum(as.integer(support_ids))) %>% rename(Region = region)
    resTotal <- res %>% mutate(Region = 'All') %>% mutate(target=1, support_ids = case_when(support_int %in% c(1,2) ~ 1, !support_int %in% c(3,4,5,6) ~ 0),  support_ids = tidyr::replace_na(support_ids,0)) %>% select(Region, target, turnout_current, current_support_raw, support_ids) %>%
      group_by(Region) %>% summarise(`Total Targets` = sum(as.integer(target)), `Average Turnout` = mean(turnout_current), `Average Support` = mean(turnout_current), `Current Support IDs` = sum(as.integer(support_ids)))
    rbind(res1,resTotal)
  },  striped = TRUE, bordered = TRUE,  hover = TRUE, width = "auto", align = 'c')

  output$view1 <- renderTable({
    if (is.null(input$checkboxes2[1])) {
      paste("No Selection")
    } else {
      res1 <- foo$filters %>% filter(id == input$checkboxes2[1]) %>% inner_join(filterData(), by = "person_id") %>% mutate(target=1, support_ids = case_when(support_int %in% c(1,2) ~ 1, !support_int %in% c(3,4,5,6) ~ 0),  support_ids = tidyr::replace_na(support_ids,0)) %>% select(region, target, turnout_current, current_support_raw, support_ids) %>%
        group_by(region) %>% summarise(`Total Targets` = sum(as.integer(target)), `Average Turnout` = mean(turnout_current), `Average Support` = mean(turnout_current), `Current Support IDs` = sum(as.integer(support_ids))) %>% rename(Region = region)
      resTotal <- foo$filters %>% filter(id == input$checkboxes2[1]) %>% inner_join(filterData(), by = "person_id") %>% mutate(Region = 'All') %>% mutate(target=1, support_ids = case_when(support_int %in% c(1,2) ~ 1, !support_int %in% c(3,4,5,6) ~ 0),  support_ids = tidyr::replace_na(support_ids,0)) %>% select(Region, target, turnout_current, current_support_raw, support_ids) %>%
        group_by(Region) %>% summarise(`Total Targets` = sum(as.integer(target)), `Average Turnout` = mean(turnout_current), `Average Support` = mean(turnout_current), `Current Support IDs` = sum(as.integer(support_ids)))
      rbind(res1,resTotal)
    }
  },  striped = TRUE, bordered = TRUE,  hover = TRUE, width = "auto", align = 'c')

  output$view2 <- renderTable({
    if (is.null(input$checkboxes2[2])) {
      paste("No Selection")
    } else {
      res1 <- foo$filters %>% filter(id == input$checkboxes2[2]) %>% inner_join(filterData(), by = "person_id") %>% mutate(target=1, support_ids = case_when(support_int %in% c(1,2) ~ 1, !support_int %in% c(3,4,5,6) ~ 0),  support_ids = tidyr::replace_na(support_ids,0)) %>% select(region, target, turnout_current, current_support_raw, support_ids) %>%
        group_by(region) %>% summarise(`Total Targets` = sum(as.integer(target)), `Average Turnout` = mean(turnout_current), `Average Support` = mean(turnout_current), `Current Support IDs` = sum(as.integer(support_ids))) %>% rename(Region = region)
      resTotal <- foo$filters %>% filter(id == input$checkboxes2[2]) %>% inner_join(filterData(), by = "person_id") %>% mutate(Region = 'All') %>% mutate(target=1, support_ids = case_when(support_int %in% c(1,2) ~ 1, !support_int %in% c(3,4,5,6) ~ 0),  support_ids = tidyr::replace_na(support_ids,0)) %>% select(Region, target, turnout_current, current_support_raw, support_ids) %>%
        group_by(Region) %>% summarise(`Total Targets` = sum(as.integer(target)), `Average Turnout` = mean(turnout_current), `Average Support` = mean(turnout_current), `Current Support IDs` = sum(as.integer(support_ids)))
      rbind(res1,resTotal)
    }
  },  striped = TRUE, bordered = TRUE,  hover = TRUE, width = "auto", align = 'c')

  output$view3 <- renderTable({
    if (is.null(input$checkboxes2[3])) {
      paste("No Selection")
    } else {
      res1 <- foo$filters %>% filter(id == input$checkboxes2[3]) %>% inner_join(filterData(), by = "person_id") %>% mutate(target=1, support_ids = case_when(support_int %in% c(1,2) ~ 1, !support_int %in% c(3,4,5,6) ~ 0),  support_ids = tidyr::replace_na(support_ids,0)) %>% select(region, target, turnout_current, current_support_raw, support_ids) %>%
        group_by(region) %>% summarise(`Total Targets` = sum(as.integer(target)), `Average Turnout` = mean(turnout_current), `Average Support` = mean(turnout_current), `Current Support IDs` = sum(as.integer(support_ids))) %>% rename(Region = region)
      resTotal <- foo$filters %>% filter(id == input$checkboxes2[3]) %>% inner_join(filterData(), by = "person_id") %>% mutate(Region = 'All') %>% mutate(target=1, support_ids = case_when(support_int %in% c(1,2) ~ 1, !support_int %in% c(3,4,5,6) ~ 0),  support_ids = tidyr::replace_na(support_ids,0)) %>% select(Region, target, turnout_current, current_support_raw, support_ids) %>%
        group_by(Region) %>% summarise(`Total Targets` = sum(as.integer(target)), `Average Turnout` = mean(turnout_current), `Average Support` = mean(turnout_current), `Current Support IDs` = sum(as.integer(support_ids)))
      rbind(res1,resTotal)
    }
  },  striped = TRUE, bordered = TRUE,  hover = TRUE, width = "auto", align = 'c')

  output$view4 <- renderTable({
    if (is.null(input$checkboxes2[4])) {
      paste("No Selection")
    } else {
      res1 <- foo$filters %>% filter(id == input$checkboxes2[4]) %>% inner_join(filterData(), by = "person_id") %>% mutate(target=1, support_ids = case_when(support_int %in% c(1,2) ~ 1, !support_int %in% c(3,4,5,6) ~ 0),  support_ids = tidyr::replace_na(support_ids,0)) %>% select(region, target, turnout_current, current_support_raw, support_ids) %>%
        group_by(region) %>% summarise(`Total Targets` = sum(as.integer(target)), `Average Turnout` = mean(turnout_current), `Average Support` = mean(turnout_current), `Current Support IDs` = sum(as.integer(support_ids))) %>% rename(Region = region)
      resTotal <- foo$filters %>% filter(id == input$checkboxes2[4]) %>% inner_join(filterData(), by = "person_id") %>% mutate(Region = 'All') %>% mutate(target=1, support_ids = case_when(support_int %in% c(1,2) ~ 1, !support_int %in% c(3,4,5,6) ~ 0),  support_ids = tidyr::replace_na(support_ids,0)) %>% select(Region, target, turnout_current, current_support_raw, support_ids) %>%
        group_by(Region) %>% summarise(`Total Targets` = sum(as.integer(target)), `Average Turnout` = mean(turnout_current), `Average Support` = mean(turnout_current), `Current Support IDs` = sum(as.integer(support_ids)))
      rbind(res1,resTotal)
    }
  },  striped = TRUE, bordered = TRUE,  hover = TRUE, width = "auto", align = 'c')

  output$pvt <- renderPivottabler({
    pt <- PivotTable$new()
    pt$addData(addedToList())
    pt$addColumnDataGroups("age_bucket")
    pt$addRowDataGroups("max_threshold")
    pt$defineCalculation(calculationName="All", summariseExpression="n()")
    pt$renderPivot()
  })

  output$heatmap <- renderHighchart({
    res <- addedToList() %>% mutate(n = 1) %>% group_by(target_categories) %>% summarise(total=sum(n))

    hchart(res, "treemap", hcaes(x = target_categories, value = total))

  })

  output$supportdist <- renderHighchart({
    res <- addedToList() %>% select(current_support_raw)

    hchart(density(res$current_support_raw), type = "area", color = "#B71C1C", name = "Support Score")

  })

  output$turnoutdist <- renderHighchart({
    res <- addedToList() %>% select(turnout_current)

    hchart(density(res$turnout_current), type = "area", color = "#B71C1C", name = "Turnout Score")

  })

  output$donut_breakdown <- renderHighchart({
    res <- addedToList() %>% select(donut_segment)
    hchart(res$donut_segment, type = "pie", color = "#B71C1C", name = "Donut Segment")
  })

  output$contact_breakdown <- renderHighchart({
    res <- addedToList() %>% select(region, contact_made) %>% mutate(n=1) %>% group_by(region) %>% summarise(contact = sum(contact_made), targets = sum(n)) %>% mutate(contact_rate = round(contact/targets,3)*100, no_contact = 100 - contact_rate)

    plot_ly(res, x = ~region, y = ~contact_rate, type = 'bar', name = 'Contact Made') %>%
      add_trace(y = ~no_contact, name = 'No Contact') %>%
      layout(yaxis = list(title = 'Contact Rates'), xaxis = list(title = 'Region'), barmode = 'group')

  })

  output$pivotUniverse <- rpivotTable::renderRpivotTable({

    res <- addedToList() %>% select(age_bucket,ethnicity,gender,income,college_status,donut_segment,county,region,turf,precinct,max_threshold,current_support_raw,turnout_current,biden_support,buttigieg_support,warren_support,yang_support) %>%
      rename("Age Bucket" = "age_bucket",
             "Ethnicity" = "ethnicity",
             "Gender" = "gender",
             "Income" = "income",
             "College Status"="college_status",
             "Donut Segment"="donut_segment",
             "County" = "county",
             "Region" = "region",
             "Turf" = "turf",
             "Precinct" = "precinct",
             "Threshold"="max_threshold",
             "Support Score" = "current_support_raw",
             "Turnout Score" = "turnout_current",
             "Biden Score" = "biden_support",
             "Buttigieg Score" = "buttigieg_support",
             "Warren Score" = "warren_support",
             "Yang Score" = "yang_support")
    rpivotTable(data = res)
  })

  output$download <- downloadHandler(
    filename = function() {
      paste(input$name, "_", today, ".csv", sep="")
    },
    content = function(file) {
      write.csv(addedToList() %>%
                  dplyr::select(person_id) %>% distinct_all(), file, row.names = FALSE)
    }
  )

  observeEvent(input$reset, {
    shinyjs::reset("input-panel")
  })


}
