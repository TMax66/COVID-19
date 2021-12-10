library(shiny)
library(tidyverse)
library(readxl)
library(lubridate)
library(shinythemes)
library(DT)
library(here)
library(rpivotTable)
library(shinyjs)
library(shinycssloaders)
library(janitor)
library(zoo)
library(hrbrthemes)
library(plotly)
 


 
# # 


# Dati
covid <- readRDS(here("data", "processed", "covid.rds"))
 
covid <- 
  covid %>% 
  rename(Finalità = FinalitÃ) %>%
  rename("Destinatario Fattura" = Ragione_Sociale) %>% 
  mutate(anno = year(dtacc))

# Funzioni
## Valuebox
valueBox <- function(value, subtitle, icon, color) {
  div(class = "col-lg-3 col-md-6",
      div(class = "panel panel-primary",
          div(class = "panel-heading", style = paste0("background-color:", color),
              div(class = "row",
                  div(class = "col-xs-3",
                      icon(icon, "fa-5x")
                  ),
                  div(class = ("col-xs-9 text-right"),
                      div(style = ("font-size: 20px; font-weight: bold;"),
                          textOutput(value)
                      ),
                      div(subtitle)
                  )
              )
          ),
          div(class = "panel-footer",
              div(class = "clearfix")
          )
      )
  )
}

## Plot

covidP <- covid %>% 
  filter(Prova %in% c("SARS-CoV-2: agente eziologico")) %>% 
  group_by(dtacc) %>% 
  summarise(esami = sum(Tot_Eseguiti, na.rm = T)) %>%  
  filter(esami > 0) %>%
  mutate(sett = rollmean(esami, k = 30, fill = NA) )



serie1 <- function(){  
  covidP %>% 
    ggplot(aes(
      x = dtacc, 
      y = sett
    ))+
    geom_line(col = "blue", size = 1.5)+
    geom_point(aes(x = dtacc, 
                   y = esami), alpha = 1/5)+
    geom_line(aes(x = dtacc, 
                  y = esami), alpha = 1/5)+
    
    labs(
      y = "Numero Tamponi Naso Faringei", 
      x = "", 
      title = "", 
      subtitle = ""
    )+
    theme_ipsum_rc(base_size = 10,  axis_title_size = 10, 
                   plot_title_size = 5)+
    theme(
      axis.text.x=element_text(size = 10))
}


serie3 <- function(reparto){
  covid %>%
    filter(Prova %in% c("SARS-CoV-2: agente eziologico")) %>%
    filter(Reparto== reparto) %>%
    #filter(anno == 2021) %>%
    group_by(dtacc) %>%
    summarise(esami = sum(Tot_Eseguiti, na.rm = T)) %>%
    filter(esami > 0) %>%
    mutate(sett = rollmean(esami, k = 30, fill = NA) )%>%
    ggplot(aes(
      x = dtacc,
      y = sett
    ))+
    geom_line(col = "blue", size = 1.5)+
    geom_point(aes(x = dtacc,
                   y = esami), alpha = 1/5)+
    geom_line(aes(x = dtacc,
                  y = esami), alpha = 1/5)+

    labs(
      y = "Numero Tamponi Naso-Faringei",
      x = "",
      title = "",
      subtitle = ""
    )+
    theme_ipsum_rc(base_size = 10,  axis_title_size = 10,
                   plot_title_size = 5)+
    theme(
      axis.text.x=element_text(size = 10))
}

serie4 <- function(reparto){
  covid %>%
    filter(Reparto== reparto & anno == 2021) %>%
     
    group_by(dtacc) %>%
    summarise(esami = sum(Tot_Eseguiti, na.rm = T)) %>%
    filter(esami > 0) %>%
    mutate(sett = rollmean(esami, k = 30, fill = NA) )%>%
    ggplot(aes(
      x = dtacc,
      y = sett
    ))+
    geom_line(col = "blue", size = 1.5)+
    geom_point(aes(x = dtacc,
                   y = esami), alpha = 1/5)+
    geom_line(aes(x = dtacc,
                  y = esami), alpha = 1/5)+
    
    labs(
      y = "Numero esami",
      x = "",
      title = "",
      subtitle = ""
    )+
    theme_ipsum_rc(base_size = 10,  axis_title_size = 10,
                   plot_title_size = 5)+
    theme(
      axis.text.x=element_text(size = 10))
}
