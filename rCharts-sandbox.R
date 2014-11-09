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
hh$plotOptions(bar = list(stacking = "normal"))
hh$xAxis(tickLength=0,type='category')
hh$yAxis(tickLength=0,title=NA)
hh$legend(enabled=FALSE)
hh$chart(width='100%')
hh$params$width='100%'
hh$params$height=400
hh


