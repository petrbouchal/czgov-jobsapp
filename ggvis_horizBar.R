# SOURCE: https://groups.google.com/forum/#!topic/ggvis/st77SgwRWKk = horizontal bar chart workaround
# AND http://rpackages.ianhowson.com/cran/ggvis/man/compute_stack.html = stacking

library(dplyr)
library(ggvis)

cocaine %>%
  mutate(month = as.factor(month)) %>%
  group_by(state, month) %>%
  summarize(count = n()) %>%
  group_by(state) %>%
  mutate(total=sum(count)) %>%
  ungroup() %>%
  arrange(total) %>%
  group_by(state, month) %>%
  ggvis(x = ~count, x2 = 0, y = ~state, height = band(), fill=~month) %>%
  compute_stack(stack_var=~count,group_var = ~state) %>%
  layer_rects(x = ~stack_upr_,
              x2 = ~stack_lwr_) %>%
  scale_numeric("x", expand = 0) %>%
  scale_nominal('y',reverse = TRUE)


cc <- cocaine %>%
  mutate(month = as.factor(month)) %>%
  group_by(state, month) %>%
  summarize(count = n())

# mtcars %>% ggvis(x = ~cyl, y = ~wt) %>%
#   compute_stack(stack_var = ~wt, group_var = ~cyl) %>%
#   layer_rects(x = ~cyl - 0.5, x2 = ~cyl + 0.5, y = ~stack_upr_,
#               y2 = ~stack_lwr_)
