#librerie----
library(tidyverse)
library(here)
library(DBI)
library(odbc)
library(openxlsx)
library(readxl)
library(zoo)

library(sp)
library(leaflet)
library(rmapshaper)

library(gt)

library(showtext)
font_families()
font_add_google("Montserrat", "Montserrat")
showtext_auto()

# relativamente all’elaborazione dei dati covid per la presentazione del 4 novembre di cui ti avevo parlato, potrebbe essere utile avere dei grafici con:
# 1•	l’andamento dei tamponi conferiti presso l’IZSLER, sia totale che suddiviso per i 3 laboratori
# 2•	l’andamento dell’attività di identificazione delle varianti
# 3•	l’andamento dell’attività di sequenziamento
# 4•	La suddivisione dei campioni per matrici
# 5•	La suddivisione dei campioni per regione/provincia di provenienza
# 6•	La suddivisione dei campioni per conferente: sarebbe bello poter dividere gli ospedali (ASST), ATS, cliniche private,  RSA, strutture socioassistenziali. Mi rendo conto che questo è un po’ difficile e forse dovremmo prima essere noi a classificare i  conferenti in queste categorie.
# 
# Potremmo considerare i dati fino al 30 settembre.
# Fammi sapere se siete disponibili a fare voi queste elaborazioni oppure se mi devo arrangiare. In questo caso mi rinvieresti il file excel con i dati fino al 30 settembre?
# Grazie per l’aiuto che vorrai/potrai darmi.

# conn <- DBI::dbConnect(odbc::odbc(), Driver = "ODBC Driver 17 for SQL Server", Server = "dbprod02.izsler.it",Database = "IZSLER", Port = 1433, uid="user_cogep", pwd="!d44grki654hjS")
# 
# #conn <- DBI::dbConnect(odbc::odbc(), Driver = "SQL Server", Server = "dbprod02.izsler.it",Database = "IZSLER", Port = 1433)
# 
# # query in uso---
# # queryCovid <- ("SELECT
# #   dbo.Conferimenti.Numero AS nconf,
# #   dbo.Anag_TipoConf.Descrizione AS tipoconf,
# #   dbo.Anag_Comuni.Provincia AS Provincia,
# #   dbo.Anag_Referenti.Ragione_Sociale AS Conferente,
# #   dbo.Anag_Finalita.Descrizione AS Finalità,
# #   dbo.Anag_Regioni.Descrizione AS Regione,
# #   dbo.Anag_Comuni.Descrizione AS Comune,
# #   dbo.Anag_Materiali.Descrizione AS Materiale,
# #   dbo.Anag_Prove.Descrizione AS Prova,
# #   dbo.Anag_Referenti.Codice AS codiceconf,
# #   dbo.Conferimenti.Data AS dtconf,
# #   dbo.Conferimenti.Data_Accettazione AS dtacc,
# #   dbo.RDP_Date_Emissione.Data_RDP AS dtref,
# #   dbo.Anag_Reparti.Descrizione AS Reparto,
# #   dbo.Esami_Aggregati.Tot_Eseguiti, 
# #    dbo_Anag_Referenti_DestFatt.Ragione_Sociale,
# # dbo_Anag_Referenti_DestFatt.Codice,
# # dbo.Conferimenti.Dett_Materiale 
# # FROM
# # { oj dbo.Anag_TipoConf INNER JOIN dbo.Conferimenti ON ( dbo.Anag_TipoConf.Codice=dbo.Conferimenti.Tipo )
# #    INNER JOIN dbo.Anag_Comuni ON ( dbo.Anag_Comuni.Codice=dbo.Conferimenti.Luogo_Prelievo )
# #    LEFT OUTER JOIN dbo.Anag_Regioni ON ( dbo.Anag_Regioni.Codice=dbo.Anag_Comuni.Regione )
# #    INNER JOIN dbo.Anag_Referenti ON ( dbo.Conferimenti.Conferente=dbo.Anag_Referenti.Codice )
# #    LEFT OUTER JOIN dbo.Esami_Aggregati ON ( dbo.Conferimenti.Anno=dbo.Esami_Aggregati.Anno_Conferimento and dbo.Conferimenti.Numero=dbo.Esami_Aggregati.Numero_Conferimento )
# #    LEFT OUTER JOIN dbo.Nomenclatore_MP ON ( dbo.Esami_Aggregati.Nomenclatore=dbo.Nomenclatore_MP.Codice )
# #    LEFT OUTER JOIN dbo.Nomenclatore_Settori ON ( dbo.Nomenclatore_MP.Nomenclatore_Settore=dbo.Nomenclatore_Settori.Codice )
# #    LEFT OUTER JOIN dbo.Nomenclatore ON ( dbo.Nomenclatore_Settori.Codice_Nomenclatore=dbo.Nomenclatore.Chiave )
# #    LEFT OUTER JOIN dbo.Anag_Prove ON ( dbo.Nomenclatore.Codice_Prova=dbo.Anag_Prove.Codice )
# #    LEFT OUTER JOIN dbo.Programmazione_Finalita ON ( dbo.Esami_Aggregati.Anno_Conferimento=dbo.Programmazione_Finalita.Anno_Conferimento and dbo.Esami_Aggregati.Numero_Conferimento=dbo.Programmazione_Finalita.Numero_Conferimento and dbo.Esami_Aggregati.Codice=dbo.Programmazione_Finalita.Codice )
# #    LEFT OUTER JOIN dbo.Anag_Finalita ON ( dbo.Programmazione_Finalita.Finalita=dbo.Anag_Finalita.Codice )
# #    LEFT OUTER JOIN dbo.Laboratori_Reparto ON ( dbo.Esami_Aggregati.RepLab_analisi=dbo.Laboratori_Reparto.Chiave )
# #    LEFT OUTER JOIN dbo.Anag_Reparti ON ( dbo.Laboratori_Reparto.Reparto=dbo.Anag_Reparti.Codice )
# #    LEFT OUTER JOIN dbo.Anag_Laboratori ON ( dbo.Laboratori_Reparto.Laboratorio=dbo.Anag_Laboratori.Codice )
# #    LEFT OUTER JOIN dbo.Anag_Dettagli ON ( dbo.Esami_Aggregati.Dettaglio_P=dbo.Anag_Dettagli.Codice )
# #    LEFT OUTER JOIN dbo.Anag_Tipo_Dett ON ( dbo.Anag_Dettagli.Tipo_Dettaglio=dbo.Anag_Tipo_Dett.Codice )
# #    LEFT OUTER JOIN dbo.Anag_Referenti  dbo_Anag_Referenti_DestFatt ON ( dbo.Conferimenti.Dest_Fattura=dbo_Anag_Referenti_DestFatt.Codice )
# #    LEFT OUTER JOIN dbo.Anag_Materiali ON ( dbo.Anag_Materiali.Codice=dbo.Conferimenti.Codice_Materiale )
# #    INNER JOIN dbo.Conferimenti_Finalita ON ( dbo.Conferimenti.Anno=dbo.Conferimenti_Finalita.Anno and dbo.Conferimenti.Numero=dbo.Conferimenti_Finalita.Numero )
# #    INNER JOIN dbo.Anag_Finalita  dbo_Anag_Finalita_Confer ON ( dbo.Conferimenti_Finalita.Finalita=dbo_Anag_Finalita_Confer.Codice )
# #    LEFT OUTER JOIN dbo.RDP_Date_Emissione ON ( dbo.RDP_Date_Emissione.Anno=dbo.Conferimenti.Anno and dbo.RDP_Date_Emissione.Numero=dbo.Conferimenti.Numero )
# #   }
# # WHERE
# # ( dbo.Laboratori_Reparto.Laboratorio > 1  )
# #   AND  dbo.Esami_Aggregati.Esame_Altro_Ente = 0
# #   AND  dbo.Esami_Aggregati.Esame_Altro_Ente = 0
# #   AND  (
# #   dbo_Anag_Finalita_Confer.Descrizione  IN  ('Emergenza COVID-19', 'Varianti SARS-CoV2')
# #   AND  dbo.Anag_Prove.Descrizione  NOT IN  ('Motivazione di inidoneità campione', 'Motivi di mancata esecuzione di prove richieste', 'Motivi di riemissione del Rapporto di Prova', 'Note alle prove', 'Opinioni ed interpretazioni -non oggetto dell''accredit. ACCREDIA')
# #   )")
# 
# queryCovid <- "SELECT
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
#   dbo.Conferimenti.Data AS dtconf,
#   dbo.Conferimenti.Data_Accettazione AS dtacc,
#   dbo.RDP_Date_Emissione.Data_RDP AS dtref,
#   dbo.Anag_Reparti.Descrizione AS Reparto,
#   dbo.Esami_Aggregati.Tot_Eseguiti, 
#    dbo_Anag_Referenti_DestFatt.Ragione_Sociale,
# dbo_Anag_Referenti_DestFatt.Codice,
# dbo.Conferimenti.Dett_Materiale , 
# convert (SMALLDATETIME, dbo.Conferimenti.Data_Primo_RDP_Completo_Firmato) As dtprimoRDP
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
#    LEFT OUTER JOIN dbo.Anag_Dettagli ON ( dbo.Esami_Aggregati.Dettaglio_P=dbo.Anag_Dettagli.Codice )
#    LEFT OUTER JOIN dbo.Anag_Tipo_Dett ON ( dbo.Anag_Dettagli.Tipo_Dettaglio=dbo.Anag_Tipo_Dett.Codice )
#    LEFT OUTER JOIN dbo.Anag_Referenti  dbo_Anag_Referenti_DestFatt ON ( dbo_Anag_Referenti_DestFatt.Codice=dbo.Conferimenti.Dest_Fattura )
#    LEFT OUTER JOIN dbo.Anag_Materiali ON ( dbo.Anag_Materiali.Codice=dbo.Conferimenti.Codice_Materiale )
#    INNER JOIN dbo.Conferimenti_Finalita ON ( dbo.Conferimenti.Anno=dbo.Conferimenti_Finalita.Anno and dbo.Conferimenti.Numero=dbo.Conferimenti_Finalita.Numero )
#    INNER JOIN dbo.Anag_Finalita  dbo_Anag_Finalita_Confer ON ( dbo.Conferimenti_Finalita.Finalita=dbo_Anag_Finalita_Confer.Codice )
#    LEFT OUTER JOIN dbo.RDP_Date_Emissione ON ( dbo.RDP_Date_Emissione.Anno=dbo.Conferimenti.Anno and dbo.RDP_Date_Emissione.Numero=dbo.Conferimenti.Numero )
#   }WHERE
# ( dbo.Laboratori_Reparto.Laboratorio > 1  )
#   AND  dbo.Esami_Aggregati.Esame_Altro_Ente = 0
#   AND  dbo.Esami_Aggregati.Esame_Altro_Ente = 0
#   AND  (
#   dbo_Anag_Finalita_Confer.Descrizione  IN  ('Emergenza COVID-19', 'Varianti SARS-CoV2')
#   AND  dbo.Anag_Prove.Descrizione  NOT IN  ('Motivazione di inidoneità campione', 'Motivi di mancata esecuzione di prove richieste', 'Motivi di riemissione del Rapporto di Prova', 'Note alle prove', 'Opinioni ed interpretazioni -non oggetto dell''accredit. ACCREDIA')
#   )"
# 
# covid <- conn%>% tbl(sql(queryCovid)) %>% as_tibble()
# 
# covid[,"Comune"] <- sapply(covid[, "Comune"], iconv, from = "latin1", to = "UTF-8", sub = "")
# 
# covid <- covid %>% 
#   mutate(anno = year(dtacc)) %>% 
#   rename("Codice Dest Fattura" = Codice)
# 
# saveRDS(covid, here("data", "processed",  "covid.rds"))

#dati----
dt <- readRDS(here("data", "processed", "covid.rds"))

# data.frame(conferente = levels(factor(dt$Conferente))) %>%
# write.xlsx(file = "conferenti.xlsx")

conf <- read.xlsx("conferenti.xlsx")

# breaks.vec <- seq(min(dt$dtconf), max(dt$dtconf), by = "3 months")
# bre <- format(breaks.vec, "%b %y")
# https://stackoverflow.com/questions/66129660/x-axis-as-week-number-and-secondary-x-axis-as-date

##ANALISI DATI:----

dt %>% 
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    TRUE ~ paste0(Materiale))
    ) %>%
  distinct(Finalità, Materiale, Prova) %>%
  arrange(Finalità, Materiale, Prova)

dt %>% 
  distinct(Finalità)
dt %>% 
  distinct(Materiale)
dt %>% 
  distinct(Prova)
dt %>% 
  distinct(Reparto)

table(dt$Finalità)
table(dt$Materiale)
table(dt$Prova)
table(dt$Reparto)

table(dt$Prova,dt$Finalità)
table(dt$Prova,dt$Materiale)


dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("TAMPONE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  #REPARTO
  filter(Reparto %in% c("Reparto Tecnologie Biologiche Applicate", "Sede Territoriale di Pavia", "Sede Territoriale di Modena"))

min(dt$dtconf)
max(dt$dtconf)


## 1*tamponi totali----
dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    #str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  filter(!Prova == "Agente eziologico") %>% 
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  #REPARTO
  filter(Reparto %in% c("Reparto Tecnologie Biologiche Applicate", "Sede Territoriale di Pavia", "Sede Territoriale di Modena")) %>% 
  #FILTRO PRIMA DOMANDA - NUMERO TOTALE TAMPONI
  filter(Materiale %in% c("TAMPONE", "SALIVARE") & Prova %in% c("SARS-CoV-2: agente eziologico")) %>%
  group_by(dtconf) %>% 
  #group_by(dtconf = lubridate::floor_date(dtconf, "month")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
  filter(esami > 0) %>% 
  mutate(
    media1 = coalesce(rollmean(esami, k = 30, fill = NA, align = "center"), esami),
    media = rollapply(esami, width = 30, FUN=function(x) mean(x, na.rm=TRUE), by=1, by.column=TRUE, partial=TRUE, fill=NA, align="center")) %>% #k = 15
  ggplot(
    aes(x = as.Date(dtconf), y = media)) +
  geom_line(
    col = "steelblue", size = 1.1) +
  geom_point(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.1) +
  geom_line(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.2) + 
  # scale_x_date(date_breaks = "3 month",
  #              date_labels =  "%b %y")
  scale_x_date(expand = c(0, 0),
               #breaks = as.Date(dt$dtconf),
               #date_breaks = "2 month",
               breaks = as.Date(c("2020-06-01", "2021-06-01", "2022-06-01","2023-06-01")),
               minor_breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
               # minor_breaks = as.Date(c("1975-01-01", "1980-01-01",
               #                          "2005-01-01", "2010-01-01")),
               labels = scales::date_format("%Y"),
               sec.axis = dup_axis(name = "",
                                   breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
                                   labels = scales::date_format("%b"))) + 
  theme_minimal() +
  labs(
    title = "IZSLER - Totale tamponi processati",
    subtitle = "marzo 2020 - settembre 2022",
    x = NULL,
    y = NULL) +
  expand_limits(
    x = as.Date(c("2020-03-01", "2022-10-01"))
    ) +
  theme(
    text = element_text(family = "Montserrat"),
    axis.text.x.bottom = element_text(
      size = 11, 
      margin = margin(-10,0,0,0)),
      panel.grid.major.x = element_blank()
      ) +
  # annotate("rect", xmin = as.Date("2020-03-01"), xmax = as.Date("2020-12-31"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .2) +
  # annotate("rect", xmin = as.Date("2021-01-01"), xmax = as.Date("2021-12-31"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .3) +
  # annotate("rect", xmin = as.Date("2022-01-01"), xmax = as.Date("2022-10-01"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .2) +
  #prima ondata
  annotate("pointrange",
           x = mean.Date(as.Date(c("2020-03-01","2020-05-10"), format=c("%Y-%m-%d"))),
           xmin = as.Date("2020-03-01"), xmax = as.Date("2020-05-10"),
           y = 5500, colour = "red", size = 1, alpha = 0.5) +
  annotate("text",
           label = paste0("1",intToUtf8("0xAA")," ondata"),
           x = mean.Date(as.Date(c("2020-03-01","2020-05-10"), format=c("%Y-%m-%d"))),
           y = 5700, colour = "red", size = 4, alpha = 1,  hjust = 0.4, family= "Montserrat"
           ) +
  #seconda ondata
  annotate("pointrange",
           x = mean.Date(as.Date(c("2020-09-01","2021-01-09"), format=c("%Y-%m-%d"))),
           xmin = as.Date("2020-09-01"), xmax = as.Date("2021-01-09"),
           y = 5500, colour = "red", size = 1, alpha = 0.5) +
  annotate("text",
           label = paste0("2",intToUtf8("0xAA")," ondata"),
           x = mean.Date(as.Date(c("2020-09-01","2021-01-09"), format=c("%Y-%m-%d"))),
           y = 5700, colour = "red", size = 4, alpha = 1,  hjust = 0.5, family= "Montserrat"
           ) +
  #terza ondata
  annotate("pointrange",
           x = mean.Date(as.Date(c("2021-03-01","2021-05-01"), format=c("%Y-%m-%d"))),
           xmin = as.Date("2021-03-01"), xmax = as.Date("2021-05-01"),
           y = 5500, colour = "red", size = 1, alpha = 0.5) +
  annotate("text",
           label = paste0("3",intToUtf8("0xAA")," ondata"),
           x = mean.Date(as.Date(c("2021-03-01","2021-05-01"), format=c("%Y-%m-%d"))),
           y = 5700, colour = "red", size = 4, alpha = 1,  hjust = 0.5, family= "Montserrat"
           ) +
  #quarta ondata
  annotate("pointrange",
           x = mean.Date(as.Date(c("2021-12-01","2022-03-01"), format=c("%Y-%m-%d"))),
           xmin = as.Date("2021-12-01"), xmax = as.Date("2022-03-01"),
           y = 5500, colour = "red", size = 1, alpha = 0.5) +
  annotate("text",
           label = paste0("4",intToUtf8("0xAA")," ondata"),
           x = mean.Date(as.Date(c("2021-12-01","2022-03-01"), format=c("%Y-%m-%d"))),
           y = 5700, colour = "red", size = 4, alpha = 1,  hjust = 0.5, family= "Montserrat"
           ) +
  geom_vline(xintercept=as.Date(c("2021-01-01")), linetype = "11",
             color = "black", size = 0.5) +
  geom_vline(xintercept=as.Date(c("2022-01-01")), linetype = "11",
             color = "black", size = 0.5)
  



#https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwjR-KGHpOn6AhVDQPEDHVbaBPsQFnoECBsQAQ&url=https%3A%2F%2Fwww.salute.gov.it%2Fimgs%2FC_17_pubblicazioni_3068_allegato.pdf&usg=AOvVaw0OahNzMhX8eHLfPL001VLA

#https://stackoverflow.com/questions/5169366/r-ggplot2-how-to-hide-missing-dates-from-x-axis
#https://stackoverflow.com/questions/28758576/time-series-multiple-plot-for-different-group-in-r
#https://stackoverflow.com/questions/59195398/plot-time-series-in-r-ggplot-using-multiple-groups



## 1*pavia----
dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    #str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  filter(!Prova == "Agente eziologico") %>% 
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  #REPARTO
  filter(Reparto %in% c("Sede Territoriale di Pavia")) %>% 
  #FILTRO PRIMA DOMANDA - NUMERO TOTALE TAMPONI
  filter(Materiale %in% c("TAMPONE", "SALIVARE") & Prova %in% c("SARS-CoV-2: agente eziologico")) %>%
  group_by(dtconf) %>% 
  #group_by(dtconf = lubridate::floor_date(dtconf, "month")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
  filter(esami > 0) %>% 
  mutate(
    media1 = coalesce(rollmean(esami, k = 30, fill = NA, align = "center"), esami),
    media = rollapply(esami, width = 30, FUN=function(x) mean(x, na.rm=TRUE), by=1, by.column=TRUE, partial=TRUE, fill=NA, align="center")) %>% #k = 15
  ggplot(
    aes(x = as.Date(dtconf), y = media)) +
  geom_line(
    col = "steelblue", size = 1.1) +
  geom_point(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.1) +
  geom_line(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.2) + 
  # scale_x_date(date_breaks = "3 month",
  #              date_labels =  "%b %y")
  scale_x_date(expand = c(0, 0),
               #breaks = as.Date(dt$dtconf),
               #date_breaks = "2 month",
               breaks = as.Date(c("2020-06-01", "2021-06-01", "2022-06-01","2023-06-01")),
               minor_breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
               # minor_breaks = as.Date(c("1975-01-01", "1980-01-01",
               #                          "2005-01-01", "2010-01-01")),
               labels = scales::date_format("%Y"),
               sec.axis = dup_axis(name = "",
                                   breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
                                   labels = scales::date_format("%b"))) + 
  theme_minimal() +
  labs(
    title = "IZSLER - Tamponi processati presso il laboratorio della Sede Territoriale di Pavia",
    subtitle = "marzo 2020 - settembre 2022",
    x = NULL,
    y = NULL) +
  expand_limits(
    x = as.Date(c("2020-03-01", "2022-10-01"))
    ) +
  theme(
    text = element_text(family = "Montserrat"),
    axis.text.x.bottom = element_text(
      size = 11, 
      margin = margin(-10,0,0,0)),
      panel.grid.major.x = element_blank()
      ) +
  # annotate("rect", xmin = as.Date("2020-03-01"), xmax = as.Date("2020-12-31"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .2) +
  # annotate("rect", xmin = as.Date("2021-01-01"), xmax = as.Date("2021-12-31"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .3) +
  # annotate("rect", xmin = as.Date("2022-01-01"), xmax = as.Date("2022-10-01"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .2) +
  geom_vline(xintercept=as.Date(c("2021-01-01")), linetype = "11",
             color = "black", size = 0.5) +
  geom_vline(xintercept=as.Date(c("2022-01-01")), linetype = "11",
             color = "black", size = 0.5)


## 1*modena----

dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    #str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  filter(!Prova == "Agente eziologico") %>% 
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  #REPARTO
  filter(Reparto %in% c("Sede Territoriale di Modena")) %>% 
  #FILTRO PRIMA DOMANDA - NUMERO TOTALE TAMPONI
  filter(Materiale %in% c("TAMPONE", "SALIVARE") & Prova %in% c("SARS-CoV-2: agente eziologico")) %>%
  group_by(dtconf) %>% 
  #group_by(dtconf = lubridate::floor_date(dtconf, "month")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
  filter(esami > 0) %>% 
  mutate(
    media1 = coalesce(rollmean(esami, k = 30, fill = NA, align = "center"), esami),
    media = rollapply(esami, width = 30, FUN=function(x) mean(x, na.rm=TRUE), by=1, by.column=TRUE, partial=TRUE, fill=NA, align="center")) %>% #k = 15
  ggplot(
    aes(x = as.Date(dtconf), y = media)) +
  geom_line(
    col = "steelblue", size = 1.1) +
  geom_point(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.1) +
  geom_line(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.2) + 
  # scale_x_date(date_breaks = "3 month",
  #              date_labels =  "%b %y")
  scale_x_date(expand = c(0, 0),
               #breaks = as.Date(dt$dtconf),
               #date_breaks = "2 month",
               breaks = as.Date(c("2020-09-01", "2021-06-01", "2022-03-01","2023-06-01")),
               minor_breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
               # minor_breaks = as.Date(c("1975-01-01", "1980-01-01",
               #                          "2005-01-01", "2010-01-01")),
               labels = scales::date_format("%Y"),
               sec.axis = dup_axis(name = "",
                                   breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
                                   labels = scales::date_format("%b"))) + 
  theme_minimal() +
  labs(
    title = "IZSLER - Tamponi processati presso il laboratorio della Sede Territoriale di Modena",
    subtitle = "maggio 2020 - marzo 2022",
    x = NULL,
    y = NULL) +
  expand_limits(x = as.Date(c("2020-05-21", "2022-04-01"))) +
  theme(
    text = element_text(family = "Montserrat"),
    axis.text.x.bottom = element_text(
      size = 11, 
      margin = margin(-10,0,0,0)),
      panel.grid.major.x = element_blank()
      ) +
  # annotate("rect", xmin = as.Date("2020-05-21"), xmax = as.Date("2020-12-31"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .2) +
  # annotate("rect", xmin = as.Date("2021-01-01"), xmax = as.Date("2021-12-31"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .3) +
  # annotate("rect", xmin = as.Date("2022-01-01"), xmax = as.Date("2022-04-01"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .2) +
  geom_vline(xintercept=as.Date(c("2021-01-01")), linetype = "11",
             color = "black", size = 0.5) +
  geom_vline(xintercept=as.Date(c("2022-01-01")), linetype = "11",
             color = "black", size = 0.5)




## 1*Reparto Tecnologie Biologiche Applicate----

dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    #str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  filter(!Prova == "Agente eziologico") %>% 
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  #REPARTO
  filter(Reparto %in% c("Reparto Tecnologie Biologiche Applicate")) %>% 
  #FILTRO PRIMA DOMANDA - NUMERO TOTALE TAMPONI
  filter(Materiale %in% c("TAMPONE", "SALIVARE") & Prova %in% c("SARS-CoV-2: agente eziologico")) %>%
  group_by(dtconf) %>% 
  #group_by(dtconf = lubridate::floor_date(dtconf, "month")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
  filter(esami > 0) %>% 
  mutate(
    media1 = coalesce(rollmean(esami, k = 30, fill = NA, align = "center"), esami),
    media = rollapply(esami, width = 30, FUN=function(x) mean(x, na.rm=TRUE), by=1, by.column=TRUE, partial=TRUE, fill=NA, align="center")) %>% #k = 15
  ggplot(
    aes(x = as.Date(dtconf), y = media)) +
  geom_line(
    col = "steelblue", size = 1.1) +
  geom_point(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.1) +
  geom_line(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.2) + 
  # scale_x_date(date_breaks = "3 month",
  #              date_labels =  "%b %y")
  scale_x_date(expand = c(0, 0),
               #breaks = as.Date(dt$dtconf),
               #date_breaks = "2 month",
               breaks = as.Date(c("2020-06-01", "2021-06-01", "2022-06-01","2023-06-01")),
               minor_breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
               # minor_breaks = as.Date(c("1975-01-01", "1980-01-01",
               #                          "2005-01-01", "2010-01-01")),
               labels = scales::date_format("%Y"),
               sec.axis = dup_axis(name = "",
                                   breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
                                   labels = scales::date_format("%b"))) + 
  theme_minimal() +
  labs(
    title = "IZSLER - Tamponi processati presso il laboratorio del Reparto Tecnologie Biologiche Applicate",
    subtitle = "marzo 2020 - settembre 2022",
    x = NULL,
    y = NULL) +
  expand_limits(x = as.Date(c("2020-03-01", "2022-10-01"))) +
  theme(
    text = element_text(family = "Montserrat"),
    axis.text.x.bottom = element_text(
      size = 11, 
      margin = margin(-10,0,0,0)),
      panel.grid.major.x = element_blank()
      ) +
  # annotate("rect", xmin = as.Date("2020-03-01"), xmax = as.Date("2020-12-31"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .2) +
  # annotate("rect", xmin = as.Date("2021-01-01"), xmax = as.Date("2021-12-31"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .3) +
  # annotate("rect", xmin = as.Date("2022-01-01"), xmax = as.Date("2022-10-01"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .2) +
  geom_vline(xintercept=as.Date(c("2021-01-01")), linetype = "11",
             color = "black", size = 0.5) +
  geom_vline(xintercept=as.Date(c("2022-01-01")), linetype = "11",
             color = "black", size = 0.5)


## 2*identificazione----

dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    #str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  filter(!Prova == "Agente eziologico") %>% 
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  #FILTRO SECONDA DOMANDA - IDENTIFICAZIONE VARIANTI
  filter(Prova %in% c("SARS-CoV-2: identificazione varianti")) %>%
  group_by(dtconf) %>% 
  #group_by(dtconf = lubridate::floor_date(dtconf, "month")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
  filter(esami > 0) %>% 
  mutate(
    media1 = coalesce(rollmean(esami, k = 30, fill = NA, align = "center"), esami),
    media = rollapply(esami, width = 30, FUN=function(x) mean(x, na.rm=TRUE), by=1, by.column=TRUE, partial=TRUE, fill=NA, align="center")) %>% #k = 15
  ggplot(
    aes(x = as.Date(dtconf), y = media)) +
  geom_line(
    col = "steelblue", size = 1.1) +
  geom_point(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.1) +
  geom_line(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.2) + 
  # scale_x_date(date_breaks = "3 month",
  #              date_labels =  "%b %y")
  scale_x_date(expand = c(0, 0),
               #breaks = as.Date(dt$dtconf),
               #date_breaks = "2 month",
               breaks = as.Date(c("2020-06-01", "2021-06-01", "2022-06-01","2023-06-01")),
               minor_breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
               # minor_breaks = as.Date(c("1975-01-01", "1980-01-01",
               #                          "2005-01-01", "2010-01-01")),
               labels = scales::date_format("%Y"),
               sec.axis = dup_axis(name = "",
                                   breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
                                   labels = scales::date_format("%b"))) + 
  theme_minimal() +
  labs(
    title = "IZSLER - Attività di identificazione delle varianti",
    subtitle = "gennaio 2021 - luglio 2022",
    x = NULL,
    y = NULL) +
  expand_limits(x = as.Date(c("2021-01-01", "2022-07-05"))) +
  theme(
    text = element_text(family = "Montserrat"),
    axis.text.x.bottom = element_text(
      size = 11, 
      margin = margin(-10,0,0,0)),
      panel.grid.major.x = element_blank()
      ) +
  # annotate("rect", xmin = as.Date("2020-03-01"), xmax = as.Date("2020-12-31"),
  #          ymin = 0, ymax = Inf, fill = "grey50", alpha = .3) +
  # annotate("rect", xmin = as.Date("2021-01-01"), xmax = as.Date("2021-12-31"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .3) +
  # annotate("rect", xmin = as.Date("2022-01-01"), xmax = as.Date("2022-07-05"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .2) +
  geom_vline(xintercept=as.Date(c("2022-01-01")), linetype = "11",
             color = "black", size = 0.5)


## 3* sequenziamento----
dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    #str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  filter(!Prova == "Agente eziologico") %>% 
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  #FILTRO TERZA DOMANDA - SEQUENZIAMENTO
  filter(Prova %in% c("SARS-CoV-2: sequenziamento")) %>%
  group_by(dtconf) %>% 
  #group_by(dtconf = lubridate::floor_date(dtconf, "month")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
  filter(esami > 0) %>% 
  mutate(
    media1 = coalesce(rollmean(esami, k = 30, fill = NA, align = "center"), esami),
    media = rollapply(esami, width = 30, FUN=function(x) mean(x, na.rm=TRUE), by=1, by.column=TRUE, partial=TRUE, fill=NA, align="center")) %>% 
  ggplot(
    aes(x = as.Date(dtconf), y = media)) +
  geom_line(
    col = "steelblue", size = 1.1) +
  geom_point(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.1) +
  geom_line(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.2) + 
  # scale_x_date(date_breaks = "3 month",
  #              date_labels =  "%b %y")
  scale_x_date(expand = c(0, 0),
               limits = as.Date(c("2021-01-01","2022-10-01")),
               #breaks = as.Date(dt$dtconf),
               #date_breaks = "2 month",
               breaks = as.Date(c("2020-06-01", "2021-06-01", "2022-06-01","2023-06-01")),
               minor_breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
               # minor_breaks = as.Date(c("1975-01-01", "1980-01-01",
               #                          "2005-01-01", "2010-01-01")),
               labels = scales::date_format("%Y"),
               sec.axis = dup_axis(name = "",
                                   breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
                                   labels = scales::date_format("%b"))) + 
  theme_minimal() +
  labs(
    title = "IZSLER - Attività di sequenziamento",
    subtitle = "gennaio 2021 - settembre 2022",
    x = NULL,
    y = NULL) +
  expand_limits(x = as.Date(c("2021-01-01", "2022-09-21"))) +
  theme(
    text = element_text(family = "Montserrat"),
    axis.text.x.bottom = element_text(
      size = 11, 
      margin = margin(-10,0,0,0)),
      panel.grid.major.x = element_blank()
      ) +
  # annotate("rect", xmin = as.Date("2020-03-01"), xmax = as.Date("2020-12-31"),
  #          ymin = 0, ymax = Inf, fill = "grey50", alpha = .3) +
  # annotate("rect", xmin = as.Date("2021-01-01"), xmax = as.Date("2021-12-31"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .3) +
  # annotate("rect", xmin = as.Date("2022-01-01"), xmax = as.Date("2022-09-21"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .2) +
  geom_vline(xintercept=as.Date(c("2022-01-01")), linetype = "11",
             color = "black", size = 0.5)

  
## 3* SETTIMANA sequenziamento----
dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    #str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  filter(!Prova == "Agente eziologico") %>% 
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  #FILTRO TERZA DOMANDA - SEQUENZIAMENTO
  filter(Prova %in% c("SARS-CoV-2: sequenziamento")) %>%
  #filter(Reparto == "Reparto Tecnologie Biologiche Applicate") %>% 
  #filter(Reparto == "Analisi del rischio ed epidemiologia genomica") %>% 
  #group_by(dtconf) %>% 
  group_by(dtconf = lubridate::floor_date(dtconf, "week")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
  filter(esami > 0) %>% 
  mutate(
    media1 = coalesce(rollmean(esami, k = 30, fill = NA, align = "center"), esami),
    media = rollapply(esami, width = 7, FUN=function(x) mean(x, na.rm=TRUE), by=1, by.column=TRUE, partial=TRUE, fill=NA, align="center")) %>%
  ggplot(
    aes(x = as.Date(dtconf), y = media)) +
  geom_line(
    col = "steelblue", size = 1.1) +
  geom_point(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.1) +
  geom_line(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.2) + 
  # scale_x_date(date_breaks = "3 month",
  #              date_labels =  "%b %y")
  scale_x_date(expand = c(0, 0),
               limits = as.Date(c("2021-01-01","2022-10-01")),
               #breaks = as.Date(dt$dtconf),
               #date_breaks = "2 month",
               breaks = as.Date(c("2020-06-01", "2021-06-01", "2022-06-01","2023-06-01")),
               minor_breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
               # minor_breaks = as.Date(c("1975-01-01", "1980-01-01",
               #                          "2005-01-01", "2010-01-01")),
               labels = scales::date_format("%Y"),
               sec.axis = dup_axis(name = "",
                                   breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
                                   labels = scales::date_format("%b"))) + 
  theme_minimal() +
  labs(
    title = "IZSLER - Attività di sequenziamento",
    subtitle = "gennaio 2021 - settembre 2022",
    x = NULL,
    y = NULL) +
  expand_limits(x = as.Date(c("2021-01-01", "2022-10-01"))) +
  theme(
    text = element_text(family = "Montserrat"),
    axis.text.x.bottom = element_text(
      size = 11, 
      margin = margin(-10,0,0,0)),
      panel.grid.major.x = element_blank()
      ) +
  # annotate("rect", xmin = as.Date("2020-03-01"), xmax = as.Date("2020-12-31"),
  #          ymin = 0, ymax = Inf, fill = "grey50", alpha = .3) +
  # annotate("rect", xmin = as.Date("2021-01-01"), xmax = as.Date("2021-12-31"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .3) +
  # annotate("rect", xmin = as.Date("2022-01-01"), xmax = as.Date("2022-10-01"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .2) +
  geom_vline(xintercept=as.Date(c("2022-01-01")), linetype = "11",
             color = "black", size = 0.5)


## 3* SETTIMANA BRESCIA sequenziamento----
dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    #str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  filter(!Prova == "Agente eziologico") %>% 
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  #FILTRO TERZA DOMANDA - SEQUENZIAMENTO
  filter(Prova %in% c("SARS-CoV-2: sequenziamento")) %>%
  filter(Reparto == "Reparto Tecnologie Biologiche Applicate") %>% 
  #filter(Reparto == "Analisi del rischio ed epidemiologia genomica") %>% 
  #group_by(dtconf) %>% 
  group_by(dtconf = lubridate::floor_date(dtconf, "week")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
  filter(esami > 0) %>% 
  mutate(
    media1 = coalesce(rollmean(esami, k = 30, fill = NA, align = "center"), esami),
    media = rollapply(esami, width = 7, FUN=function(x) mean(x, na.rm=TRUE), by=1, by.column=TRUE, partial=TRUE, fill=NA, align="center")) %>%
  ggplot(
    aes(x = as.Date(dtconf), y = media)) +
  geom_line(
    col = "steelblue", size = 1.1) +
  geom_point(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.1) +
  geom_line(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.2) + 
  # scale_x_date(date_breaks = "3 month",
  #              date_labels =  "%b %y")
  scale_x_date(expand = c(0, 0),
               limits = as.Date(c("2021-01-01","2022-07-31")),
               #breaks = as.Date(dt$dtconf),
               #date_breaks = "2 month",
               breaks = as.Date(c("2020-06-01", "2021-06-01", "2022-06-01","2023-06-01")),
               minor_breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
               # minor_breaks = as.Date(c("1975-01-01", "1980-01-01",
               #                          "2005-01-01", "2010-01-01")),
               labels = scales::date_format("%Y"),
               sec.axis = dup_axis(name = "",
                                   breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
                                   labels = scales::date_format("%b"))) + 
  theme_minimal() +
  labs(
    title = "IZSLER - Reparto Tecnologie Biologiche Applicate - Attività di sequenziamento",
    subtitle = "gennaio 2021 - luglio 2022",
    x = NULL,
    y = NULL) +
  expand_limits(x = as.Date(c("2021-01-01", "2022-07-31"))) +
  theme(
    text = element_text(family = "Montserrat"),
    axis.text.x.bottom = element_text(
      size = 11, 
      margin = margin(-10,0,0,0)),
      panel.grid.major.x = element_blank()
      ) +
  # annotate("rect", xmin = as.Date("2020-03-01"), xmax = as.Date("2020-12-31"),
  #          ymin = 0, ymax = Inf, fill = "grey50", alpha = .3) +
  # annotate("rect", xmin = as.Date("2021-01-01"), xmax = as.Date("2021-12-31"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .3) +
  # annotate("rect", xmin = as.Date("2022-01-01"), xmax = as.Date("2022-07-31"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .2) +
  geom_vline(xintercept=as.Date(c("2022-01-01")), linetype = "11",
             color = "black", size = 0.5)


## 3* SETTIMANA PARMA sequenziamento----
dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    #str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  filter(!Prova == "Agente eziologico") %>% 
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  #FILTRO TERZA DOMANDA - SEQUENZIAMENTO
  filter(Prova %in% c("SARS-CoV-2: sequenziamento")) %>%
  #filter(Reparto == "Reparto Tecnologie Biologiche Applicate") %>% 
  filter(Reparto == "Analisi del rischio ed epidemiologia genomica") %>% 
  #group_by(dtconf) %>% 
  group_by(dtconf = lubridate::floor_date(dtconf, "week")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
  filter(esami > 0) %>% 
  mutate(
    media1 = coalesce(rollmean(esami, k = 30, fill = NA, align = "center"), esami),
    media = rollapply(esami, width = 7, FUN=function(x) mean(x, na.rm=TRUE), by=1, by.column=TRUE, partial=TRUE, fill=NA, align="center")) %>%
  ggplot(
    aes(x = as.Date(dtconf), y = media)) +
  geom_line(
    col = "steelblue", size = 1.1) +
  geom_point(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.1) +
  geom_line(
    aes(x = as.Date(dtconf), y = esami), col = "black", alpha = 1/5, size = 0.2) + 
  # scale_x_date(date_breaks = "3 month",
  #              date_labels =  "%b %y")
  scale_x_date(expand = c(0, 0),
               limits = as.Date(c("2021-03-01","2022-09-18")),
               #breaks = as.Date(dt$dtconf),
               #date_breaks = "2 month",
               breaks = as.Date(c("2020-06-01", "2021-06-01", "2022-06-01","2023-06-01")),
               minor_breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
               # minor_breaks = as.Date(c("1975-01-01", "1980-01-01",
               #                          "2005-01-01", "2010-01-01")),
               labels = scales::date_format("%Y"),
               sec.axis = dup_axis(name = "",
                                   breaks = as.Date(c(
                                     "2020-01-01","2020-03-01","2020-05-01","2020-07-01","2020-09-01","2020-11-01",
                                     "2021-01-01","2021-03-01","2021-05-01","2021-07-01","2021-09-01","2021-11-01",
                                     "2022-01-01","2022-03-01","2022-05-01","2022-07-01","2022-09-01","2022-11-01"
                                    )),
                                   labels = scales::date_format("%b"))) + 
  theme_minimal() +
  labs(
    title = "IZSLER - Analisi del rischio ed epidemiologia genomica - Attività di sequenziamento",
    subtitle = "marzo 2021 - settembre 2022",
    x = NULL,
    y = NULL) +
  expand_limits(x = as.Date(c("2021-03-01", "2022-09-18"))) +
  theme(
    text = element_text(family = "Montserrat"),
    axis.text.x.bottom = element_text(
      size = 11, 
      margin = margin(-10,0,0,0)),
      panel.grid.major.x = element_blank()
      ) +
  # annotate("rect", xmin = as.Date("2020-03-01"), xmax = as.Date("2020-12-31"),
  #          ymin = 0, ymax = Inf, fill = "grey50", alpha = .3) +
  # annotate("rect", xmin = as.Date("2021-03-01"), xmax = as.Date("2021-12-31"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .3) +
  # annotate("rect", xmin = as.Date("2022-01-01"), xmax = as.Date("2022-09-18"),
  #          ymin = 0, ymax = Inf, fill = "skyblue3", alpha = .2) +
  geom_vline(xintercept=as.Date(c("2022-01-01")), linetype = "11",
             color = "black", size = 0.5)
  
  
## 4* GT matrici----
d <- dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    #str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  filter(!Prova == "Agente eziologico") %>% 
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  filter(Materiale %in% c("TAMPONE", "SALIVARE")) %>% 
  #FILTRO QUARTA DOMANDA - SUDDIVISIONE CAMPIONI PER MATRICI
  group_by(anno, Materiale) %>% 
  #group_by(dtconf = lubridate::floor_date(dtconf, "month")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>%
  arrange(desc(esami)) %>% 
  ungroup() 

num.groups <- d %>% select(Materiale) %>% n_distinct()
colnames(d)
colnames(d) <- c("Anno",
                 "Matrice",
                 "Campioni")
dummy.rows.mat <- matrix(rep(colnames(d), num.groups), nrow=num.groups, byrow=TRUE)
dummy.rows.df <- as.data.frame(dummy.rows.mat, row.names=F, make.names=F) %>% janitor::row_to_names(1, remove_row = F)
col.names <- as.factor(d$Matrice)
dummy.rows.df$Matrice <- levels(col.names)
rep <- rbind(dummy.rows.df,d)
rep <- as_tibble(rep)

rep %>%
  gt(groupname_col = "Matrice") %>%
  row_group_order(groups = c("TAMPONE", "SALIVARE")) %>% 
  tab_header(
    title = "IZSLER - Campioni processati per tipo di matrice",
    subtitle = "marzo 2020 - settembre 2022"
    ) %>% 
  tab_options(column_labels.hidden = T) %>% 
  tab_style(style = list(
    cell_text(align = "left")),
    locations = cells_title()) %>% 
  tab_style(style = list(
    cell_text(align = "center", weight = "bold")),
    locations = cells_row_groups()) %>%
  cols_width(Matrice ~ px(175)
             ) %>% tab_options(table.width = px(350))%>%
  tab_style(
    style = list(
      cell_text(align = "right")
    ),
    locations = cells_body(
      columns = c("Campioni")
    )) %>% opt_table_font(
    font = list(
      google_font(name = "Montserrat")
    )
  )
  
## 5* GT regioni/province----
sigla_pro <- read_xlsx(here("data", "processed", "sigle province.xlsx"))

p <- dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    #str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  filter(!Prova == "Agente eziologico") %>% 
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  #FILTRO QUINTA DOMANDA - SUDDIVISIONE CAMPIONI PER PROVINCE
  group_by(Regione, Provincia) %>% 
  #group_by(dtconf = lubridate::floor_date(dtconf, "month")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>%
  arrange(desc(esami)) %>% 
  ungroup() %>% 
  filter(!Regione == "Non definita") %>% 
  left_join(sigla_pro %>%
              select(-c(Regione)), by = c("Provincia"= "Sigla"), suffix = c("_0", "_1")) %>% 
  select(Regione, Provincia_1, esami) %>% 
  mutate(Regione = toupper(Regione))

# num.groups <- p %>% select(Regione) %>% n_distinct()
colnames(p)
colnames(p) <- c("Regione",
                 "Provincia",
                 "Campioni")
# dummy.rows.mat <- matrix(rep(colnames(p), num.groups), nrow=num.groups, byrow=TRUE)
# dummy.rows.df <- as.data.frame(dummy.rows.mat, row.names=F, make.names=F) %>% janitor::row_to_names(1, remove_row = F)
# col.names <- as.factor(p$Regione)
# dummy.rows.df$Regione <- levels(col.names)
# rep <- rbind(dummy.rows.df, p)
# rep <- as_tibble(rep)

p %>%
  gt(groupname_col = "Regione") %>%
  tab_header(
    title = "IZSLER - Campioni processati per Provincia di provenienza",
    subtitle = "marzo 2020 - settembre 2022"
    ) %>% 
  tab_options(column_labels.hidden = T) %>% 
  tab_style(style = list(
    cell_text(align = "left")),
    locations = cells_title()) %>% 
  tab_style(style = list(
    cell_text(align = "center", weight = "bold")),
    locations = cells_row_groups()) %>%
  cols_width(Provincia ~ px(175)
             ) %>% tab_options(table.width = px(350))%>%
  tab_style(
    style = list(
      cell_text(align = "right")
    ),
    locations = cells_body(
      columns = c("Campioni")
    )) %>% 
  opt_table_font(
    font = list(
      google_font(name = "Montserrat")
    )
  )

## 5* BARPLOT regioni/province----
sigla_pro <- read_xlsx(here("data", "processed", "sigle province.xlsx"))

p <- dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    #str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  filter(!Prova == "Agente eziologico") %>% 
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  #FILTRO QUINTA DOMANDA - SUDDIVISIONE CAMPIONI PER PROVINCE
  group_by(Regione, Provincia) %>% 
  #group_by(dtconf = lubridate::floor_date(dtconf, "month")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>%
  arrange(desc(esami)) %>% 
  ungroup() %>% 
  filter(!Regione == "Non definita") %>% 
  left_join(sigla_pro %>%
              select(-c(Regione)), by = c("Provincia"= "Sigla"), suffix = c("_0", "_1")) %>% 
  select(Regione, Provincia_1, esami) %>% 
  mutate(Regione = toupper(Regione))

# num.groups <- p %>% select(Regione) %>% n_distinct()
colnames(p)
colnames(p) <- c("Regione",
                 "Provincia",
                 "Campioni")
# dummy.rows.mat <- matrix(rep(colnames(p), num.groups), nrow=num.groups, byrow=TRUE)
# dummy.rows.df <- as.data.frame(dummy.rows.mat, row.names=F, make.names=F) %>% janitor::row_to_names(1, remove_row = F)
# col.names <- as.factor(p$Regione)
# dummy.rows.df$Regione <- levels(col.names)
# rep <- rbind(dummy.rows.df, p)
# rep <- as_tibble(rep)

p %>%
  mutate(Provincia = case_when(
    Provincia == "Aosta/Aoste" ~ paste0("Aosta"),
    TRUE ~ paste0(Provincia)
  )) %>% 
  ggplot(aes(x = Campioni , y = reorder(Provincia, Campioni))) + 
  geom_bar(stat = "identity", fill = "lightsteelblue4", width = 0.5) +   #slategray3 - lightsteelblue4 - lightskyblue3
  geom_text(aes(label = Campioni), hjust = -.2, vjust = .5, size = 3.5, family = "Montserrat") +
  labs(title = "IZSLER - Campioni processati per Provincia di provenienza",
       subtitle = "marzo 2020 - settembre 2022",
       x = NULL,
       y = NULL) +
  theme_bw() +
  scale_x_sqrt(expand = c(0, 0),
                      limits = c(0, 490000)) +
  # scale_x_continuous(trans = "sqrt",
  #                    expand = c(0, 0),
  #                    limits = c(0, 480000)) +
  theme(
    text = element_text(family="Montserrat"),
    # plot.title = element_text(size = 13, face = "bold", family = "Montserrat"),
    # plot.subtitle = element_text(size = 11, family = "Montserrat"),
    axis.text.x = element_blank(),
    axis.text.y = element_text(size = 11),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_blank(),
    panel.border = element_rect(fill = NA, colour = "grey"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
    )

  
  
  
  
  
  

## 6* GT conferente----
s <- dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    #str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  filter(!Prova == "Agente eziologico") %>% 
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  #FILTRO SESTA DOMANDA - SUDDIVISIONE CAMPIONI PER CONFERENTE
  group_by(Conferente) %>% 
  #group_by(dtconf = lubridate::floor_date(dtconf, "month")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>%
  arrange(desc(esami)) %>% 
  ungroup() %>% 
  left_join(conf, by = c("Conferente"= "conferente")) %>%
  mutate(classificazione = case_when(
    classificazione == "ASST " ~ paste0("ASST"),
    TRUE ~ paste0(classificazione)
  )) %>% 
  group_by(classificazione) %>% 
  summarise(esami = sum(esami, na.rm = TRUE)) %>%
  filter(!classificazione == "da eliminare") %>% 
  arrange(desc(esami)) 


# num.groups <- p %>% select(Regione) %>% n_distinct()
colnames(s)
colnames(s) <- c("Conferente",
                 "Campioni")
# dummy.rows.mat <- matrix(rep(colnames(p), num.groups), nrow=num.groups, byrow=TRUE)
# dummy.rows.df <- as.data.frame(dummy.rows.mat, row.names=F, make.names=F) %>% janitor::row_to_names(1, remove_row = F)
# col.names <- as.factor(p$Regione)
# dummy.rows.df$Regione <- levels(col.names)
# rep <- rbind(dummy.rows.df, p)
# rep <- as_tibble(rep)

s %>%
  gt(
    #groupname_col = "Regione"
    ) %>%
  tab_header(
    title = "IZSLER - Campioni processati per tipo di conferente",
    subtitle = "marzo 2020 - settembre 2022"
    ) %>% 
  #tab_options(column_labels.hidden = T) %>% 
  tab_style(style = list(
    cell_text(align = "left")),
    locations = cells_title()) %>% 
  tab_style(style = list(
    cell_text(weight = "bold")),
    locations = cells_column_labels()) %>%
  cols_width(Conferente ~ px(175)
             ) %>% tab_options(table.width = px(350))%>%
  tab_style(
    style = list(
      cell_text(align = "right")
    ),
    locations = cells_body(
      columns = c("Campioni")
    )) %>% 
  opt_table_font(
    font = list(
      google_font(name = "Montserrat")
    )
  )
  

## 6* BARPLOT conferente----
s <- dt %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>%
  #PROVA
  mutate(Prova = case_when(
    str_detect(Prova, "Sequenziamento") ~ paste0("SARS-CoV-2: sequenziamento"),
    str_detect(Prova, "identificazione") ~ paste0("SARS-CoV-2: identificazione varianti"),
    #str_detect(Prova, "Agente eziologico") ~ paste0("SARS-CoV-2: agente eziologico"),
    TRUE ~ paste0(Prova)
  )) %>%
  filter(!Prova == "Agente eziologico") %>% 
  #MATERIALE
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    Materiale == "RNA" ~ paste0("RNA SARS-CoV-2"),
    TRUE ~ paste0(Materiale))) %>%
  filter(!Materiale %in% c("ALTRI MATERIALI", "espettorato", "FECI", "LAVAGGIO BRONCHIALE", "materiale vari")) %>% 
  #FILTRO SESTA DOMANDA - SUDDIVISIONE CAMPIONI PER CONFERENTE
  group_by(Conferente) %>% 
  #group_by(dtconf = lubridate::floor_date(dtconf, "month")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>%
  arrange(desc(esami)) %>% 
  ungroup() %>% 
  left_join(conf, by = c("Conferente"= "conferente")) %>%
  mutate(classificazione = case_when(
    classificazione == "ASST " ~ paste0("ASST"),
    TRUE ~ paste0(classificazione)
  )) %>% 
  group_by(classificazione) %>% 
  summarise(esami = sum(esami, na.rm = TRUE)) %>%
  filter(!classificazione == "da eliminare") %>% 
  arrange(desc(esami)) 

# num.groups <- p %>% select(Regione) %>% n_distinct()
colnames(s)
colnames(s) <- c("Conferente",
                 "Campioni")
# dummy.rows.mat <- matrix(rep(colnames(p), num.groups), nrow=num.groups, byrow=TRUE)
# dummy.rows.df <- as.data.frame(dummy.rows.mat, row.names=F, make.names=F) %>% janitor::row_to_names(1, remove_row = F)
# col.names <- as.factor(p$Regione)
# dummy.rows.df$Regione <- levels(col.names)
# rep <- rbind(dummy.rows.df, p)
# rep <- as_tibble(rep)

s %>% 
  mutate(Conferente = case_when(
    Conferente == "STRUTTURE SOCIOSANITARIE" ~ paste0("STRUTTURE\nSOCIOSANITARIE"),
    TRUE ~ paste0(Conferente)
  )) %>% 
  ggplot(aes(x = Campioni , y = reorder(Conferente, Campioni))) + 
  geom_bar(stat = "identity", fill = "lightsteelblue4", width = 0.5) +   #slategray3 - lightsteelblue4 - lightskyblue3
  geom_text(aes(label = Campioni), hjust = -.2, vjust = .5, size = 3.5, family = "Montserrat") +
  labs(title = "IZSLER - Campioni processati per tipo di conferente",
       subtitle = "marzo 2020 - settembre 2022",
       x = NULL,
       y = NULL) +
  theme_bw() +
  scale_x_sqrt(expand = c(0, 0),
                      limits = c(0, 850000)) +
  # scale_x_continuous(trans = "sqrt",
  #                    expand = c(0, 0),
  #                    limits = c(0, 480000)) +
  theme(
    text = element_text(family="Montserrat"),
    # plot.title = element_text(size = 13, face = "bold", family = "Montserrat"),
    # plot.subtitle = element_text(size = 11, family = "Montserrat"),
    axis.text.x = element_blank(),
    axis.text.y = element_text(size = 11),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_blank(),
    panel.border = element_rect(fill = NA, colour = "grey"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
    )



#PROVINCE----
sigla_pro <- read_xlsx(here("data", "processed", "sigle province.xlsx"))
bubble_pro <- dt %>% 
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    TRUE ~ paste0(Materiale))
    ) %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>% 
  #filter(Materiale %in% c("TAMPONE", "SALIVARE")) %>% 
  group_by(Regione, Provincia) %>% 
  #group_by(dtconf = lubridate::floor_date(dtconf, "month")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
  ungroup() %>%
  # mutate(Comune = case_when(
  #   str_detect(Comune, "Forl") ~ paste0("Forlì"),
  #   str_detect(Comune, "Cant") ~ paste0("Cantù"),
  #   TRUE ~ paste0(Comune)
  # )) %>% 
  left_join(sigla_pro %>%
              select(-c(Regione)), by = c("Provincia"= "Sigla"), suffix = c("_0", "_1"))

bubble_pro <- bubble_pro %>% 
  filter(!Regione == "Non definita")

#View(bubble_pro)

library(sf)
reg <- readRDS(here("data", "processed", "ITA_adm1.sf.rds"))
pro <- readRDS(here("data", "processed", "ITA_adm2.sf.rds"))
com <- readRDS(here("data", "processed", "ITA_adm3.sf.rds"))
sf::st_crs(reg) = 4326
sf::st_crs(pro) = 4326
sf::st_crs(com) = 4326

com1 <- com[com$NAME_1 %in% c("Emilia-Romagna", "Lombardia"),]
pro1 <- pro[pro$NAME_1 %in% c("Emilia-Romagna", "Lombardia"),]
reg1 <- reg[reg$NAME_1 %in% c("Emilia-Romagna", "Lombardia"),]

pro1 <- pro1 %>% mutate(NAME_2 = case_when(
  NAME_2 == "Mantua" ~ paste0("Mantova"),
  NAME_2 == "Reggio Nell'Emilia" ~ paste0("Reggio Emilia"),
  NAME_2 == "Monza and Brianza" ~ paste0("Monza e Brianza"),
  NAME_2 == "Forli' - Cesena" ~ paste0("Forlì - Cesena"),
  TRUE ~ paste0(NAME_2)))

pro1 <- pro1 %>%
  left_join(bubble_pro %>% 
              filter(Regione %in% c("Emilia Romagna", "Lombardia")), by = c("NAME_2"= "Provincia_1"))


pro1 <- pro1 %>% mutate(esami = ifelse(is.na(esami), 0, esami)) %>%
  # mutate(lng = sf::st_coordinates(st_centroid(pro1$geometry))[,1],
  #        lat = sf::st_coordinates(st_centroid(pro1$geometry))[,2])
  mutate(lng = map_dbl(geometry, ~st_point_on_surface(.x)[[1]]),
           lat = map_dbl(geometry, ~st_point_on_surface(.x)[[2]])) %>% 
  mutate(NAME_2 = case_when(
    NAME_2 == "Monza e Brianza" ~ paste0("Monza-Brianza"),
    NAME_2 == "Forlì - Cesena" ~ paste0("Forlì-Cesena"),
    TRUE ~ paste0(NAME_2)
  ))

#View(pro1)

# head(sort(pro1$esami, decreasing = F))
# bins <- c(0, 100, 1000, 5000, 10000, 50000, 150000, 250000, 450000)
# pal <- colorBin("OrRd", domain = pro1$esami, bins = bins)

head(sort(pro1$esami, decreasing = T))
bins <- c(0, 1000, 10000, 100000, 250000, 450000)
RColorBrewer::brewer.pal(9, "OrRd")[1:9]
vec <- RColorBrewer::brewer.pal(9, "OrRd")[c(1,3,5,7,9)]
pal <- colorBin(palette = vec, domain = pro1$esami, bins = bins)


m <- leaflet(pro1,
        height = 900,
        width = "100%",
        options = leafletOptions(zoomControl = FALSE,
                                 attributionControl = FALSE)) %>% 
  setView(10.63 ,44.93,zoom = 7.5) %>%
  #fitBounds(9, 44, 11, 46) %>% 
  #addTiles() %>% 
  addMapPane("background_map", zIndex = 410) %>%  # Level 1: bottom
  addMapPane("polygons", zIndex = 420) %>%        # Level 2: middle
  addMapPane("labels", zIndex = 430) %>%          # Level 3: top
  addProviderTiles(provider = "CartoDB.VoyagerNoLabels",
                   options = pathOptions(pane = "background_map")) %>%
  # addProviderTiles(provider = "Stamen.TerrainLabels", #CartoDB.VoyagerNoLabels - #Stamen.TerrainLabels - CartoDB.VoyagerOnlyLabels
  #                  options = pathOptions(pane = "labels")) %>%
  addPolygons(data = reg1,
              stroke = TRUE,
              fill = FALSE,
              weight = 3,
              opacity = 1,
              color = "black",
              dashArray = "1",
    options = pathOptions(pane = "polygons")
  ) %>% 
    # addPolygons(data = pro1,
    #           stroke = TRUE,
    #           fill = FALSE,
    #           weight = 0.5,
    #           opacity = 0.5,
    #           color = "black",
    #           dashArray = "1")
  addPolygons(data = pro1,
              label = as.character(pro1$NAME_2),
              stroke = TRUE,
              fillColor = ~pal(pro1$esami),
              weight = 1,
              opacity = 1,
              color = "black",
              dashArray = "1",
              fillOpacity = 0.7,
    options = pathOptions(pane = "polygons")
              # stroke = TRUE,
              # weight = 0.2,
              # opacity = 1,
              # color = "grey",
              # fillColor = ~pal(bubble$esami),
              # fillOpacity = ~bubble$esami / max(bubble$esami),
              # #color = ~pal(bubble$esami)
              ) %>% 
  addLegend(pal = pal,
            values = ~pro1$esami,
            opacity = 1,
            #bins = c(0, 100, 1000, 5000, 10000, 50000, 150000, 250000, 450000),
            title = "Esami eseguiti",
            position = "topright",
            labFormat = labelFormat(
              prefix = "",
              suffix = "",
              between = " - ",
              digits = 3,
              big.mark = "",
              transform = identity
              )) %>% 
  addLabelOnlyMarkers(data = pro1, ~lng, ~lat,
                      label = ~as.character(toupper(pro1$NAME_2)), 
                      labelOptions = labelOptions(
                      noHide = T,
                      direction = 'center',
                      textOnly = T,
                      style = list(
                      "font-family" = "Montserrat",
                      "color" = "black",
                      "font-weight" = "bold",
                      "font-size" = "8px"
                      #"text-shadow" = "0 0 5px #fff"
                      #"-webkit-text-stroke" = "2px #fff"
                      )))

m  
library(htmlwidgets)
library(webshot2)
saveWidget(m, "temp_pro.html", selfcontained = TRUE)
webshot2::webshot("temp_pro.html", file="mappa esami.png", cliprect="viewport")















#map si----
latlong <- readxl::read_xlsx(here("data", "processed", "geo_comuni.xlsx"))

bubble <- dt %>% 
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    TRUE ~ paste0(Materiale))
    ) %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>% 
  filter(Materiale %in% c("TAMPONE", "SALIVARE")) %>% 
  group_by(Regione, Provincia, Comune) %>% 
  #group_by(dtconf = lubridate::floor_date(dtconf, "month")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
  mutate(Comune = case_when(
    str_detect(Comune, "Forl") ~ paste0("Forlì"),
    str_detect(Comune, "Cant") ~ paste0("Cantù"),
    TRUE ~ paste0(Comune)
  )) %>% 
  left_join(latlong %>% 
              select(-c(istat)), by = c("Comune"= "comune"))
bubble <- bubble[-149,]

library(sf)
reg <- readRDS(here("data", "processed", "ITA_adm1.sf.rds"))
pro <- readRDS(here("data", "processed", "ITA_adm2.sf.rds"))
com <- readRDS(here("data", "processed", "ITA_adm3.sf.rds"))
sf::st_crs(reg) = 4326
sf::st_crs(pro) = 4326
sf::st_crs(com) = 4326

#vec <- bubble$Comune

com1 <- com[com$NAME_1 %in% c("Emilia-Romagna", "Lombardia"),]
pro1 <- pro[pro$NAME_1 %in% c("Emilia-Romagna", "Lombardia"),]
reg1 <- reg[reg$NAME_1 %in% c("Emilia-Romagna", "Lombardia"),]

#pal <- colorFactor(colors, bubble$esami)

# pal <- colorNumeric(palette = RColorBrewer::brewer.pal(9, "OrRd")[1:9], domain = bubble$esami)
# #YlOrRd
# RColorBrewer::brewer.pal(9, "OrRd")[4:9]
# RColorBrewer::brewer.pal(9, "Blues")[9:6]
# vec <- c(RColorBrewer::brewer.pal(9, "Blues")[9:7], RColorBrewer::brewer.pal(9, "OrRd")[4:9])
# pal <- colorNumeric(palette = vec, domain = bubble$esami)

head(sort(bubble$esami, decreasing = F))
bins <- c(0, 100, 500, 1000, 5000, 10000, 50000, 100000, 180000)
pal <- colorBin("YlOrRd", domain = bubble$esami, bins = bins)


m1 <- leaflet(bubble,
             height = 800,
             width = "100%",
             options = leafletOptions(zoomControl = FALSE,
                                      attributionControl = FALSE)) %>% 
  setView(10.631518337764917, 45.251473335912064, zoom = 7.5) %>%
  #fitBounds(9, 44, 11, 46) %>% 
  #addTiles() %>% 
  addMapPane("background_map", zIndex = 410) %>%  # Level 1: bottom
  addMapPane("polygons", zIndex = 420) %>%        # Level 2: middle
  addMapPane("labels", zIndex = 430) %>%          # Level 3: top
  addProviderTiles(provider = "CartoDB.PositronNoLabels",
                   options = pathOptions(pane = "background_map")) %>%
  addProviderTiles(provider = "Stamen.TerrainLabels", #Stamen.TerrainLabels - CartoDB.VoyagerOnlyLabels
                   options = pathOptions(pane = "labels")) %>%
  addPolygons(data = reg1,
              stroke = TRUE,
              fill = FALSE,
              weight = 3,
              opacity = 1,
              color = "grey",
              dashArray = "1",
    options = pathOptions(pane = "polygons")
  ) %>% 
    # addPolygons(data = pro1,
    #           stroke = TRUE,
    #           fill = FALSE,
    #           weight = 0.5,
    #           opacity = 0.5,
    #           color = "black",
    #           dashArray = "1")
  addPolygons(data = com1,
              stroke = TRUE,
              fillColor = ~pal(bubble$esami),
              weight = 0.5,
              opacity = 1,
              color = "grey",
              dashArray = "1",
              fillOpacity = 0.6,
    options = pathOptions(pane = "polygons")
                # stroke = TRUE,
              # weight = 0.2,
              # opacity = 1,
              # color = "grey",
              # fillColor = ~pal(bubble$esami),
              # fillOpacity = ~bubble$esami / max(bubble$esami),
              # #color = ~pal(bubble$esami)
              ) %>% 
  addLegend(pal = pal,
            values = ~bubble$esami,
            opacity = 1,
            #bins = c(30000,60000,90000,120000,150000,180000),
            title = "Esami eseguiti",
            position = "topright",
            labFormat = labelFormat(
              prefix = "",
              suffix = "",
              between = " - ",
              digits = 3,
              big.mark = "",
              transform = identity
              )) 
m1
library(htmlwidgets)
library(webshot)
saveWidget(m, "temp1.html", selfcontained = TRUE)
webshot("temp1.html", file = "Rplot.png")
  
# addLabelOnlyMarkers(data = bubble1, ~lng, ~lat,
  #                     label = ~as.character(bubble1$Comune), 
  #                     labelOptions = labelOptions(
  #                       noHide = T,
  #                       direction = 'top',
  #                       textOnly = T,
  #                       style = list(
  #                         "font-family" = "serif",
  #                         "font-style" = "bold",
  #                         "font-size" = "12px"
  #     )))

# bubble1 <- bubble %>% 
#   filter(esami > 1000)

































#map no----
latlong <- readxl::read_xlsx(here("data", "processed", "geo_comuni.xlsx"))

# library(GADMTools)
# com <- GADMTools::gadm_sp_loadCountries("ITA", level=3, basefile = "data/")$sp

bubble <- dt %>% 
  mutate(Materiale = case_when(
    str_detect(Materiale, "TAMPO") ~ paste0("TAMPONE"),
    str_detect(Materiale, "SALIVA") ~ paste0("SALIVARE"),
    TRUE ~ paste0(Materiale))
    ) %>%
  filter(dtconf < "2022-10-01") %>% 
  arrange(dtconf) %>% 
  filter(Materiale %in% c("TAMPONE", "SALIVARE")) %>% 
  group_by(Regione, Provincia, Comune) %>% 
  #group_by(dtconf = lubridate::floor_date(dtconf, "month")) %>%
  summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
  mutate(Comune = case_when(
    str_detect(Comune, "Forl") ~ paste0("Forlì"),
    str_detect(Comune, "Cant") ~ paste0("Cantù"),
    TRUE ~ paste0(Comune)
  )) %>% 
  left_join(latlong %>% 
              select(-c(istat)), by = c("Comune"= "comune"))
bubble <- bubble[-149,]


colors <- c("blue", "red")
pal <- colorFactor(colors, bubble$esami)


#https://learn.r-journalism.com/en/mapping/leaflet_maps/leaflet/
#https://rpubs.com/SalvadorW2/643223
#https://leaflet-extras.github.io/leaflet-providers/preview/
#https://github.com/leaflet-extras/leaflet-providers
leaflet() %>% 
  #addTiles() %>% 
  addProviderTiles(provider = "OpenStreetMap.HOT") %>% 
  #addPolygons(data = cp, stroke = TRUE, weight = 1, fillColor = "blue") %>% 
  
  #https://rstudio.github.io/leaflet/markers.html
  #https://leafletjs.com/examples/custom-icons/
  
  addCircles(data = bubble, ~lng, ~lat, weight = 5, #popup = ~ as.character(locality),
             radius = ~(esami/50), opacity = 5, color = ~pal(esami))      
               
  



#Nhttps://stackoverflow.com/questions/62886513/is-there-a-way-to-conditionally-vary-opacity-of-polygons-using-leaflet


#MAP----
ita <- readRDS(here("data", "processed", "gadm36_ITA_1_sp.rds"))
ita <- ms_simplify(ita, keep_shapes = TRUE)

cp <- ita
#cp <- readRDS(here("data", "processed", "cp.RDS"))




locations <- read_excel(here("data", "processed", "sampling_locations.xlsx"))

coords_italy <- locations %>% 
  filter(country=="Italy") %>% 
  relocate(country)
colnames(coords_italy) <- c("country", "locality", "lat", "long")
coords <- coords_italy
#coords <- readRDS(here("data", "processed", "coords.RDS"))

leaflet() %>% 
    addTiles() %>% 
    addPolygons(data = cp, stroke = TRUE, weight = 1, fillColor = "blue") %>% 
    #https://rstudio.github.io/leaflet/markers.html
    #https://leafletjs.com/examples/custom-icons/
    addMarkers(data = coords, ~long, ~lat, #popup = ~ as.character(locality),
               label = ~as.character(locality))



leaflet() %>% 
    addTiles() %>% 
    #addPolygons(data = cp, stroke = TRUE, weight = 1, fillColor = "blue") %>% 
  
    #https://rstudio.github.io/leaflet/markers.html
    #https://leafletjs.com/examples/custom-icons/
  
    addCircleMarkers(data = bubble, ~lng, ~lat, #popup = ~ as.character(locality),
                     radius = ~3, opacity = 5,
                     label = ~as.character(Comune))
