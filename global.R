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
library(plotly)

# conn <- DBI::dbConnect(odbc::odbc(), Driver = "SQL Server", Server = "dbprod02.izsler.it",Database = "IZSLER", Port = 1433)
# #
# #
# queryCovid <- ("SELECT
#   dbo.Conferimenti.Numero AS nconf,
#   dbo.Anag_TipoConf.Descrizione AS tipoconf,
#   dbo.Anag_Comuni.Provincia AS Provincia,
#   dbo.Anag_Referenti.Ragione_Sociale AS Conferente,
#   dbo.Anag_Finalita.Descrizione AS Finalità,
#   dbo.Anag_Regioni.Descrizione AS Regione,
#   dbo.Anag_Comuni.Descrizione AS Comune,
#   dbo.Anag_Materiali.Descrizione AS Materiale,
#   dbo.Anag_Prove.Descrizione AS Prova,
#   dbo.Anag_Referenti.Codice AS codiceconf,
#   dbo.Conferimenti.Data AS dtacc,
#   convert (SMALLDATETIME, dbo.Conferimenti.Data_Primo_RDP_Completo_Firmato) As dtref,
#   dbo.Anag_Reparti.Descrizione AS Reparto,
#   dbo.Esami_Aggregati.Tot_Eseguiti
# FROM
# { oj dbo.Anag_TipoConf INNER JOIN dbo.Conferimenti ON ( dbo.Anag_TipoConf.Codice=dbo.Conferimenti.Tipo )
#    INNER JOIN dbo.Anag_Comuni ON ( dbo.Anag_Comuni.Codice=dbo.Conferimenti.Luogo_Prelievo )
#    LEFT OUTER JOIN dbo.Anag_Regioni ON ( dbo.Anag_Regioni.Codice=dbo.Anag_Comuni.Regione )
#    INNER JOIN dbo.Anag_Referenti ON ( dbo.Conferimenti.Conferente=dbo.Anag_Referenti.Codice )
#    LEFT OUTER JOIN dbo.Esami_Aggregati ON ( dbo.Conferimenti.Anno=dbo.Esami_Aggregati.Anno_Conferimento and dbo.Conferimenti.Numero=dbo.Esami_Aggregati.Numero_Conferimento )
#    LEFT OUTER JOIN dbo.Nomenclatore_MP ON ( dbo.Esami_Aggregati.Nomenclatore=dbo.Nomenclatore_MP.Codice )
#    LEFT OUTER JOIN dbo.Nomenclatore_Settori ON ( dbo.Nomenclatore_MP.Nomenclatore_Settore=dbo.Nomenclatore_Settori.Codice )
#    LEFT OUTER JOIN dbo.Nomenclatore ON ( dbo.Nomenclatore_Settori.Codice_Nomenclatore=dbo.Nomenclatore.Chiave )
#    LEFT OUTER JOIN dbo.Anag_Prove ON ( dbo.Nomenclatore.Codice_Prova=dbo.Anag_Prove.Codice )
#    LEFT OUTER JOIN dbo.Programmazione_Finalita ON ( dbo.Esami_Aggregati.Anno_Conferimento=dbo.Programmazione_Finalita.Anno_Conferimento and dbo.Esami_Aggregati.Numero_Conferimento=dbo.Programmazione_Finalita.Numero_Conferimento and dbo.Esami_Aggregati.Codice=dbo.Programmazione_Finalita.Codice )
#    LEFT OUTER JOIN dbo.Anag_Finalita ON ( dbo.Programmazione_Finalita.Finalita=dbo.Anag_Finalita.Codice )
#    LEFT OUTER JOIN dbo.Laboratori_Reparto ON ( dbo.Esami_Aggregati.RepLab_analisi=dbo.Laboratori_Reparto.Chiave )
#    LEFT OUTER JOIN dbo.Anag_Reparti ON ( dbo.Laboratori_Reparto.Reparto=dbo.Anag_Reparti.Codice )
#    LEFT OUTER JOIN dbo.Anag_Laboratori ON ( dbo.Laboratori_Reparto.Laboratorio=dbo.Anag_Laboratori.Codice )
#    LEFT OUTER JOIN dbo.Anag_Materiali ON ( dbo.Anag_Materiali.Codice=dbo.Conferimenti.Codice_Materiale )
#    INNER JOIN dbo.Conferimenti_Finalita ON ( dbo.Conferimenti.Anno=dbo.Conferimenti_Finalita.Anno and dbo.Conferimenti.Numero=dbo.Conferimenti_Finalita.Numero )
#    INNER JOIN dbo.Anag_Finalita  dbo_Anag_Finalita_Confer ON ( dbo.Conferimenti_Finalita.Finalita=dbo_Anag_Finalita_Confer.Codice )
#   }
# WHERE
# ( dbo.Laboratori_Reparto.Laboratorio > 1  )
#   AND  dbo.Esami_Aggregati.Esame_Altro_Ente = 0
#   AND  dbo.Esami_Aggregati.Esame_Altro_Ente = 0
#   AND  (
#   dbo_Anag_Finalita_Confer.Descrizione  =  'Emergenza COVID-19'
#   AND  dbo.Anag_Prove.Descrizione  NOT IN  ('Motivazione di inidoneità campione', 'Motivi di mancata esecuzione di prove richieste', 'Motivi di riemissione del Rapporto di Prova', 'Note alle prove', 'Note alle prove di sequenziamento genomico', 'Opinioni ed interpretazioni -non oggetto dell''accredit. ACCREDIA')
#   )
# 
# ")
# 
# 
# covid <- conn%>% tbl(sql(queryCovid)) %>% as_tibble()
# 
# covid[,"Comune"] <- sapply(covid[, "Comune"], iconv, from = "latin1", to = "UTF-8", sub = "")
# # 
# saveRDS(covid, here("data", "processed",  "covid.rds"))

# Dati
covid <- readRDS(here("data", "processed", "covid.rds"))
covid <- 
  covid %>% 
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
serie1 <- function(){  
  covid %>% 
    filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico")) %>% 
    #mutate(anno = year(dtacc)) %>% 
    filter(anno == 2021) %>% 
    
    
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

serie2 <- function(regione){  
  covid %>% 
    filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico")) %>% 
    #mutate(anno = year(dtacc)) %>% 
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
      y = "Numero Tamponi Naso-Faringei", 
      x = "", 
      title =  "", 
      subtitle = ""
    )+
    theme_ipsum_rc(base_size = 10,  axis_title_size = 10, 
                   plot_title_size = 5)+
    theme(
      axis.text.x=element_text(size = 10))
  
}

serie3 <- function(reparto){  
  covid %>% 
    filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico")) %>% 
    filter(Reparto== reparto) %>% 
    filter(anno == 2021) %>% 
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

