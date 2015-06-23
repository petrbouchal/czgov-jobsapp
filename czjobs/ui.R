require(rCharts)
# options(RCHART_LIB = 'uvcharts')
shinyUI(fluidPage(
    includeCSS('./www/custom.css'),
    tags$head(
      includeScript('./analytics-code.js')),
  fluidRow(
    textOutput('counttext'),
#     htmlOutput('googlechart'),
    showOutput('rchart','highcharts'),
    DT::dataTableOutput('data'),
    tags$style(type="text/css", '#data tfoot {display: table-header-group;}'),
    tags$br(),
    tags$span(tags$a(href='http://www.morph.io/petrbouchal/GovJobsCZ','Data'),
              ' | ',
              tags$a(href='http://www.github.com/petrbouchal/GovJobsCZ','Kód'))
  )
))
