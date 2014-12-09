p3 <- uPlot('carb', 'wt', data = mtcars, type='StackedBar')
# p3$xAxis(type = "addMeasureAxis")
# p3$yAxis(type = "addCategoryAxis", orderRule='-Order')
# p3$legend(
#   x = 200,
#   y = 10,
#   width = 400,
#   height = 20,
#   horizontalAlign = "right"
# )
# p3$params$width <- 400
# p3$params$height <- 800
p3$params$config$dimension$width <- 800
p3$params$config$dimension$height <- 600
# p3$params$config$margin <- 0

p3

cocaine2 <- cocaine %>%
  group_by(state, month) %>%
  summarise_each(funs = 'sum') %>%
  arrange(price)

hh <- hPlot(data=cocaine2, y='price',x='state', type='bar', group='month', stacking='normal')
hh$plotOptions(bar = list(stacking = "normal",borderColor=NA))
hh$xAxis(tickLength=0,type='category')
hh$yAxis(tickLength=0,title=NA)
hh$legend(enabled=FALSE)
hh$params$width='100%'
hh$params$height=800
hh

rr <- rPlot(price ~ state, data=cocaine2, type='bar',color='month')
rr$params$coord=list(flip='true')
rr

dd <- dPlot(state ~ price, type='bar', groups='month', data=cocaine2)
dd$xAxis(type = "addMeasureAxis")
#good test of orderRule on y instead of x
dd$yAxis(type = "addCategoryAxis", orderRule='price')
dd$legend(
  x = 200,
  y = 10,
  width = 400,
  height = 20,
  horizontalAlign = "right"
)
dd$templates$afterScript = "<script> var yAxis = myChart.axes.filter(function(axis){return axis.position==='y'})[0]; yAxis.gridlineShape.remove() </script>"
dd


# following adapted from https://gist.github.com/reinholdsson/5842467
require(rCharts)

df <- data.frame(
  name = c("MPO", "MPO","MPO", "MMR", "MMR","MMR"),
  count = sample(1:4, 6, replace = T),
  date = c(sample(1:4,3, replace=FALSE),
           sample(1:4,3, replace=FALSE))
)

df$date = paste(df$date, ' days')

require(tidyr)
gg <- spread(df, key=date, value=count, fill=0)
df2 <- gather(gg, date, count, -name)

a <- rCharts:::Highcharts$new()

a$chart(type = "bar")
a$plotOptions(bar = list(stacking = "normal"))
a$xAxis(categories = levels(df$name))

invisible(sapply(unique(df2$date), function(sername){
  d <- df2[df2$date == sername, ]
  a$series(name = sername, data = d$count, stack = d$name[[1]])
}))
a

# https://github.com/ramnathv/rCharts/issues/201 :

df <- data.frame(
  name = c("MPO", "MPO","MPO", "MMR", "MMR","MMR"),
  count = sample(1:4, 6, replace = T),
  date = c(sample(1:4,3, replace=FALSE),
           sample(1:4,3, replace=FALSE))
)
df$date = paste(df$date, ' days')

n1 <- nPlot(count ~ date, group = 'name', data = df, type = 'multiBarHorizontal')
n1$chart(stacked = TRUE, forceY = 10)
# n1$params$width=400
n1

