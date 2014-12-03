library(ggvis)
shinyUI(fluidPage(theme='custom.css',
  tags$head(
    includeScript('analytics-code-test.js'),
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
  fluidRow(
    textOutput('counttext'),
    tags$div(style="max-width:800px; height:400px;",
             ggvisOutput('graf')),
    dataTableOutput('data'),
    tags$style(type="text/css", '#data tfoot {display: table-header-group;}'),
    tags$br(),
    tags$span(tags$a(href='http://www.morph.io/petrbouchal/GovJobsCZ','Data'),
              ' | ',
              tags$a(href='http://www.github.com/petrbouchal/GovJobsCZ','Kód'))
  )
))
