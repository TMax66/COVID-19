library(tidyverse)
library(here)
library(DBI)
library(odbc)
library(lubridate)


conn <- DBI::dbConnect(odbc::odbc(), Driver = "SQL Server", Server = "dbprod02.izsler.it",Database = "DarwinSqlSE", Port = 1433)


query <- "SELECT  [Anno], 
                  [Numero], 
                  [IdAccett],
                  [Esito1],
                  [Esito1_Nom],
                  [Esito2],
                  [Numero_Campione],
                  [DataReferto],
                  [DataFirma],
                  [OraFirma],
                  [DataRicezioneCampione]
FROM [DarwinSqlSE].[dbo].[Prg_Estrazione_Covid19]"



covid <- conn%>% tbl(sql(query)) %>% as_tibble()

saveRDS(covid, "COVID.RDS")


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



