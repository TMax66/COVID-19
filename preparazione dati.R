library(tidyverse)
library(here)
library(DBI)
library(odbc)
library(lubridate)


#conn <- DBI::dbConnect(odbc::odbc(), Driver = "ODBC Driver 17 for SQL Server", Server = "dbprod02.izsler.it",Database = "IZSLER", Port = 1433, uid="user_cogep", pwd="!d44grki654hjS")

conn <- DBI::dbConnect(odbc::odbc(), Driver = "SQL Server", Server = "dbprod02.izsler.it",Database = "IZSLER", Port = 1433)
# #
# #
queryCovid <- ("SELECT        Conferimenti.Numero AS nconf, Anag_TipoConf.Descrizione AS tipoconf, Anag_Comuni.Provincia, Anag_Referenti.Ragione_Sociale AS Conferente, Anag_Finalita.Descrizione AS Finalità, Anag_Regioni.Descrizione AS Regione, 
                         Anag_Comuni.Descrizione AS Comune, Anag_Materiali.Descrizione AS Materiale, Anag_Prove.Descrizione AS Prova, Anag_Referenti.Codice AS codiceconf, Conferimenti.Data AS dtconf, Conferimenti.Data_Accettazione AS dtacc, 
                         RDP_Date_Emissione.Data_RDP AS dtref, Anag_Reparti.Descrizione AS Reparto, Esami_Aggregati.Tot_Eseguiti, dbo_Anag_Referenti_DestFatt.Ragione_Sociale, Anag_Referenti_1.Pubblico
FROM            Anag_TipoConf INNER JOIN
                         Conferimenti ON Anag_TipoConf.Codice = Conferimenti.Tipo INNER JOIN
                         Anag_Comuni ON Anag_Comuni.Codice = Conferimenti.Luogo_Prelievo LEFT OUTER JOIN
                         Anag_Regioni ON Anag_Regioni.Codice = Anag_Comuni.Regione INNER JOIN
                         Anag_Referenti ON Conferimenti.Conferente = Anag_Referenti.Codice LEFT OUTER JOIN
                         Esami_Aggregati ON Conferimenti.Anno = Esami_Aggregati.Anno_Conferimento AND Conferimenti.Numero = Esami_Aggregati.Numero_Conferimento LEFT OUTER JOIN
                         Nomenclatore_MP ON Esami_Aggregati.Nomenclatore = Nomenclatore_MP.Codice LEFT OUTER JOIN
                         Nomenclatore_Settori ON Nomenclatore_MP.Nomenclatore_Settore = Nomenclatore_Settori.Codice LEFT OUTER JOIN
                         Nomenclatore ON Nomenclatore_Settori.Codice_Nomenclatore = Nomenclatore.Chiave LEFT OUTER JOIN
                         Anag_Prove ON Nomenclatore.Codice_Prova = Anag_Prove.Codice LEFT OUTER JOIN
                         Programmazione_Finalita ON Esami_Aggregati.Anno_Conferimento = Programmazione_Finalita.Anno_Conferimento AND Esami_Aggregati.Numero_Conferimento = Programmazione_Finalita.Numero_Conferimento AND 
                         Esami_Aggregati.Codice = Programmazione_Finalita.Codice LEFT OUTER JOIN
                         Anag_Finalita ON Programmazione_Finalita.Finalita = Anag_Finalita.Codice LEFT OUTER JOIN
                         Laboratori_Reparto ON Esami_Aggregati.RepLab_analisi = Laboratori_Reparto.Chiave LEFT OUTER JOIN
                         Anag_Reparti ON Laboratori_Reparto.Reparto = Anag_Reparti.Codice LEFT OUTER JOIN
                         Anag_Laboratori ON Laboratori_Reparto.Laboratorio = Anag_Laboratori.Codice LEFT OUTER JOIN
                         Anag_Referenti AS dbo_Anag_Referenti_DestFatt ON Conferimenti.Dest_Fattura = dbo_Anag_Referenti_DestFatt.Codice LEFT OUTER JOIN
                         Anag_Materiali ON Anag_Materiali.Codice = Conferimenti.Codice_Materiale INNER JOIN
                         Conferimenti_Finalita ON Conferimenti.Anno = Conferimenti_Finalita.Anno AND Conferimenti.Numero = Conferimenti_Finalita.Numero INNER JOIN
                         Anag_Finalita AS dbo_Anag_Finalita_Confer ON Conferimenti_Finalita.Finalita = dbo_Anag_Finalita_Confer.Codice INNER JOIN
                         Anag_Referenti AS Anag_Referenti_1 ON Anag_Comuni.Codice = Anag_Referenti_1.Comune LEFT OUTER JOIN
                         RDP_Date_Emissione ON RDP_Date_Emissione.Anno = Conferimenti.Anno AND RDP_Date_Emissione.Numero = Conferimenti.Numero
WHERE        (Laboratori_Reparto.Laboratorio > 1) AND (Esami_Aggregati.Esame_Altro_Ente = 0) AND (Esami_Aggregati.Esame_Altro_Ente = 0) AND (dbo_Anag_Finalita_Confer.Descrizione IN ('Emergenza COVID-19', 'Varianti SARS-CoV2')) 
                         AND (Anag_Prove.Descrizione NOT IN ('Motivazione di inidoneità campione', 'Motivi di mancata esecuzione di prove richieste', 'Motivi di riemissione del Rapporto di Prova', 'Note alle prove', 
                         'Opinioni ed interpretazioni -non oggetto dell''accredit. ACCREDIA'))"
)







#
#
covid <- conn%>% tbl(sql(queryCovid)) %>% as_tibble()

covid[,"Comune"] <- sapply(covid[, "Comune"], iconv, from = "latin1", to = "UTF-8", sub = "")

covid <- covid %>% 
  mutate(anno = year(dtacc))
#
saveRDS(covid, here("data", "processed",  "covid.rds"))

