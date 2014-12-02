require(ggvis)
shinyUI(fluidPage(theme='custom.css',
  tags$head(
#     tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
    includeScript('analytics-code.js')),
  fluidRow(
    textOutput('counttext'),
#     htmlOutput('googlechart'),
    ggvisOutput('graf'),
    dataTableOutput('data'),
    tags$style(type="text/css", '#data tfoot {display: table-header-group;}'),
    tags$br(),
    tags$span(tags$a(href='http://www.morph.io/petrbouchal/GovJobsCZ','Data'),
              ' | ',
              tags$a(href='http://www.github.com/petrbouchal/GovJobsCZ','Kód'))
  )
))
