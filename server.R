server<-function(input, output) {
  
# Situazione Generale----
  
## Tabella----
  output$tabella <- renderDataTable(
    datatable((covid %>% 
                filter(tipoconf == "Gratuito")))
    
  )
  
## Plot----
  output$serie <- renderPlot({  
    
    if(input$Regione == "Dati Complessivi") {
      
      # covid %>% 
      #   filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico")) %>% 
      #   mutate(anno = year(dtacc)) %>% 
      #   filter(anno == 2021) %>% 
      #   group_by(dtacc) %>% 
      #   summarise(esami = sum(Tot_Eseguiti, na.rm = T)) %>%  
      #   filter(esami > 0) %>%
      #   mutate(sett = rollmean(esami, k = 30, fill = NA) )%>%  
      #   ggplot(aes(
      #     x = dtacc, 
      #     y = sett
      #   ))+
      #   geom_line(col = "blue", size = 1.5)+
      #   geom_point(aes(x = dtacc, 
      #                  y = esami), alpha = 1/5)+
      #   geom_line(aes(x = dtacc, 
      #                 y = esami), alpha = 1/5)+
      #   
      #   labs(
      #     y = "Numero Tamponi Naso Faringei", 
      #     x = "", 
      #     title = "Andamento del numero di tamponi naso-faringei processati dai laboratori COVID dell'IZSLER nel 2021", 
      #     subtitle = " I punti rappresentano il numero di tamponi giornalieri, la linea blu la media mobile mensile"
      #   )+
      #   theme_ipsum_rc(base_size = 10,  axis_title_size = 10, 
      #                  plot_title_size = 10)+
      #   theme(
      #     axis.text.x=element_text(size = 10))
      
      serie1()
      
    } else  
      
      if(input$Regione == "Lombardia") {  
        
      # covid %>% 
      #     filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico")) %>% 
      # mutate(anno = year(dtacc)) %>% 
      #   filter(anno == 2021 & Regione == "Lombardia") %>% 
      # group_by(dtacc) %>% 
      # summarise(esami = sum(Tot_Eseguiti, na.rm = T)) %>%  
      # filter(esami > 0) %>%
      # mutate(sett = rollmean(esami, k = 30, fill = NA) )%>%  
      # ggplot(aes(
      #   x = dtacc, 
      #   y = sett
      # ))+
      # geom_line(col = "blue", size = 1.5)+
      # # geom_col( aes(y = Tot), 
      # #    alpha = 1/5)+
      # 
      # geom_point(aes(x = dtacc, 
      #                y = esami), alpha = 1/5)+
      # geom_line(aes(x = dtacc, 
      #               y = esami), alpha = 1/5)+
      # #geom_hline(yintercept = 2729) +
      # 
      # labs(
      #   y = "Numero Tamponi Naso Faringei", 
      #   x = "", 
      #   title =  "Andamento del numero di tamponi naso-faringei processati dai laboratori COVID dell'IZSLER nel 2021", 
      #   subtitle = " I punti rappresentano il numero di tamponi giornalieri, la linea blu la media mobile mensile"
      # )+
      #     theme_ipsum_rc(base_size = 10,  axis_title_size = 10, 
      #                    plot_title_size = 10)+
      #     theme(
      #       axis.text.x=element_text(size = 10))
      #   
        
        serie2(regione = "Lombardia")
    
      } else
        
        if(input$Regione == "Emilia Romagna")
        {
          
        #   covid %>% 
        #     filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico")) %>% 
        #     mutate(anno = year(dtacc)) %>% 
        #     filter(anno == 2021 & Regione == "Emilia Romagna") %>% 
        #     group_by(dtacc) %>% 
        #     summarise(esami = sum(Tot_Eseguiti, na.rm = T)) %>%  
        #     filter(esami > 0) %>%
        #     mutate(sett = rollmean(esami, k = 30, fill = NA) )%>%  
        #     ggplot(aes(
        #       x = dtacc, 
        #       y = sett
        #     ))+
        #     geom_line(col = "blue", size = 1.5)+
        #     # geom_col( aes(y = Tot), 
        #     #    alpha = 1/5)+
        #     
        #     geom_point(aes(x = dtacc, 
        #                    y = esami), alpha = 1/5)+
        #     geom_line(aes(x = dtacc, 
        #                   y = esami), alpha = 1/5)+
        #     #geom_hline(yintercept = 2729) +
        #     
        #     labs(
        #       y = "Numero Tamponi Naso Faringei", 
        #       x = "", 
        #       title =  "Andamento del numero di tamponi naso-faringei processati dai laboratori COVID dell'IZSLER nel 2021", 
        #       subtitle = " I punti rappresentano il numero di tamponi giornalieri, la linea blu la media mobile mensile"
        #     )+
        #     theme_ipsum_rc(base_size = 10,  axis_title_size = 10, 
        #                    plot_title_size = 10)+
        #     theme(
        #       axis.text.x=element_text(size = 10))
        # }
        # 
        
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
  
  



