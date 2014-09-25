## Query: select '<a href=''' || joburl || ''' target=''_blank''>' || jobtitle || '</a>' as Pozice, dept as Ministerstvo from 'data' where datetime = (select max(datetime) from data) order by Ministerstvo
## Date query: select max(datetime) as date from data

library(RCurl)
library(jsonlite)
library(dplyr)
library(googleVis)

url_data <- 'https://api.morph.io/petrbouchal/GovJobsCZ/data.json?key=N4S7F3oGM4jPyicp%2B2mx&query=select%20%27%3Ca%20href%3D%27%27%27%20%7C%7C%20joburl%20%7C%7C%20%27%27%27%20target%3D%27%27_blank%27%27%3E%27%20%7C%7C%20jobtitle%20%7C%7C%20%27%3C%2Fa%3E%27%20as%20Pozice%2C%20dept%20as%20Ministerstvo%20from%20%27data%27%20where%20datetime%20%3D%20(select%20max(datetime)%20from%20data)%20order%20by%20Ministerstvo%20'
url_date <- 'https://api.morph.io/petrbouchal/GovJobsCZ/data.json?key=N4S7F3oGM4jPyicp%2B2mx&query=select%20max(datetime)%20as%20date%20from%20data'
tmpFile <- tempfile()
tmpFile <- getURL(url_data)
#     download.file(url_data, destfile = tmpFile)
data <- fromJSON(tmpFile)
tmpFile2 <- tempfile()
tmpFile2 <- getURL(url_date)
date <- fromJSON(tmpFile2)
datum <- strptime(date$date, '%Y-%m-%d')
datum <- strftime(date$date, '%d.%m.%Y')
deptcount <- length(unique(data$Ministerstvo))
jobcount <- length(unique(data$Pozice))

gcoptions = list(width = '100%',
                 height = 320,
                 bar = '{groupWidth: \"85%\"}',
                 colors="['red']",
                 legend = list(position = "none"),
                 titlePosition = 'none',
                 chartArea = '{left: 60, top: 25, height: \'85%\'}',
                 axisTitlesPosition = 'none',
                 theme = 'maximized',
                 vAxis = '{textStyle: {color: \'red\', bold: false,
                           fontFace: \'Source Sans Pro\'},
                           textPosition: \'out\'}')

data2 <- data %>% group_by(Ministerstvo) %>% summarise(pozic=n()) %>% arrange(-pozic)

shinyServer(function(input, output) {
  output$counttext <- renderText(paste0(' Nalezeno ',jobcount,' nabídek od ',
                                        deptcount,' úřadů. Naposledy zkontrolováno ', datum,'.'))
  output$data <- renderDataTable(data,options = list(lengthChange=F,
                                                     language.search='Hledat',
                                                     pageLength=10,
                                                     dom="<<t>pi>",
                                                     searching=T,
                                                     columns=list(list('width'='90%'),list('width'='10%'))))
  output$googlechart <- renderGvis((gvisBarChart(data2,'Ministerstvo','pozic',
                                                 options=gcoptions)))
})
