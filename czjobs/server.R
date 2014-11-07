## Query: select '<a href=''' || joburl || ''' target=''_blank''>' || jobtitle || '</a>' as Pozice, dept as Organizace, seenfor, live, latest from 'data' where live = 1 order by Organizace
## Query w/out <a> etc: select joburl,jobtitle, dept as Organizace, seenfor, live, latest from 'data' where live = 1 order by Organizace
## Date query: select max(lastseen) as date from data

library(plyr)
library(dplyr)
library(rCharts)
library(RCurl)
library(jsonlite)
# library(googleVis)

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
data$Pozice <- paste0('<a href=\"',data$joburl,' target=\"_blank\">',data$jobtitle,'</a>')

data2 <- data %>% group_by(zkratka) %>% summarise(pozic=n()) %>% arrange(-pozic)
tabledata <- select(data, Pozice, Organizace=fullnazev, seenfor) %>% arrange(seenfor)

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

  output$rchart <- renderChart2({
    rch <- uPlot('zkratka','pozic', data=data2, type='StackedBar')
#     rch <- uPlot('zkratka','pozic', data=data2, type='StackedBar', group='seenfor')
    rch$params$width <- 800
    rch$params$height <- 400
    rch$params$margin <- 0
    rch$config(dimension = list(width=800, height=350))
    rch$config(margin = list(top=20, bottom=20, left=60, right=20))
    rch$config(graph = list(custompalette = c('#999999','#000000')))
    rch$config(bar = list(textcolor = '#ffffff'))
    rch$config(axis = list(showticks = FALSE, showsubticks=FALSE,
                           opacity=1, showtext=TRUE))
    return(rch)
  })
})
