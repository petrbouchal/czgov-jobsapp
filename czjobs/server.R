## Query: select '<a href=''' || joburl || ''' target=''_blank''>' || jobtitle || '</a>' as Pozice, dept as Organizace, seenfor, live, latest from 'data' where live = 1 order by Organizace
## Query w/out <a> etc: select joburl,jobtitle, dept as Organizace, seenfor, live, latest from 'data' where live = 1 order by Organizace
## Date query: select max(lastseen) as date from data

library(plyr)
library(dplyr)
library(ggvis)
library(RCurl)
library(jsonlite)

url_data <- 'https://api.morph.io/petrbouchal/czgov-jobs-test/data.json?key=N4S7F3oGM4jPyicp%2B2mx&query=select%20joburl%2Cjobtitle%2C%20dept%20as%20Organizace%2C%20seenfor%2C%20live%2C%20latest%20from%20%27data%27%20where%20live%20%3D%201%20order%20by%20seenfor'
url_date <- 'https://api.morph.io/petrbouchal/czgov-jobs-test/data.json?key=N4S7F3oGM4jPyicp%2B2mx&query=select%20max(lastseen)%20as%20date%20from%20data'
url_allorgs <- 'https://api.morph.io/petrbouchal/czgov-jobs-test/data.json?key=N4S7F3oGM4jPyicp%2B2mx&query=select%20count(distinct(dept))%20as%20alldeptcount%20from%20%27data%27'
tmpFile <- tempfile()
tmpFile <- getURL(url_data,.opts = list(ssl.verifypeer = FALSE))
data <- fromJSON(tmpFile)
tmpFile2 <- tempfile()
tmpFile2 <- getURL(url_date,.opts = list(ssl.verifypeer = FALSE))
tmpFile3 <- tempfile()
tmpFile3 <- getURL(url_allorgs,.opts = list(ssl.verifypeer = FALSE))
date <- fromJSON(tmpFile2)
alldeptcount <- fromJSON(tmpFile3)[1,1]
datum <- strptime(date$date, '%Y-%m-%d')
datum <- strftime(date$date, '%d.%m.%Y')
deptcount <- length(unique(data$Organizace))
jobcount <- length(unique(data$joburl))

load('./names.dta')
data <- merge(data,names,all.x=TRUE)
data$Pozice <- paste0('<a href=\"',data$joburl,'\" target=\"_blank\">',data$jobtitle,'</a>')

tabledata <- select(data, Pozice, Organizace=fullnazev, Stáří=seenfor) %>% arrange(Stáří)

shinyServer(function(input, output) {
  output$counttext <- renderText(paste0(' Nalezeno ',jobcount,' nabídek od ',
                                        deptcount,
                                        ' organizací. Naposledy zkontrolováno ',
                                        datum,'. Sledujeme ', alldeptcount,
                                        ' organizací.'))

  output$data <- renderDataTable(tabledata,options = list(lengthChange=F,
                                                     language=list(
                                                       "paginate"=list("next"="další",
                                                                       "previous"="předchozí"),
                                                       "infoEmpty"="Nic nenalezeno",
                                                       "zeroRecords"="Hledání neodpovídá žádná pozice",
                                                       "info"="Pozice _START_ až _END_ z _TOTAL_",
                                                       "infoFiltered"=" (celkem _MAX_)"),
                                                     pageLength=10,
                                                     dom="<<t>pi>",
                                                     searching=T,
                                                     columns=list(list('width'='70%', 'title'='Pozice'),
                                                                  list('width'='20%', 'title'='Organizace'),
                                                                  list('width'='10%', 'title'='Stáří (dny)'))))
  tooltip <- function(data) {
    paste0("<div>Úřad: ", data$zkratka,
           "<br />Nabídky vyvěšené před ", data$seenfor," dny",
           "<br />", data$stack_upr_ - data$stack_lwr_," nabídek</div>")
  }

#   Blue = colorRampPalette(c(rgb(0,136/255,204/255),"lightgrey"))
  Blue = colorRampPalette(c("blue","lightgrey"))

  data %>%
    mutate(zkratka = as.character(zkratka)) %>%
    group_by(zkratka, seenfor) %>%
    summarise(pozic=n()) %>%
    group_by(zkratka) %>% mutate(total=sum(pozic)) %>%
    arrange(-seenfor) %>%
    ungroup() %>%
    arrange(-total) %>%
    group_by(zkratka) %>%
    ggvis(x = ~pozic, x2 = 0, y = ~zkratka, height = band(), stroke:=NA, fill=~seenfor) %>%
    compute_stack(stack_var=~pozic, group_var = ~zkratka) %>%
    layer_rects(x = ~stack_upr_, x2 = ~stack_lwr_) %>%
    add_tooltip(tooltip) %>%
    scale_numeric("x", expand = 0) %>%
#     scale_numeric('fill', range=Blue(length(unique(data2$seenfor)))) %>%
    hide_legend('fill') %>%
    scale_nominal('y',sort = FALSE) %>%
    add_axis('x',
             properties = axis_props(
               ticks = list(stroke = NA),
               majorTicks = list(strokeWidth = 0),
               grid = list(stroke = 'lightgrey'),
               labels = list(
                 fill = "lightgrey",
                 fontSize = 10,
                 align = "middle",
                 baseline = "middle"
               ),
               axis = list(stroke = NA, strokeWidth = 0)
             )) %>%
    add_axis('y',title = "",
             properties = axis_props(
               ticks = list(stroke = NA),
               majorTicks = list(strokeWidth = 0),
               grid = list(stroke = NA),
               labels = list(
                 fill = "#08c",
                 fontSize = 12,
                 align = "right",
                 baseline = "right"
               ),
               axis = list(stroke = NA, strokeWidth = 0))) %>%
    set_options(height=400, width=800) %>%
    bind_shiny('graf')
})
