# SOURCE: https://groups.google.com/forum/#!topic/ggvis/st77SgwRWKk = horizontal bar chart workaround
# AND http://rpackages.ianhowson.com/cran/ggvis/man/compute_stack.html = stacking

library(dplyr)
library(ggvis)

tooltip <- function(data) {
  paste0("<div style=\'font-family:sans-serif;\'>Month: ", data$month, "<br />State: ", data$state,
          "<br />Count: ", data$stack_upr_ - data$stack_lwr_,'</div>')
}

Blue = colorRampPalette(c("white","red"))
colourscale=Blue(n = 12)

cocaine %>%
  mutate(month = as.factor(month),
         state = as.factor(state)) %>%
  group_by(state, month) %>%
  summarize(count = n()) %>%
  group_by(state) %>%
  mutate(total=sum(count)) %>%
  ungroup() %>%
  arrange(total) %>%
  mutate(state=reorder(state, total, mean)) %>% 
  group_by(state, month) %>%
  ggvis(x = ~count, x2 = 0, y = ~state, height = band(), fill=~month, stroke:=NA) %>%
  compute_stack(stack_var=~count,group_var = ~state) %>%
  layer_rects(x = ~stack_upr_, x2 = ~stack_lwr_) %>%
  add_tooltip(tooltip) %>%
  scale_numeric("x", expand = 0) %>%
  scale_nominal('fill',sort = FALSE, range=colourscale) %>%
#   hide_legend('fill') %>%
  scale_nominal('y',reverse = TRUE)

# mtcars %>% ggvis(x = ~cyl, y = ~wt) %>%
#   compute_stack(stack_var = ~wt, group_var = ~cyl) %>%
#   layer_rects(x = ~cyl - 0.5, x2 = ~cyl + 0.5, y = ~stack_upr_,
#               y2 = ~stack_lwr_)
