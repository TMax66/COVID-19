library(tidyverse)
library(here)
library(readxl)
library(rpivotTable)
library


dtBT <- read_excel(here("SVILUPPO","datilab.xlsx"), sheet = "BT")

dtBT$n.esami <- rnorm(dim(dtBT)[1], 200, 50)

rpivotTable(dtBT)
