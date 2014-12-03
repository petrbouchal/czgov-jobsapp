## Query: select '<a href=''' || joburl || ''' target=''_blank''>' || jobtitle || '</a>' as Pozice, dept as Ministerstvo from 'data' where datetime = (select max(datetime) from data) order by Ministerstvo
## Date query: select max(datetime) as date from data

library(plyr)
library(dplyr)
library(rCharts)
library(RCurl)
library(jsonlite)
# library(googleVis)

url_data <- 'https://api.morph.io/petrbouchal/GovJobsCZ/data.json?key=N4S7F3oGM4jPyicp%2B2mx&query=select%20joburl%2C%20jobtitle%2C%20dept%20as%20Organizace%20from%20%27data%27%20where%20datetime%20%3D%20(select%20max(datetime)%20from%20data)%20order%20by%20Organizace%20'
url_date <- 'https://api.morph.io/petrbouchal/GovJobsCZ/data.json?key=N4S7F3oGM4jPyicp%2B2mx&query=select%20max(datetime)%20as%20date%20from%20data'
url_allorgs <- 'https://api.morph.io/petrbouchal/GovJobsCZ/data.json?key=N4S7F3oGM4jPyicp%2B2mx&query=select%20count(distinct(dept))%20as%20alldeptcount%20from%20%27data%27'
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

data2 <- data %>% group_by(zkratka) %>% summarise(pozic=n()) %>% arrange(-pozic)
tabledata <- select(data, Pozice, Organizace=fullnazev)
jobcount <- nrow(data)

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
                                                     columns=list(list('width'='75%', 'title'='Pozice'),
                                                                  list('width'='25%', 'title'='Organizace'))))
  output$rchart <- renderChart2({
    # This is a workaround to keep the ordering
    # as per https://github.com/ramnathv/rCharts/issues/212
#     rch <- hPlot(x='zkratka',y='pozic', data=data2, type='bar')
    rch <- Highcharts$new()
    rch$params$width <- '100%'
    rch$params$height <- 400
    rch$series(data = data2$pozic, type = "bar", pointWidth=400/deptcount-6,name='Nabídek')
    rch$plotOptions(bar = list(stacking = "normal", borderColor=NA))
    rch$xAxis(tickLength=0,type='category', categories=data2$zkratka)
    rch$yAxis(tickLength=0,title=NA,
              tickPositions=seq(0,ceiling(max(data2$pozic)/10)*10,10))
    rch$legend(enabled=FALSE)
    return(rch)
  })
})
