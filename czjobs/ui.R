require(ggplot2)
shinyUI(fluidPage(
    includeCSS('./www/custom.css'),
    tags$head(
      includeScript('./analytics-code.js')),
  fluidRow(
    textOutput('counttext'),
#     htmlOutput('googlechart'),
    column(width=4,  
      plotOutput('chart', 
                 click = "plot_click",
                 dblclick = dblclickOpts(
                   id = "plot_dblclick"
                 ),
                 hover = hoverOpts(
                   id = "plot_hover"
                 ),
                 brush = brushOpts(
                   id = "plot_brush",
                   direction = "y"))),
      # actionLink("resetchart","Zobrazit všechny")),
  column(width=8,
    DT::dataTableOutput('data'),
    tags$style(type="text/css", '#data tfoot {display: table-header-group;}'),
    tags$br(),
    tags$span(tags$a(href='http://www.morph.io/petrbouchal/GovJobsCZ','Data'),
              ' | ',
              tags$a(href='http://www.github.com/petrbouchal/GovJobsCZ','Kód'))
  ))
))
