shinyUI(fluidPage(theme='./www/custom.css',
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
  fluidRow(
    textOutput('counttext'),
    htmlOutput('googlechart'),
    dataTableOutput('data'),
    tags$style(type="text/css", '#data tfoot {display: table-header-group;}'),
    tags$br(),
    tags$span(tags$a(href='http://www.morph.io/petrbouchal/GovJobsCZ','Data'),
              ' | ',
              tags$a(href='http://www.github.com/petrbouchal/GovJobsCZ','Kód'))
  )
))
