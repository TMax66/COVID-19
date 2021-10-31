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
  
## numero tamponi processati----
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

## media tamponi processati----
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
  
## Varianti----
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
     
## Sequenziamento
 
   
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
  
}
  
  



