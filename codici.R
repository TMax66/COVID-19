
library(tidyverse)
library(here)
library(DBI)
library(odbc)
library(lubridate)


conn <- DBI::dbConnect(odbc::odbc(), Driver = "SQL Server", Server = "dbprod02.izsler.it",Database = "DarwinSqlSE", Port = 1433)


query <- "SELECT DISTINCT 
                dbo.Conferimenti.Anno, 
                dbo.Conferimenti.Numero AS NumeroConferimento, 
                dbo.Anag_Prove.Codice AS Codice_Prova, 
                dbo.Anag_Prove.Descrizione AS Prova, 
                dbo.Anag_Tecniche.Descrizione AS Tecnica, 
                dbo.Risultati_Analisi.Numero_Campione, 
                dbo.Nomenclatore_Range.ModEspr, 
                dbo.Nomenclatore_Range.ModEspr2, 
                dbo.Anag_Reparti.Descrizione AS Reparto, 
                dbo.Anag_Laboratori.Descrizione AS LaboratorioAnalisi, 
                CONVERT(VARCHAR(10), dbo.Programmazione.Data_Inizio_Analisi, 111) AS Data_Inizio_Analisi, 
                CONVERT(VARCHAR(10), dbo.Programmazione.Data_Fine_Analisi, 111) AS Data_Fine_Analisi, 
                dbo.Conferimenti.Conferimento_Chiuso
FROM 
                dbo.Conferimenti 
                LEFT OUTER JOIN dbo.Conferimenti_Finalita ON dbo.Conferimenti.Anno = dbo.Conferimenti_Finalita.Anno AND dbo.Conferimenti.Numero = dbo.Conferimenti_Finalita.Numero 
                LEFT OUTER JOIN dbo.Programmazione ON dbo.Conferimenti.Anno = dbo.Programmazione.Anno_Conferimento AND dbo.Conferimenti.Numero = dbo.Programmazione.Numero_Conferimento 
                LEFT OUTER JOIN dbo.Nomenclatore_MP ON dbo.Programmazione.Nomenclatore = dbo.Nomenclatore_MP.Codice 
                LEFT OUTER JOIN dbo.Nomenclatore_Settori ON dbo.Nomenclatore_MP.Nomenclatore_Settore = dbo.Nomenclatore_Settori.Codice 
                LEFT OUTER JOIN dbo.Nomenclatore ON dbo.Nomenclatore_Settori.Codice_Nomenclatore = dbo.Nomenclatore.Chiave 
                LEFT OUTER JOIN dbo.Anag_Prove ON dbo.Nomenclatore.Codice_Prova = dbo.Anag_Prove.Codice 
                LEFT OUTER JOIN dbo.Anag_Tecniche ON dbo.Nomenclatore.Codice_Tecnica = dbo.Anag_Tecniche.Codice 
                LEFT OUTER JOIN dbo.Risultati_Analisi ON dbo.Programmazione.Anno_Conferimento = dbo.Risultati_Analisi.Anno_Conferimento AND dbo.Programmazione.Numero_Conferimento = dbo.Risultati_Analisi.Numero_Conferimento AND dbo.Programmazione.Codice = dbo.Risultati_Analisi.Codice 
                LEFT OUTER JOIN dbo.Laboratori_Reparto AS Laboratori_Reparto1 ON dbo.Programmazione.RepLab_analisi = Laboratori_Reparto1.Chiave 
                LEFT OUTER JOIN dbo.Anag_Laboratori ON Laboratori_Reparto1.Laboratorio = dbo.Anag_Laboratori.Codice 
                LEFT OUTER JOIN dbo.Anag_Reparti ON Laboratori_Reparto1.Reparto = dbo.Anag_Reparti.Codice 
                LEFT OUTER JOIN dbo.Anag_Referenti ON dbo.Conferimenti.Proprietario = dbo.Anag_Referenti.Codice 
                LEFT OUTER JOIN dbo.Nomenclatore_Range ON dbo.Risultati_Analisi.Range = dbo.Nomenclatore_Range.Codice 
                LEFT OUTER JOIN dbo.Anag_Specie ON dbo.Conferimenti.Codice_Specie = dbo.Anag_Specie.Codice 
WHERE
                (dbo.Conferimenti.Anno >= 2021) 
                AND (dbo.Conferimenti_Finalita.Finalita = 1236)
"



covid <- conn%>% tbl(sql(query)) %>% as_tibble()

#saveRDS(covid, "COVID.RDS")

camp <- readRDS("COVID.RDS")

covid <- readRDS(here("data", "processed", "covid.rds"))


covid$ID <- paste0(covid$anno, "/", covid$nconf)
camp$ID <- paste0(camp$Anno, "/", camp$Numero)

covid <- covid %>% 
  select( -Tot_Eseguiti)


covid %>% 
  left_join(camp, by="ID") %>% View()


library(readxl)
library(tidyverse)
bs <- read_excel("data/bs30.xlsx")
bs$nconf <- substr(bs$`ID accettazione`, start = 6, stop = 11 )

 

bs %>% 
  group_by(nconf) %>% 
  summarise(esami = n()) %>% View()
  





conferimenti <- unique(factor(bs29$nconf))

















covid %>%
  filter(Reparto== "Analisi del rischio ed epidemiologia genomica" & anno == 2021) %>%
  
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
                y = esami), alpha = 1/5)



