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

conn <- DBI::dbConnect(odbc::odbc(), Driver = "SQL Server", Server = "dbprod02.izsler.it",Database = "IZSLER", Port = 1433)



queryCovid <- ("SELECT
  dbo.Conferimenti.Numero AS nconf,
  dbo.Anag_TipoConf.Descrizione AS tipoconf,
  dbo.Anag_Comuni.Provincia AS Provincia,
  dbo.Anag_Referenti.Ragione_Sociale AS Conferente,
  dbo.Anag_Finalita.Descrizione AS Finalità,
  dbo.Anag_Regioni.Descrizione AS Regione,
  dbo.Anag_Comuni.Descrizione AS Comune,
  dbo.Anag_Materiali.Descrizione AS Materiale,
  dbo.Anag_Prove.Descrizione AS Prova,
  dbo.Anag_Referenti.Codice AS codiceconf,
  dbo.Conferimenti.Data AS dtacc,
  dbo.Anag_Reparti.Descrizione AS Reparto,
  dbo.Esami_Aggregati.Tot_Eseguiti
FROM
{ oj dbo.Anag_TipoConf INNER JOIN dbo.Conferimenti ON ( dbo.Anag_TipoConf.Codice=dbo.Conferimenti.Tipo )
   INNER JOIN dbo.Anag_Comuni ON ( dbo.Anag_Comuni.Codice=dbo.Conferimenti.Luogo_Prelievo )
   LEFT OUTER JOIN dbo.Anag_Regioni ON ( dbo.Anag_Regioni.Codice=dbo.Anag_Comuni.Regione )
   INNER JOIN dbo.Anag_Referenti ON ( dbo.Conferimenti.Conferente=dbo.Anag_Referenti.Codice )
   LEFT OUTER JOIN dbo.Esami_Aggregati ON ( dbo.Conferimenti.Anno=dbo.Esami_Aggregati.Anno_Conferimento and dbo.Conferimenti.Numero=dbo.Esami_Aggregati.Numero_Conferimento )
   LEFT OUTER JOIN dbo.Nomenclatore_MP ON ( dbo.Esami_Aggregati.Nomenclatore=dbo.Nomenclatore_MP.Codice )
   LEFT OUTER JOIN dbo.Nomenclatore_Settori ON ( dbo.Nomenclatore_MP.Nomenclatore_Settore=dbo.Nomenclatore_Settori.Codice )
   LEFT OUTER JOIN dbo.Nomenclatore ON ( dbo.Nomenclatore_Settori.Codice_Nomenclatore=dbo.Nomenclatore.Chiave )
   LEFT OUTER JOIN dbo.Anag_Prove ON ( dbo.Nomenclatore.Codice_Prova=dbo.Anag_Prove.Codice )
   LEFT OUTER JOIN dbo.Programmazione_Finalita ON ( dbo.Esami_Aggregati.Anno_Conferimento=dbo.Programmazione_Finalita.Anno_Conferimento and dbo.Esami_Aggregati.Numero_Conferimento=dbo.Programmazione_Finalita.Numero_Conferimento and dbo.Esami_Aggregati.Codice=dbo.Programmazione_Finalita.Codice )
   LEFT OUTER JOIN dbo.Anag_Finalita ON ( dbo.Programmazione_Finalita.Finalita=dbo.Anag_Finalita.Codice )
   LEFT OUTER JOIN dbo.Laboratori_Reparto ON ( dbo.Esami_Aggregati.RepLab_analisi=dbo.Laboratori_Reparto.Chiave )
   LEFT OUTER JOIN dbo.Anag_Reparti ON ( dbo.Laboratori_Reparto.Reparto=dbo.Anag_Reparti.Codice )
   LEFT OUTER JOIN dbo.Anag_Laboratori ON ( dbo.Laboratori_Reparto.Laboratorio=dbo.Anag_Laboratori.Codice )
   LEFT OUTER JOIN dbo.Anag_Materiali ON ( dbo.Anag_Materiali.Codice=dbo.Conferimenti.Codice_Materiale )
   INNER JOIN dbo.Conferimenti_Finalita ON ( dbo.Conferimenti.Anno=dbo.Conferimenti_Finalita.Anno and dbo.Conferimenti.Numero=dbo.Conferimenti_Finalita.Numero )
   INNER JOIN dbo.Anag_Finalita  dbo_Anag_Finalita_Confer ON ( dbo.Conferimenti_Finalita.Finalita=dbo_Anag_Finalita_Confer.Codice )
  }
WHERE
( dbo.Laboratori_Reparto.Laboratorio > 1  )
  AND  dbo.Esami_Aggregati.Esame_Altro_Ente = 0
  AND  dbo.Esami_Aggregati.Esame_Altro_Ente = 0
  AND  (
  dbo_Anag_Finalita_Confer.Descrizione  =  'Emergenza COVID-19'
  AND  dbo.Anag_Prove.Descrizione  NOT IN  ('Motivazione di inidoneità campione', 'Motivi di mancata esecuzione di prove richieste', 'Motivi di riemissione del Rapporto di Prova', 'Note alle prove', 'Note alle prove di sequenziamento genomico', 'Opinioni ed interpretazioni -non oggetto dell''accredit. ACCREDIA')
  )

")

covid <- conn%>% tbl(sql(queryCovid)) %>% as_tibble()

covid[,"Comune"] <- sapply(covid[, "Comune"], iconv, from = "latin1", to = "UTF-8", sub = "")



 
library(writexl)
covid %>% 
   mutate(anno = year(dtacc)) %>%
    filter(Regione == "Lombardia" & anno == 2021) %>%
    group_by(codiceconf, Conferente, Comune,Prova) %>%
    summarise("esami" = sum(Tot_Eseguiti, na.rm = T)) %>%
    pivot_wider(names_from = "Prova", values_from = "esami", values_fill = 0) %>%
    adorn_totals(where = "row") %>% 
    write.xlsx('tl.xlsx')
