# Sales Dashboard - R Shiny Application

A  sales analytics dashboard built with R Shiny that provides interactive visualizations and insights for sales data analysis. The application offers multiple views for examining sales performance across different dimensions including time periods, geographic regions and product lines.

## Live Demo

**Application URL**: [https://farukhasan.shinyapps.io/ShinyUp/](https://farukhasan.shinyapps.io/ShinyUp/)


## Application Screenshot

![Sales Dashboard Landing Page]([screenshot-landing-page.png](https://github.com/farukhasan/shiny-business-sales-BI-dashboard/blob/main/sales_dashboard.png))

## Features

### Dashboard Overview
- **Key Performance Indicators**: Total sales, order count, average order value, and profit margin calculations
- **Sales Trend Analysis**: Time-series visualization showing sales performance over time
- **Order Status Distribution**: Pie chart breakdown of order statuses (Shipped, Resolved, Cancelled, In Process)
- **Monthly Sales Patterns**: Bar chart displaying sales volume by month
- **Top Customer Analysis**: Horizontal bar chart showing highest-revenue customers

### Product Analytics
- **Product Line Performance**: Sales comparison across different product categories
- **Deal Size Distribution**: Visual breakdown of small, medium, and large deals
- **Quantity vs Revenue Analysis**: Relationship between order quantities and sales values

### Geographic Insights
- **Sales by Country**: Country-wise sales performance visualization
- **Regional Metrics Table**: Detailed country statistics including total sales, order counts, and average order values

### Data Management
- **Interactive Data Table**: Complete dataset view with sorting, filtering, and pagination
- **Real-time Filtering**: Dynamic filters for year, country, and product line selection
- **Export Capabilities**: Data table supports standard export functions

## Technical Implementation

### Technology Stack
- **Framework**: R Shiny with shinydashboard
- **Visualization**: Plotly for interactive charts
- **Data Processing**: dplyr for data manipulation
- **UI Components**: shinyWidgets for enhanced input controls
- **Tables**: DT package for interactive data tables

### Data Sources
The application supports two data loading methods:

1. **Primary Data Source**: Sales data from GitHub repository
   - URL: `https://raw.githubusercontent.com/Kianoush-h/Analysis-of-Sales-Data/master/data/sales_data_sample.csv`
   - Contains historical sales transactions with customer, product, and geographic information

2. **Fallback Data**: Synthetic dataset generated when primary source is unavailable
   - Simulates 200 sales records with realistic patterns
   - Includes data from 2023-2024 with various product lines and countries

### Data Schema
The application processes the following key data fields:

- **ORDERNUMBER**: Unique identifier for each sales transaction
- **ORDERDATE**: Transaction date (MM/DD/YYYY format)
- **SALES**: Revenue amount for each order
- **QUANTITYORDERED**: Number of items in each order
- **COUNTRY**: Geographic location of the customer
- **PRODUCTLINE**: Product category (Motorcycles, Classic Cars, Trucks, Vintage Cars, Planes)
- **DEALSIZE**: Order size classification (Small, Medium, Large)
- **STATUS**: Order fulfillment status
- **CUSTOMERNAME**: Customer identification

### Calculated Fields
The application creates additional metrics for analysis:

- **PROFIT_MARGIN**: Calculated as percentage based on sales and estimated costs
- **ORDER_SIZE**: Categorization based on quantity ordered (Small: ≤30, Medium: 31-50, Large: >50)
- **MONTH**: Extracted month names for temporal analysis
- **YEAR**: Extracted year for annual filtering
- **QUARTER**: Quarterly grouping for seasonal analysis

## Installation Requirements

### R Packages
```r
install.packages(c(
  "shiny",
  "shinydashboard", 
  "DT",
  "plotly",
  "dplyr",
  "readr",
  "lubridate",
  "scales",
  "shinyWidgets"
))
```

### System Requirements
- R version 4.0 or higher
- RStudio (recommended for development)
- Web browser with JavaScript enabled
- Internet connection for data loading

## Usage Instructions

### Navigation
The dashboard contains four main sections accessible via the sidebar menu:

1. **Overview**: Primary dashboard with key metrics and trend analysis
2. **Products**: Product-focused analytics and performance metrics
3. **Geography**: Geographic distribution and regional performance
4. **Data**: Complete dataset view with interactive table

### Filtering Options
Three filter controls are available in the sidebar:
- **Year Filter**: Select specific years for analysis
- **Country Filter**: Focus on particular geographic regions  
- **Product Line Filter**: Analyze specific product categories

All filters support multiple selections and include search functionality for easy navigation.

### Interactive Features
- Hover over charts for detailed data points
- Click and drag to zoom in chart areas
- Use filter controls to update all visualizations simultaneously
- Sort and search within data tables
- Export data table contents to various formats

## Performance Considerations

### Data Processing
- Efficient data loading with error handling and fallback options
- Reactive programming ensures updates only when filters change
- Optimized aggregation functions for large datasets

### User Experience
- Responsive design adapts to different screen sizes
- Fast rendering with plotly for smooth interactions
- Minimal loading times through efficient data processing

## Customization Options

### Styling
The application includes custom CSS for:
- Background colors and component styling
- Border radius and spacing adjustments
- Font sizes and menu formatting
- Color schemes for consistent branding

### Data Integration
To use your own data:
1. Replace the CSV URL in the `load_data()` function
2. Ensure column names match the expected schema
3. Adjust data type conversions as needed
4. Update calculated fields based on your business logic

## Future Enhancements

Potential improvements for future versions:
- Additional visualization types (heatmaps, scatter plots)
- Advanced filtering options (date ranges, custom queries)
- Export functionality for charts and reports
- User authentication and role-based access
- Real-time data integration capabilities
- Mobile-responsive design improvements

## Support and Documentation

For technical support or questions about the application:
- Review the source code for implementation details
- Check R package documentation for specific functions
- Refer to Shiny documentation for framework-specific questions


---

*Last updated: July 2025*
