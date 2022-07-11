server<-function(input, output) {
  


output$agg <- renderUI({
 paste0("Dati aggiornati al:", format(as.Date(substr(max(covid$dtref, na.rm = TRUE), start = 1, stop = 11)), "%d-%m-%Y"))
})

output$aggBS <- renderUI({
  paste0("Dati aggiornati al:", format(as.Date(substr(max(covid$dtref, na.rm = TRUE), start = 1, stop = 11)), "%d-%m-%Y"))
})

output$aggPV <- renderUI({
  paste0("Dati aggiornati al:", format(as.Date(substr(max(covid$dtref, na.rm = TRUE), start = 1, stop = 11)), "%d-%m-%Y"))
})

output$aggMO <- renderUI({
  paste0("Dati aggiornati al:", format(as.Date(substr(max(covid$dtref, na.rm = TRUE), start = 1, stop = 11)), "%d-%m-%Y"))
})

output$aggAREG <- renderUI({
  paste0("Dati aggiornati al:", format(as.Date(substr(max(covid$dtref, na.rm = TRUE), start = 1, stop = 11)), "%d-%m-%Y"))
})

 
  
 
# Situazione Generale----
## Tabella----
  output$tabella <-  renderDataTable( 
    server = TRUE,
    class = 'cell-border stripe', rownames=FALSE,
    options = list(dom="Brtip", pageLength = 10,
                                          searching = TRUE,paging = TRUE,autoWidth = TRUE),
    covid 
     
  )

 

output$downloadData <- downloadHandler(
  filename = function() {
    paste("data-", Sys.Date(), ".csv", sep="")
  },
  content = function(file) {
    write.csv(covid, file)
  }
)

  
## Plot----
  output$serie <- renderPlotly({  
    
     # if(input$Regione == "Dati Complessivi") {
      serie1()
      
    })
  
      
    
  
## Valuebox----



### numero ----
  output$tottamp <- renderText({
    
    #if(input$Regione == "Dati Complessivi") {
    
    tot <-covid %>% 
            mutate(anno = year(dtacc)) %>% 
             filter(Prova %in% c("SARS-CoV-2: agente eziologico")) %>% 
               summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) 
   
    tot$esami
  })

### media ----
  output$medg<- renderText({  
     
     #if(input$Regione == "Dati Complessivi") {
     
    media <-  covid %>% 
       mutate(anno = year(dtacc)) %>% 
        filter(Prova %in% c("SARS-CoV-2: agente eziologico") ) %>% 
         group_by(dtacc) %>% 
         summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
         summarise(media = round(mean(esami),2))
  
     media$media
     
     
   })
  
###varianti----
   output$vart<- renderText({
     
    # if(input$Regione == "Dati Complessivi"){
       var <- covid %>% 
         mutate(anno = year(dtacc)) %>% 
         filter(Prova %in% c( "SARS-CoV-2: identificazione varianti", 
                              "SARS-CoV-2: identificazione varianti N501Y") ) %>% 
         summarise(var = sum(Tot_Eseguiti, na.rm = TRUE))
       var$var
       
       
   })
     
###sequenziamento----
 
   
output$seqt<- renderText({
 # if(input$Regione == "Dati Complessivi"){
    seq <- covid %>% 
      mutate(anno = year(dtacc)) %>% 
      filter(Prova %in% c( "Sequenziamento acidi nucleici", 
                           "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
                           "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") ) %>% 
      summarise(seq = sum(Tot_Eseguiti, na.rm = TRUE))
    seq$seq
  
})

###tempi----

output$tref <- renderText({
  tempi <- covid %>% 
    filter(Prova %in% c("SARS-CoV-2: agente eziologico")) %>% 
    mutate(tempiref=(interval(dtacc, dtprimoRDP))/ddays(1), 
           tempiref = factor(tempiref)) %>% 
    group_by(tempiref) %>% 
    summarise(n = n()) %>%
    mutate(freq = round(100*(n / sum(n)), 0), 
           rank = rank(row_number()), 
           cums = cumsum(freq)) %>% 
    filter(rank==2) %>% 
    select(cums)
  tempi$cums

})

     
     
     
     
   
   
   
  
# Laboratori Covid----

## Laboratorio Brescia----
### Tabella----
output$tabella2 <- renderDataTable(
  server = TRUE,
  class = 'cell-border stripe', rownames=FALSE,
  options = list(dom="Brtip", pageLength = 10,
                 searching = TRUE,paging = TRUE,autoWidth = TRUE),

  
  covid %>% 
                 filter(Reparto == "Reparto Tecnologie Biologiche Applicate")
  
)

output$downloadDatabs <- downloadHandler(
  filename = function() {
    paste("data-", Sys.Date(), ".csv", sep="")
  },
  content = function(file) {
    write.csv((covid%>% 
                filter(Reparto == "Reparto Tecnologie Biologiche Applicate")), file)
  }
)

### Plot----
output$serieBS<- renderPlotly({  
    serie3(reparto = "Reparto Tecnologie Biologiche Applicate")
})

### ValueBox----


##### numero----
output$tottampBS <- renderText({
  
 
    
    tot <-covid %>% 
      mutate(anno = year(dtacc)) %>% 
      filter(Prova %in% c("SARS-CoV-2: agente eziologico")  & Reparto == "Reparto Tecnologie Biologiche Applicate") %>% 
      summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) 
    
    tot$esami
})



##### media----
output$medgBS<- renderText({  
    media <-  covid %>% 
      mutate(anno = year(dtacc)) %>% 
      filter(Prova %in% c("SARS-CoV-2: agente eziologico") & Reparto == "Reparto Tecnologie Biologiche Applicate") %>% 
      group_by(dtacc) %>% 
      summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
      summarise(media = round(mean(esami), 2))
    media$media
})
    
##### varianti----

output$varbs<- renderText({
varbs <- covid %>% 
  mutate(anno = year(dtacc)) %>% 
  filter(Prova %in% c( "SARS-CoV-2: identificazione varianti", 
                       "SARS-CoV-2: identificazione varianti N501Y")  & Reparto == "Reparto Tecnologie Biologiche Applicate") %>% 
  summarise(var = sum(Tot_Eseguiti, na.rm = TRUE))
varbs$var
})


##### sequenziamento----


output$seqbs<- renderText({
seqbs <- covid %>% 
  mutate(anno = year(dtacc)) %>% 
  filter(Prova %in% c( "Sequenziamento acidi nucleici", 
                       "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
                       "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") & Reparto == "Reparto Tecnologie Biologiche Applicate") %>% 
  summarise(seq = sum(Tot_Eseguiti, na.rm = TRUE))
seqbs$seq
})

###tempi----

output$trefbs <- renderText({
  tempi <- covid %>% 
    filter(Prova %in% c("SARS-CoV-2: agente eziologico") 
           &  Reparto == "Reparto Tecnologie Biologiche Applicate") %>% 
    mutate(tempiref=(interval(dtacc, dtprimoRDP))/ddays(1), 
           tempiref = factor(tempiref)) %>% 
    group_by(tempiref) %>% 
    summarise(n = n()) %>%
    mutate(freq = round(100*(n / sum(n)), 0), 
           rank = rank(row_number()), 
           cums = cumsum(freq)) %>% 
    filter(rank==2) %>% 
    select(cums)
  tempi$cums
  
})



##Laboratorio PV----

### Tabella----
output$tabella3 <- renderDataTable(      server = TRUE,
                                         class = 'cell-border stripe', rownames=FALSE,
                                         options = list(dom="Brtip", pageLength = 10,
                                                        searching = TRUE,paging = TRUE,autoWidth = TRUE),
               covid %>% 
               filter(Reparto == "Sede Territoriale di Pavia")
  
)

output$downloadDataPV  <- downloadHandler(
  filename = function() {
    paste("data-", Sys.Date(), ".csv", sep="")
  },
  content = function(file) {
    write.csv((covid %>% 
                 filter(Reparto == "Sede Territoriale di Pavia")), file)
  }
)

### Plot----
output$seriePV<- renderPlotly({  
  serie3(reparto = "Sede Territoriale di Pavia")
})

### ValueBox----


##### numero----
output$tottampPV <- renderText({
  
  
  
  tot <-covid %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(Prova %in% c( "SARS-CoV-2: agente eziologico")  & Reparto == "Sede Territoriale di Pavia") %>% 
    summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) 
  
  tot$esami
})



##### media----
output$medgPV<- renderText({  
  media <-  covid %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(Prova %in% c(  "SARS-CoV-2: agente eziologico") & Reparto == "Sede Territoriale di Pavia") %>% 
    group_by(dtacc) %>% 
    summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
    summarise(media = round(mean(esami), 1))
  media$media
})

##### varianti----

output$varPV<- renderText({
  varPV <- covid %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(Prova %in% c( "SARS-CoV-2: identificazione varianti", 
                         "SARS-CoV-2: identificazione varianti N501Y")  & Reparto == "Sede Territoriale di Pavia") %>% 
    summarise(var = sum(Tot_Eseguiti, na.rm = TRUE))
  varPV$var
})


##### sequenziamento----


output$seqPV<- renderText({
  seqPV <- covid %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(Prova %in% c( "Sequenziamento acidi nucleici", 
                         "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
                         "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") & Reparto == "Sede Territoriale di Pavia") %>% 
    summarise(seq = sum(Tot_Eseguiti, na.rm = TRUE))
  seqPV$seq
})

###tempi----

output$trefpv <- renderText({
  tempi <- covid %>% 
    filter(Prova %in% c(  "SARS-CoV-2: agente eziologico") 
           &  Reparto == "Sede Territoriale di Pavia") %>% 
    mutate(tempiref=(interval(dtacc, dtprimoRDP))/ddays(1), 
           tempiref = factor(tempiref)) %>% 
    group_by(tempiref) %>% 
    summarise(n = n()) %>%
    mutate(freq = round(100*(n / sum(n)), 0), 
           rank = rank(row_number()), 
           cums = cumsum(freq)) %>% 
    filter(rank==2) %>% 
    select(cums)
  tempi$cums
  
})


##Laboratorio MO----

### Tabella----
output$tabella4 <- renderDataTable( 
  server = TRUE,
  class = 'cell-border stripe', rownames=FALSE,
  options = list(dom="Brtip", pageLength = 10,
                 searching = TRUE,paging = TRUE,autoWidth = TRUE),
  
  covid %>% 
   filter(Reparto == "Sede Territoriale di Modena")
  
)

output$downloadDatamo  <- downloadHandler(
  filename = function() {
    paste("data-", Sys.Date(), ".csv", sep="")
  },
  content = function(file) {
    write.csv((  covid %>% 
                   filter(Reparto == "Sede Territoriale di Modena")), file)
  }
)

### Plot----
output$serieMO<- renderPlotly({  
  serie3(reparto = "Sede Territoriale di Modena")
})

### ValueBox----


##### numero----
output$tottampMO <- renderText({
  
  
  
  tot <-covid %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(Prova %in% c(  "SARS-CoV-2: agente eziologico")  & Reparto == "Sede Territoriale di Modena") %>% 
    summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) 
  
  tot$esami
})



##### media----
output$medgMO<- renderText({  
  media <-  covid %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(Prova %in% c(  "SARS-CoV-2: agente eziologico") & Reparto == "Sede Territoriale di Modena") %>% 
    group_by(dtacc) %>% 
    summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
    summarise(media = round(mean(esami), 1))
  media$media
})

##### varianti----

output$varMO<- renderText({
  varMO <- covid %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(Prova %in% c( "SARS-CoV-2: identificazione varianti", 
                         "SARS-CoV-2: identificazione varianti N501Y") & Reparto == "Sede Territoriale di Modena") %>% 
    summarise(var = sum(Tot_Eseguiti, na.rm = TRUE))
  varMO$var
})


##### sequenziamento----


output$seqMO<- renderText({
  seqMO <- covid %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(Prova %in% c( "Sequenziamento acidi nucleici", 
                         "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
                         "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") & Reparto == "Sede Territoriale di Modena") %>% 
    summarise(seq = sum(Tot_Eseguiti, na.rm = TRUE))
  seqMO$seq
})

###tempi----

output$trefmo <- renderText({
  tempi <- covid %>% 
    filter(Prova %in% c(  "SARS-CoV-2: agente eziologico") 
           &  Reparto == "Sede Territoriale di Modena") %>% 
    mutate(tempiref=(interval(dtacc, dtprimoRDP))/ddays(1), 
           tempiref = factor(tempiref)) %>% 
    group_by(tempiref) %>% 
    summarise(n = n()) %>%
    mutate(freq = round(100*(n / sum(n)), 0), 
           rank = rank(row_number()), 
           cums = cumsum(freq)) %>% 
    filter(rank==2) %>% 
    select(cums)
  tempi$cums
  
})




#AREG----
## Tabella----
output$tabellaAREG <-  renderDataTable( 
  server = TRUE,
  class = 'cell-border stripe', rownames=FALSE,
  options = list(dom="Brtip", pageLength = 10,
                 searching = TRUE,paging = TRUE,autoWidth = TRUE),
  covid %>% 
    filter(Finalità == "Varianti SARS-CoV2")
  
)



output$downloadDataAREG <- downloadHandler(
  filename = function() {
    paste("data-", Sys.Date(), ".csv", sep="")
  },
  content = function(file) {
    vroom::vroom_write(covid, file)
  }
)

## Plot----

output$serieAREG<- renderPlotly({  
  serie4(reparto = "Analisi del rischio ed epidemiologia genomica")
})

## Sequenziamento----

output$seqAREG<- renderText({
  seqAREG <- covid %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(Prova %in% c( "Sequenziamento acidi nucleici", 
                         "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
                         "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") & Reparto == "Analisi del rischio ed epidemiologia genomica") %>% 
    summarise(seq = sum(Tot_Eseguiti, na.rm = TRUE))
  seqAREG$seq
})

## tempi di refertazione----

output$trefareg <- renderText({
  tempi <- covid %>% 
      filter(Prova %in% c( "Sequenziamento acidi nucleici",
                           "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
                           "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") & Reparto == "Analisi del rischio ed epidemiologia genomica") %>%
      mutate(tempiref=(interval(dtacc, dtprimoRDP))/ddays(1)) %>% 
    summarise(mediana = median(tempiref, na.rm = TRUE))
  tempi$mediana
})
 


  # covid %>% 
  #   filter(Prova %in% c( "Sequenziamento acidi nucleici", 
  #                        "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
  #                        "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") & Reparto == "Analisi del rischio ed epidemiologia genomica") %>%
  #   mutate(tempiref=(interval(dtacc, dtref))/ddays(1)) %>% 
  # ggplot(
  #   aes(x = tempiref)
  # )+
  # geom_histogram(col = "blue")+
  # xlim(0, 50)+ 
  # theme_bw()+
  # labs(title =  "distribuzione tempi di refertazione", x = "giorni")
    
  




 
#TABELLA PIVOT----

output$pivot <- renderRpivotTable({
  
  if(input$dt == "Data di Accettazione"){  
  
  
  
  rpivotTable(covid %>% 
                filter(dtacc >= input$datarange[1] & dtacc <= input$datarange[2]), 
               #select( ),
              aggregatorName="Sum", vals = "Tot_Eseguiti",
               onRefresh = htmlwidgets::JS(
                 "function(config) {
                        Shiny.onInputChange('mypivot', document.getElementById('pivot').innerHTML); }"))
    
  }else
    
    if(input$dt == "Data di Refertazione"){
      rpivotTable(covid %>% 
                    filter(dtref >= input$datarange[1] & dtref <= input$datarange[2]), 
                  #select( ),
                  aggregatorName="Sum", vals = "Tot_Eseguiti",
                  onRefresh = htmlwidgets::JS(
                    "function(config) {
                        Shiny.onInputChange('pivot', document.getElementById('mypivot').innerHTML); }"))
    }
    
    
})


# pivot_tbl <- eventReactive(input$mypivot, {
#   tryCatch({
#     input$mypivot %>%
#       read_html %>%
#       html_table(fill = TRUE) %>%
#       .[[2]]
#   }, error = function(e) {
#     return()
#   })
# })
# 
# observe({
#   if (is.data.frame(pivot_tbl()) && nrow(pivot_tbl()) > 0) {
#     shinyjs::enable("download_pivot")
#   } else {
#     shinyjs::disable("download_pivot")
#   }
# })
# 
# output$download_pivot <- downloadHandler(
#   filename = function() {
#     "pivot.xlsx"
#   },
#   content = function(file) {
#     writexl::write_xlsx(as.data.frame(pivot_tbl()), path =file)
#   }
# )





}



  



