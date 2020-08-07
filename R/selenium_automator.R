##This was used during my time at Burrow to help automate reporting for our legacy logistics platform

library(rvest)
library(RSelenium)
library(dplyr)

#' Return "OK"
#* @get /health
healthCheckAPI <- function(){
  "OK"
}

#' Return "OK"
#* @get /klaussner
klaussnerShippingAPI <- function(res){
  browserpreference <- "chrome"
  eCaps <- list(chromeOptions = list(
    args = c('--no-sandbox', '--headless', '--disable-gpu', '--window-size=1280,800')
  ))
  tryCatch({rD <- rsDriver(port = 4444L, browser = paste0(browserpreference), extraCapabilities = eCaps)}
           ,error=function(rD,remDr){
             try(remDr$close(), silent=T)
             try(rD$server$stop(),silent=T)
             try(suppressWarnings(rm(rD, envir = .GlobalEnv)), silent=T)
             try(suppressWarnings(rm(remDr, envir = .GlobalEnv)), silent=T)
             gc()
             rD <- rsDriver(port = 4444L, browser = paste0(browserpreference))
           })
  
  # Invoiced Orders -------------------------------------------------------------
  
  remDr <- remoteDriver(port = 4444L, browser = paste0(browserpreference), extraCapabilities = eCaps)
  remDr$open()
  remDr$navigate("http://hidden/from/public.com")
  username <- remDr$findElement(using = "name", value = "ctl00$MainContent$Login1$UserName")
  username$sendKeysToElement(list("xxx"))
  
  password <- remDr$findElement(using = "name", value = "ctl00$MainContent$Login1$Password")
  password$sendKeysToElement(list("xxx"))
  
  login <- remDr$findElement(using = "name",value = "ctl00$MainContent$Login1$LoginButton")
  login$clickElement()
  
  customer <- remDr$findElement(using = "name",value = "CustomerNumberList")
  customer$clickElement()
  
  customer_option <- remDr$findElement(using = 'xpath', "//*/option[@value = '103025']")
  customer_option$clickElement()
  
  status <- remDr$findElement(using = "name",value = "StatusCode")
  status$clickElement()
  
  status_option <- remDr$findElement(using = 'xpath', "//*/option[@value = 'INVOICED']")
  status_option$clickElement()
  
  format <- remDr$findElement(using = "name",value = "OutputFormat")
  format$clickElement()
  
  format_status <- remDr$findElement(using = 'xpath', "//*/option[@value = 'Excel']")
  format_status$clickElement()
  
  submit <- remDr$findElement(using = "id",value = "SubmitButton")
  submit$clickElement()
  
  Sys.sleep(200)
  
  df <- file.info(list.files("./downloads", full.names = T))
  klassuner_find <- rownames(df)[which.max(df$mtime)]
  
  klaussner <- readxl::read_xlsx(klassuner_find)
  
  klaussner_select <- klaussner %>%
    select(1,2,3,5,7,8,23,24)
  
  colnames(klaussner_select) <- c("order_number","order_status","customer_po","order_entry_date","pickup_date","pickup_status", "invoice_date", "invoice_number")
  
  klaussner_select$order_entry_date <- as.character(as.Date(klaussner_select$order_entry_date, format = "%Y%m%d"))
  klaussner_select$pickup_date <- as.character(as.Date(klaussner_select$pickup_date, format = "%Y%m%d"))
  klaussner_select$invoice_date <- as.character(as.Date(klaussner_select$invoice_date, format = "%Y%m%d"))
  klaussner_select$order_number <- as.character(klaussner_select$order_number)
  klaussner_select$customer_po <- as.character(klaussner_select$customer_po)
  klaussner_select$invoice_number<- as.character(klaussner_select$invoice_number)
  
  print(paste0(klaussner_select))
  
  klaussner_select_csv <- write.csv(klaussner_select, "klaussner_invoiced.csv", row.names = FALSE)
  klaussner_select_txt <- write.table(klaussner_select, "klaussner_invoiced.txt", row.names = FALSE)
  
  fileNames <- list.files(path = './downloads')
  index <- which(Sys.time() - file.info(fileNames)$ctime > 10)
  fileNames[index]
  
  # Open Orders -------------------------------------------------------------
  
  remDr <- remoteDriver(port = 4444L, browser = paste0(browserpreference), extraCapabilities = eCaps)
  remDr$open()
  remDr$navigate("http://servicenet.klaussner.com/Login.aspx?ReturnUrl=%2fOrdersAndDelivery%2fOrderStatus.aspx")
  username <- remDr$findElement(using = "name", value = "ctl00$MainContent$Login1$UserName")
  username$sendKeysToElement(list("katy"))
  
  password <- remDr$findElement(using = "name", value = "ctl00$MainContent$Login1$Password")
  password$sendKeysToElement(list("katy"))
  
  login <- remDr$findElement(using = "name",value = "ctl00$MainContent$Login1$LoginButton")
  login$clickElement()
  
  customer <- remDr$findElement(using = "name",value = "CustomerNumberList")
  customer$clickElement()
  
  customer_option <- remDr$findElement(using = 'xpath', "//*/option[@value = '103025']")
  customer_option$clickElement()
  
  status <- remDr$findElement(using = "name",value = "StatusCode")
  status$clickElement()
  
  status_option <- remDr$findElement(using = 'xpath', "//*/option[@value = 'OPEN']")
  status_option$clickElement()
  
  format <- remDr$findElement(using = "name",value = "OutputFormat")
  format$clickElement()
  
  format_status <- remDr$findElement(using = 'xpath', "//*/option[@value = 'Excel']")
  format_status$clickElement()
  
  submit <- remDr$findElement(using = "id",value = "SubmitButton")
  submit$clickElement()
  
  Sys.sleep(200)
  
  df_open_select <- file.info(list.files("./downloads", full.names = T))
  klassuner_find_open <- rownames(df_open_select)[which.max(df_open_select$mtime)]
  
  klaussner_open <- readxl::read_xlsx(klassuner_find_open)
  
  klaussner_select_open <- klaussner_open %>%
    select(1,2,3,5,7)
  
  colnames(klaussner_select_open) <- c("order_number","order_status","customer_po","order_entry_date","pickup_date")
  
  klaussner_select_open$order_entry_date <- as.Date(klaussner_select_open$order_entry_date, format = "%Y%m%d")
  klaussner_select_open$pickup_date <- as.Date(klaussner_select_open$pickup_date, format = "%Y%m%d")
  klaussner_select_open$order_number <- as.character(klaussner_select_open$order_number)
  klaussner_select_open$customer_po <- as.character(klaussner_select_open$customer_po)
  
  klaussner_open_csv <- write.csv(klaussner_select_open, "klaussner_open.csv", row.names = FALSE)
  
  res$body <- "Check"
  res
}
