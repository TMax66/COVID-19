server<-function(input, output) {
  
# Situazione Generale----
  
## Tabella----
  output$tabella <- renderDataTable({   
    
    if(input$Regione == "Dati Complessivi") {
    
    datatable((covid %>% 
                filter(tipoconf == "Gratuito" & anno == 2021)))
    } else
    
    if(input$Regione == "Lombardia"){
      datatable((covid %>% 
                   filter(tipoconf == "Gratuito" & anno == 2021 & Regione == "Lombardia")))
      
    } else
    
      if(input$Regione == "Emilia Romagna"){
        datatable((covid %>% 
                     filter(tipoconf == "Gratuito" & anno == 2021 & Regione == "Emilia Romagna")))
      }
    
  })
  
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
         summarise(media = mean(esami))
  
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
output$tabella2 <- renderDataTable({   
  
  if(input$Regione == "Dati Complessivi") {
    
    datatable((covid %>% 
                 filter(tipoconf == "Gratuito" & anno == 2021 & Reparto == "Reparto Tecnologie Biologiche Applicate")))
  } else
    
    if(input$Regione == "Lombardia"){
      datatable((covid %>% 
                   filter(tipoconf == "Gratuito" & anno == 2021 & Regione == "Lombardia" & Reparto == "Reparto Tecnologie Biologiche Applicate")))
      
    } else
      
      if(input$Regione == "Emilia Romagna"){
        datatable((covid %>% 
                     filter(tipoconf == "Gratuito" & anno == 2021 & Regione == "Emilia Romagna"& Reparto == "Reparto Tecnologie Biologiche Applicate")))
      }
  
})



### Plot----
output$serieBS<- renderPlotly({  
    serie3(reparto = "Reparto Tecnologie Biologiche Applicate")
})







### ValueBox----
##### numero----
##### media----
##### varianti----
##### sequenziamento----
}
  
  



