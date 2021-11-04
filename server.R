server<-function(input, output) {
  
# Situazione Generale----

  
  
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


## Tabella----
  output$tabella <- renderDataTable( 
    server = FALSE,
    class = 'cell-border stripe', rownames=FALSE,
    extensions = 'Buttons',options = list(dom="Brtip", pageLength = 10,
                                          searching = FALSE,paging = TRUE,autoWidth = TRUE,
                                          buttons = c('excel')),
    
    if(input$Regione == "Dati Complessivi") {
    
      covid %>% 
                filter(tipoconf == "Gratuito" & anno == 2021)
    } else
    
    if(input$Regione == "Lombardia"){
    covid %>% 
                   filter(tipoconf == "Gratuito" & anno == 2021 & Regione == "Lombardia")
      
    } else
    
      if(input$Regione == "Emilia Romagna"){
     covid %>% 
                     filter(tipoconf == "Gratuito" & anno == 2021 & Regione == "Emilia Romagna")
      }
    
  )
  
## Plot----
  output$serie <- renderPlotly({  
    
      if(input$Regione == "Dati Complessivi") {
      serie1()
      } else  
      if(input$Regione == "Lombardia") {  
      serie2(regione = "Lombardia")
      } else
      if(input$Regione == "Emilia Romagna")
        {
        serie2(regione = "Emilia Romagna")
        }   
    })
  
      
    
  
## Valuebox----
  
### numero ----
  output$tottamp <- renderText({
    
    if(input$Regione == "Dati Complessivi") {
    
    tot <-covid %>% 
            mutate(anno = year(dtacc)) %>% 
             filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021) %>% 
               summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) 
   
    tot$esami
    
    } else 
      
      if(input$Regione == "Lombardia") { 
        
        tot <-covid %>% 
          filter(Regione == "Lombardia") %>% 
          mutate(anno = year(dtacc)) %>% 
          filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021) %>% 
          summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) 
        
        tot$esami
        
        } else
          
        if(input$Regione == "Emilia Romagna") {
          
          tot <-covid %>% 
            filter(Regione == "Emilia Romagna") %>% 
          mutate(anno = year(dtacc)) %>% 
            filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021) %>% 
            summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) 
          
          tot$esami
          
        }
    
  })

### media ----
  output$medg<- renderText({  
     
     if(input$Regione == "Dati Complessivi") {
     
    media <-  covid %>% 
       mutate(anno = year(dtacc)) %>% 
        filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021) %>% 
         group_by(dtacc) %>% 
         summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
         summarise(media = round(mean(esami),2))
  
     media$media
     
     } else
       
       if(input$Regione == "Lombardia") {
         
         media <-  covid %>% 
           filter(Regione == "Lombardia") %>% 
           mutate(anno = year(dtacc)) %>% 
           filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021) %>% 
           group_by(dtacc) %>% 
           summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
           summarise(media = mean(esami))
         media$media
       } else
         
      if(input$Regione == "Emilia Romagna") { 
        
        media <-  covid %>% 
          filter(Regione == "Emilia Romagna") %>% 
          mutate(anno = year(dtacc)) %>% 
        filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021) %>% 
          group_by(dtacc) %>% 
          summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
          summarise(media = mean(esami))
        media$media
        }
   })
  
###varianti----
   output$vart<- renderText({
     
     if(input$Regione == "Dati Complessivi"){
       var <- covid %>% 
         mutate(anno = year(dtacc)) %>% 
         filter(Prova %in% c( "SARS-CoV-2: identificazione varianti", 
                              "SARS-CoV-2: identificazione varianti N501Y") & anno == 2021) %>% 
         summarise(var = sum(Tot_Eseguiti, na.rm = TRUE))
       var$var
       
         } else
           
      if(input$Regione == "Lombardia") {
        var <- covid %>% 
          filter(Regione == "Lombardia") %>% 
          mutate(anno = year(dtacc)) %>% 
          filter(Prova %in% c( "SARS-CoV-2: identificazione varianti", 
                               "SARS-CoV-2: identificazione varianti N501Y") & anno == 2021) %>% 
          summarise(var = sum(Tot_Eseguiti, na.rm = TRUE))
        var$var
      } else
        
        if(input$Regione == "Emilia Romagna") {
          
          var <- covid %>% 
            filter(Regione == "Emilia Romagna") %>% 
            mutate(anno = year(dtacc)) %>% 
            filter(Prova %in% c( "SARS-CoV-2: identificazione varianti", 
                                 "SARS-CoV-2: identificazione varianti N501Y") & anno == 2021) %>% 
            summarise(var = sum(Tot_Eseguiti, na.rm = TRUE))
          var$var
        }
     
   })
     
###sequenziamento----
 
   
output$seqt<- renderText({
  if(input$Regione == "Dati Complessivi"){
    seq <- covid %>% 
      mutate(anno = year(dtacc)) %>% 
      filter(Prova %in% c( "Sequenziamento acidi nucleici", 
                           "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
                           "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") & anno == 2021) %>% 
      summarise(seq = sum(Tot_Eseguiti, na.rm = TRUE))
    seq$seq
  } else
    if(input$Regione == "Lombardia"){
      seq <- covid %>% 
        filter(Regione == "Lombardia") %>% 
        mutate(anno = year(dtacc)) %>% 
        filter(Prova %in% c( "Sequenziamento acidi nucleici", 
                             "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
                             "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") & anno == 2021) %>% 
        summarise(seq = sum(Tot_Eseguiti, na.rm = TRUE))
      seq$seq
    } else
      if(input$Regione == "Emilia Romagna"){
        seq <- covid %>% 
          filter(Regione == "Emilia Romagna") %>% 
          mutate(anno = year(dtacc)) %>% 
          filter(Prova %in% c( "Sequenziamento acidi nucleici", 
                               "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
                               "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") & anno == 2021) %>% 
          summarise(seq = sum(Tot_Eseguiti, na.rm = TRUE))
        seq$seq 
      }

})
     
     
     
     
     
   
   
   
  
# Laboratori Covid----

## Laboratorio Brescia----
### Tabella----
output$tabella2 <- renderDataTable(
server = FALSE,
class = 'cell-border stripe', rownames=FALSE,
extensions = 'Buttons',options = list(dom="Brtip", pageLength = 10,
                                      searching = FALSE,paging = TRUE,autoWidth = TRUE,
                                      buttons = c('excel')),

  
  covid %>% 
                 filter(tipoconf == "Gratuito" & anno == 2021 & Reparto == "Reparto Tecnologie Biologiche Applicate")
  
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
      filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021 & Reparto == "Reparto Tecnologie Biologiche Applicate") %>% 
      summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) 
    
    tot$esami
})



##### media----
output$medgBS<- renderText({  
    media <-  covid %>% 
      mutate(anno = year(dtacc)) %>% 
      filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021& Reparto == "Reparto Tecnologie Biologiche Applicate") %>% 
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
                       "SARS-CoV-2: identificazione varianti N501Y") & anno == 2021 & Reparto == "Reparto Tecnologie Biologiche Applicate") %>% 
  summarise(var = sum(Tot_Eseguiti, na.rm = TRUE))
varbs$var
})


##### sequenziamento----


output$seqbs<- renderText({
seqbs <- covid %>% 
  mutate(anno = year(dtacc)) %>% 
  filter(Prova %in% c( "Sequenziamento acidi nucleici", 
                       "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
                       "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") & anno == 2021& Reparto == "Reparto Tecnologie Biologiche Applicate") %>% 
  summarise(seq = sum(Tot_Eseguiti, na.rm = TRUE))
seqbs$seq
})




##Laboratorio PV----

### Tabella----
output$tabella3 <- renderDataTable(  server = FALSE,
                                     class = 'cell-border stripe', rownames=FALSE,
                                     extensions = 'Buttons',options = list(dom="Brtip", pageLength = 10,
                                                                           searching = FALSE,paging = TRUE,autoWidth = TRUE,
                                                                           buttons = c('excel')),
               covid %>% 
               filter(tipoconf == "Gratuito" & anno == 2021 & Reparto == "Sede Territoriale di Pavia")
  
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
    filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021 & Reparto == "Sede Territoriale di Pavia") %>% 
    summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) 
  
  tot$esami
})



##### media----
output$medgPV<- renderText({  
  media <-  covid %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021& Reparto == "Sede Territoriale di Pavia") %>% 
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
                         "SARS-CoV-2: identificazione varianti N501Y") & anno == 2021 & Reparto == "Sede Territoriale di Pavia") %>% 
    summarise(var = sum(Tot_Eseguiti, na.rm = TRUE))
  varPV$var
})


##### sequenziamento----


output$seqPV<- renderText({
  seqPV <- covid %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(Prova %in% c( "Sequenziamento acidi nucleici", 
                         "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
                         "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") & anno == 2021& Reparto == "Sede Territoriale di Pavia") %>% 
    summarise(seq = sum(Tot_Eseguiti, na.rm = TRUE))
  seqPV$seq
})




##Laboratorio MO----

### Tabella----
output$tabella4 <- renderDataTable( 
  server = FALSE,
  class = 'cell-border stripe', rownames=FALSE,
  extensions = 'Buttons',options = list(dom="Brtip", pageLength = 10,
                                        searching = FALSE,paging = TRUE,autoWidth = TRUE,
                                        buttons = c('excel')),
  
  covid %>% 
               filter(tipoconf == "Gratuito" & anno == 2021 & Reparto == "Sede Territoriale di Modena")
  
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
    filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021 & Reparto == "Sede Territoriale di Modena") %>% 
    summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) 
  
  tot$esami
})



##### media----
output$medgMO<- renderText({  
  media <-  covid %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021& Reparto == "Sede Territoriale di Modena") %>% 
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
                         "SARS-CoV-2: identificazione varianti N501Y") & anno == 2021 & Reparto == "Sede Territoriale di Modena") %>% 
    summarise(var = sum(Tot_Eseguiti, na.rm = TRUE))
  varMO$var
})


##### sequenziamento----


output$seqMO<- renderText({
  seqMO <- covid %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(Prova %in% c( "Sequenziamento acidi nucleici", 
                         "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
                         "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") & anno == 2021& Reparto == "Sede Territoriale di Modena") %>% 
    summarise(seq = sum(Tot_Eseguiti, na.rm = TRUE))
  seqMO$seq
})


##Laboratorio sede territoriale BS--

# output$tabella5 <- renderDataTable({   
#   
#   datatable((covid %>% 
#                filter(tipoconf == "Gratuito" & anno == 2021 & Reparto == "Sede Territoriale di Brescia")))
#   
# })
# 
# 
# 
# ### Plot---
# output$serieTBS<- renderPlotly({  
#   serie3(reparto = "Sede Territoriale di Brescia")
# })
# 
# ### ValueBox---
# 
# 
# ##### numero---
# output$tottampMO <- renderText({
#   
#   
#   
#   tot <-covid %>% 
#     mutate(anno = year(dtacc)) %>% 
#     filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021 & Reparto == "Sede Territoriale di Brescia") %>% 
#     summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) 
#   
#   tot$esami
# })
# 
# 
# 
# ##### media---
# output$medgTBS<- renderText({  
#   media <-  covid %>% 
#     mutate(anno = year(dtacc)) %>% 
#     filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021& Reparto == "Sede Territoriale di Brescia") %>% 
#     group_by(dtacc) %>% 
#     summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
#     summarise(media = round(mean(esami), 1))
#   media$media
# })
# 
# ##### varianti---
# 
# output$varTBS<- renderText({
#   varTBS <- covid %>% 
#     mutate(anno = year(dtacc)) %>% 
#     filter(Prova %in% c( "SARS-CoV-2: identificazione varianti", 
#                          "SARS-CoV-2: identificazione varianti N501Y") & anno == 2021 & Reparto == "Sede Territoriale di Brescia") %>% 
#     summarise(var = sum(Tot_Eseguiti, na.rm = TRUE))
#   varTBS$var
# })
# 
# 
# ##### sequenziamento---
# 
# 
# output$seqTBS<- renderText({
#   seqTBS <- covid %>% 
#     mutate(anno = year(dtacc)) %>% 
#     filter(Prova %in% c( "Sequenziamento acidi nucleici", 
#                          "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
#                          "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") & anno == 2021& Reparto == "Sede Territoriale di Brescia") %>% 
#     summarise(seq = sum(Tot_Eseguiti, na.rm = TRUE))
#   seqTBS$seq
# })






}
  
  



