# Minimalistic Sales Dashboard - R Shiny

# Install necessary packages if not already installed
# install.packages(c("shiny", "shinydashboard", "DT", "plotly", "dplyr", "readr", "lubridate", "scales", "shinyWidgets"))

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(dplyr)
library(readr)
library(lubridate)
library(scales)
library(shinyWidgets)

# Load and process data
load_data <- function() {
  tryCatch({
    data <- read_csv("https://raw.githubusercontent.com/Kianoush-h/Analysis-of-Sales-Data/master/data/sales_data_sample.csv", 
                     show_col_types = FALSE)
    
    data <- data %>%
      mutate(
        ORDERDATE = as.Date(ORDERDATE, format = "%m/%d/%Y"),
        MONTH = month(ORDERDATE, label = TRUE),
        YEAR = year(ORDERDATE),
        QUARTER = paste0("Q", quarter(ORDERDATE)),
        PROFIT_MARGIN = round((SALES - SALES * 0.7) / SALES * 100, 1),
        ORDER_SIZE = ifelse(QUANTITYORDERED <= 30, "Small", 
                            ifelse(QUANTITYORDERED <= 50, "Medium", "Large"))
      ) %>%
      filter(!is.na(SALES), !is.na(ORDERDATE))
    
    return(data)
  }, error = function(e) {
    set.seed(123)
    data.frame(
      ORDERNUMBER = 1:200,
      ORDERDATE = sample(seq(as.Date("2023-01-01"), as.Date("2024-12-31"), by = "day"), 200),
      SALES = round(runif(200, 1000, 15000), 2),
      QUANTITYORDERED = sample(10:100, 200, replace = TRUE),
      COUNTRY = sample(c("USA", "France", "Spain", "Australia", "Germany"), 200, replace = TRUE),
      PRODUCTLINE = sample(c("Motorcycles", "Classic Cars", "Trucks", "Vintage Cars", "Planes"), 200, replace = TRUE),
      DEALSIZE = sample(c("Small", "Medium", "Large"), 200, replace = TRUE),
      STATUS = sample(c("Shipped", "Resolved", "Cancelled", "In Process"), 200, replace = TRUE),
      CUSTOMERNAME = paste("Customer", sample(1:50, 200, replace = TRUE)),
      stringsAsFactors = FALSE
    ) %>%
      mutate(
        MONTH = month(ORDERDATE, label = TRUE),
        YEAR = year(ORDERDATE),
        QUARTER = paste0("Q", quarter(ORDERDATE)),
        PROFIT_MARGIN = round(runif(200, 15, 35), 1),
        ORDER_SIZE = ifelse(QUANTITYORDERED <= 30, "Small", 
                            ifelse(QUANTITYORDERED <= 50, "Medium", "Large"))
      )
  })
}

# UI
ui <- dashboardPage(
  dashboardHeader(title = "Sales Dashboard", titleWidth = 200),
  dashboardSidebar(
    width = 200,
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("chart-line")),
      menuItem("Products", tabName = "products", icon = icon("box")),
      menuItem("Geography", tabName = "geography", icon = icon("globe")),
      menuItem("Data", tabName = "table", icon = icon("table"))
    ),
    hr(),
    pickerInput("year_filter", "Select Year(s):", choices = NULL, multiple = TRUE, options = list(`actions-box` = TRUE, `live-search` = TRUE)),
    pickerInput("country_filter", "Select Country:", choices = NULL, multiple = TRUE, options = list(`actions-box` = TRUE, `live-search` = TRUE)),
    pickerInput("product_filter", "Select Product Line:", choices = NULL, multiple = TRUE, options = list(`actions-box` = TRUE, `live-search` = TRUE))
  ),
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper { background-color: #fafafa; }
        .small-box { border-radius: 5px; border: 1px solid #eee; }
        .box { border-radius: 5px; border: 1px solid #ddd; }
        .sidebar-menu > li > a { padding: 10px 15px; font-size: 14px; }
        .picker { font-size: 13px; }
      "))
    ),
    tabItems(
      tabItem("overview",
              fluidRow(
                valueBoxOutput("total_sales", width = 3),
                valueBoxOutput("total_orders", width = 3),
                valueBoxOutput("avg_order_value", width = 3),
                valueBoxOutput("profit_margin", width = 3)
              ),
              fluidRow(
                box(title = "Sales Trend", status = "primary", width = 8,
                    plotlyOutput("sales_trend", height = "300px")),
                box(title = "Order Status", status = "info", width = 4,
                    plotlyOutput("status_pie", height = "300px"))
              ),
              fluidRow(
                box(title = "Monthly Sales", status = "success", width = 6,
                    plotlyOutput("monthly_sales", height = "300px")),
                box(title = "Top Customers", status = "warning", width = 6,
                    plotlyOutput("top_customers", height = "300px"))
              )
      ),
      tabItem("products",
              fluidRow(
                box(title = "Product Performance", status = "primary", width = 8,
                    plotlyOutput("product_performance", height = "400px")),
                box(title = "Deal Size", status = "info", width = 4,
                    plotlyOutput("deal_size_pie", height = "400px"))
              )
      ),
      tabItem("geography",
              fluidRow(
                box(title = "Sales by Country", status = "primary", width = 8,
                    plotlyOutput("country_sales", height = "400px")),
                box(title = "Country Metrics", status = "info", width = 4,
                    DT::dataTableOutput("country_metrics"))
              )
      ),
      tabItem("table",
              fluidRow(
                box(title = "Sales Data", status = "primary", width = 12,
                    DT::dataTableOutput("data_table"))
              )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  sales_data <- reactive({ load_data() })
  
  # Update Filters
  observe({
    data <- sales_data()
    updatePickerInput(session, "year_filter", choices = sort(unique(data$YEAR)), selected = unique(data$YEAR))
    updatePickerInput(session, "country_filter", choices = sort(unique(data$COUNTRY)), selected = unique(data$COUNTRY))
    updatePickerInput(session, "product_filter", choices = sort(unique(data$PRODUCTLINE)), selected = unique(data$PRODUCTLINE))
  })
  
  filtered_data <- reactive({
    data <- sales_data()
    if (!is.null(input$year_filter)) data <- data[data$YEAR %in% input$year_filter, ]
    if (!is.null(input$country_filter)) data <- data[data$COUNTRY %in% input$country_filter, ]
    if (!is.null(input$product_filter)) data <- data[data$PRODUCTLINE %in% input$product_filter, ]
    return(data)
  })
  
  output$total_sales <- renderValueBox({
    valueBox(
      value = paste0("$", format(sum(filtered_data()$SALES, na.rm = TRUE), big.mark = ",")),
      subtitle = "Total Sales", icon = icon("dollar-sign"), color = "blue"
    )
  })
  
  output$total_orders <- renderValueBox({
    valueBox(
      value = format(nrow(filtered_data()), big.mark = ","),
      subtitle = "Total Orders", icon = icon("shopping-cart"), color = "green"
    )
  })
  
  output$avg_order_value <- renderValueBox({
    valueBox(
      value = paste0("$", format(round(mean(filtered_data()$SALES, na.rm = TRUE)), big.mark = ",")),
      subtitle = "Avg Order Value", icon = icon("chart-line"), color = "yellow"
    )
  })
  
  output$profit_margin <- renderValueBox({
    valueBox(
      value = paste0(round(mean(filtered_data()$PROFIT_MARGIN, na.rm = TRUE), 1), "%"),
      subtitle = "Profit Margin", icon = icon("percentage"), color = "red"
    )
  })
  
  output$sales_trend <- renderPlotly({
    data <- filtered_data() %>%
      group_by(ORDERDATE) %>%
      summarise(Sales = sum(SALES, na.rm = TRUE), .groups = 'drop') %>%
      arrange(ORDERDATE)
    
    plot_ly(data, x = ~ORDERDATE, y = ~Sales, type = 'scatter', mode = 'lines+markers',
            line = list(color = '#3498db'), marker = list(color = '#2980b9', size = 4)) %>%
      layout(xaxis = list(title = "Date"), yaxis = list(title = "Sales ($)"))
  })
  
  output$status_pie <- renderPlotly({
    data <- filtered_data() %>% count(STATUS) %>% arrange(desc(n))
    plot_ly(data, labels = ~STATUS, values = ~n, type = 'pie',
            textinfo = 'label+percent', marker = list(colors = c('#3498db', '#2ecc71', '#e74c3c', '#f39c12'))) %>%
      layout(showlegend = FALSE)
  })
  
  output$monthly_sales <- renderPlotly({
    data <- filtered_data() %>%
      group_by(MONTH) %>%
      summarise(Sales = sum(SALES, na.rm = TRUE), .groups = 'drop')
    
    plot_ly(data, x = ~MONTH, y = ~Sales, type = 'bar', marker = list(color = '#2ecc71')) %>%
      layout(xaxis = list(title = "Month"), yaxis = list(title = "Sales ($)"))
  })
  
  output$top_customers <- renderPlotly({
    data <- filtered_data() %>%
      group_by(CUSTOMERNAME) %>%
      summarise(Sales = sum(SALES, na.rm = TRUE), .groups = 'drop') %>%
      top_n(10, Sales) %>%
      arrange(Sales)
    
    plot_ly(data, x = ~Sales, y = ~reorder(CUSTOMERNAME, Sales), type = 'bar', orientation = 'h',
            marker = list(color = '#e74c3c')) %>%
      layout(xaxis = list(title = "Sales ($)"), yaxis = list(title = ""))
  })
  
  output$product_performance <- renderPlotly({
    data <- filtered_data() %>%
      group_by(PRODUCTLINE) %>%
      summarise(Sales = sum(SALES, na.rm = TRUE), Orders = n(), .groups = 'drop') %>%
      arrange(desc(Sales))
    
    plot_ly(data, x = ~reorder(PRODUCTLINE, Sales), y = ~Sales, type = 'bar',
            marker = list(color = '#9b59b6')) %>%
      layout(xaxis = list(title = "Product Line"), yaxis = list(title = "Sales ($)"))
  })
  
  output$deal_size_pie <- renderPlotly({
    data <- filtered_data() %>% count(DEALSIZE) %>% arrange(desc(n))
    plot_ly(data, labels = ~DEALSIZE, values = ~n, type = 'pie',
            textinfo = 'label+percent', marker = list(colors = c('#3498db', '#f39c12', '#e74c3c'))) %>%
      layout(showlegend = FALSE)
  })
  
  output$country_sales <- renderPlotly({
    data <- filtered_data() %>%
      group_by(COUNTRY) %>%
      summarise(Sales = sum(SALES, na.rm = TRUE), .groups = 'drop') %>%
      arrange(Sales)
    
    plot_ly(data, x = ~Sales, y = ~reorder(COUNTRY, Sales), type = 'bar', orientation = 'h',
            marker = list(color = '#1abc9c')) %>%
      layout(xaxis = list(title = "Sales ($)"), yaxis = list(title = ""))
  })
  
  output$country_metrics <- DT::renderDataTable({
    data <- filtered_data() %>%
      group_by(COUNTRY) %>%
      summarise(
        Sales = sum(SALES, na.rm = TRUE),
        Orders = n(),
        Avg_Order = mean(SALES, na.rm = TRUE),
        .groups = 'drop'
      ) %>%
      arrange(desc(Sales)) %>%
      mutate(
        Sales = paste0("$", format(round(Sales), big.mark = ",")),
        Avg_Order = paste0("$", format(round(Avg_Order), big.mark = ","))
      )
    
    DT::datatable(data, options = list(pageLength = 8, dom = 't', scrollX = TRUE),
                  rownames = FALSE,
                  colnames = c("Country", "Sales", "Orders", "Avg Order"))
  })
  
  output$data_table <- DT::renderDataTable({
    data <- sales_data()
    
    # Get only the columns that exist in the dataset
    selected_cols <- intersect(
      c("ORDERNUMBER", "ORDERDATE", "SALES", "QUANTITYORDERED", 
        "COUNTRY", "PRODUCTLINE", "DEALSIZE", "STATUS", "CUSTOMERNAME"),
      names(data)
    )
    
    display_data <- data[, selected_cols, drop = FALSE]
    
    # Format SALES if it exists
    if ("SALES" %in% names(display_data)) {
      display_data$SALES <- paste0("$", format(display_data$SALES, big.mark = ","))
    }
    
    # Format ORDERDATE if it exists
    if ("ORDERDATE" %in% names(display_data)) {
      display_data$ORDERDATE <- as.character(display_data$ORDERDATE)
    }
    
    DT::datatable(display_data, options = list(pageLength = 10))
  })
  
}

# Run the app
shinyApp(ui = ui, server = server)
