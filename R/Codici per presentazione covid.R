librerie()
library(openxlsx)
dt <- readRDS(here("data", "processed", "covid.rds"))

data.frame( conferente =levels(factor(dt$Conferente))) %>% 
  write.xlsx(file = "conferenti.xlsx")

