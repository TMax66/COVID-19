library(shiny)
library(tidyverse)
library(readxl)
library(lubridate)
library(shinythemes)
library(DT)
library(readr)
library(here)
library(DBI)
library(odbc)
library(rpivotTable)
library(shinyjs)
library(shinycssloaders)
library(openxlsx)
library(janitor)
library(zoo)
library(hrbrthemes)



serie2 <- function(regione){  
  covid %>% 
    filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico")) %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(anno == 2021 & Regione == regione) %>% 
    group_by(dtacc) %>% 
    summarise(esami = sum(Tot_Eseguiti, na.rm = T)) %>%  
    filter(esami > 0) %>%
    mutate(sett = rollmean(esami, k = 30, fill = NA) )%>%  
    ggplot(aes(
      x = dtacc, 
      y = sett
    ))+
    geom_line(col = "blue", size = 1.5)+
    # geom_col( aes(y = Tot), 
    #    alpha = 1/5)+
    
    geom_point(aes(x = dtacc, 
                   y = esami), alpha = 1/5)+
    geom_line(aes(x = dtacc, 
                  y = esami), alpha = 1/5)+
    #geom_hline(yintercept = 2729) +
    
    labs(
      y = "Numero Tamponi Naso Faringei", 
      x = "", 
      title =  "Andamento del numero di tamponi naso-faringei processati dai laboratori COVID dell'IZSLER nel 2021", 
      subtitle = " I punti rappresentano il numero di tamponi giornalieri, la linea blu la media mobile mensile"
    )+
    theme_ipsum_rc(base_size = 10,  axis_title_size = 10, 
                   plot_title_size = 10)+
    theme(
      axis.text.x=element_text(size = 10))
  
}

 
