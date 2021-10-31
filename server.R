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
      
      covid %>% 
        filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico")) %>% 
        mutate(anno = year(dtacc)) %>% 
        filter(anno == 2021) %>% 
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
                      y = esami), alpha = 1/5)+
        
        labs(
          y = "Numero Tamponi Naso Faringei", 
          x = "", 
          title = "Andamento del numero di tamponi naso-faringei processati dai laboratori COVID dell'IZSLER nel 2021", 
          subtitle = " I punti rappresentano il numero di tamponi giornalieri, la linea blu la media mobile mensile"
        )+
        theme_ipsum_rc(base_size = 10,  axis_title_size = 10, 
                       plot_title_size = 10)+
        theme(
          axis.text.x=element_text(size = 10))
      
    } else  
      
      if(input$Regione == "Lombardia") {  
        
      covid %>% 
          filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico")) %>% 
      mutate(anno = year(dtacc)) %>% 
        filter(anno == 2021 & Regione == "Lombardia") %>% 
      group_by(dtacc) %>% 
      summarise(esami = sum(Tot_Eseguiti, na.rm = T)) %>%  
      filter(esami > 0) %>%
      mutate(sett = rollmean(esami, k = 30, fill = NA) )%>%  
      ggplot(aes(
        x = dtacc, 
        y = sett
      ))+
      geom_line(col = "blue", size = 1.5)+
      # geom_col( aes(y = Tot), 
      #    alpha = 1/5)+
      
      geom_point(aes(x = dtacc, 
                     y = esami), alpha = 1/5)+
      geom_line(aes(x = dtacc, 
                    y = esami), alpha = 1/5)+
      #geom_hline(yintercept = 2729) +
      
      labs(
        y = "Numero Tamponi Naso Faringei", 
        x = "", 
        title =  "Andamento del numero di tamponi naso-faringei processati dai laboratori COVID dell'IZSLER nel 2021", 
        subtitle = " I punti rappresentano il numero di tamponi giornalieri, la linea blu la media mobile mensile"
      )+
          theme_ipsum_rc(base_size = 10,  axis_title_size = 10, 
                         plot_title_size = 10)+
          theme(
            axis.text.x=element_text(size = 10))
        
    
      } else
        
        if(input$Regione == "Emilia Romagna")
        {
          
          covid %>% 
            filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico")) %>% 
            mutate(anno = year(dtacc)) %>% 
            filter(anno == 2021 & Regione == "Emilia Romagna") %>% 
            group_by(dtacc) %>% 
            summarise(esami = sum(Tot_Eseguiti, na.rm = T)) %>%  
            filter(esami > 0) %>%
            mutate(sett = rollmean(esami, k = 30, fill = NA) )%>%  
            ggplot(aes(
              x = dtacc, 
              y = sett
            ))+
            geom_line(col = "blue", size = 1.5)+
            # geom_col( aes(y = Tot), 
            #    alpha = 1/5)+
            
            geom_point(aes(x = dtacc, 
                           y = esami), alpha = 1/5)+
            geom_line(aes(x = dtacc, 
                          y = esami), alpha = 1/5)+
            #geom_hline(yintercept = 2729) +
            
            labs(
              y = "Numero Tamponi Naso Faringei", 
              x = "", 
              title =  "Andamento del numero di tamponi naso-faringei processati dai laboratori COVID dell'IZSLER nel 2021", 
              subtitle = " I punti rappresentano il numero di tamponi giornalieri, la linea blu la media mobile mensile"
            )+
            theme_ipsum_rc(base_size = 10,  axis_title_size = 10, 
                           plot_title_size = 10)+
            theme(
              axis.text.x=element_text(size = 10))
        }
        
        
        
    
  }   
    
    )
  
      
    
  
## Valuebox
  
  
  tot <-  reactive(covid %>% 
    mutate(anno = year(dtacc)) %>% 
    filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021) %>% 
    summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) )
  
  output$tottamp <- renderText({
   
    tot()$esami
    
  })
  
  
   media <-  reactive(covid %>% 
                     mutate(anno = year(dtacc)) %>% 
                     filter(Prova %in% c("Agente eziologico", "SARS-CoV-2: agente eziologico") & anno == 2021) %>% 
                       group_by(dtacc) %>% 
                       summarise(esami = sum(Tot_Eseguiti, na.rm = TRUE)) %>% 
                       summarise(media = mean(esami)))
  
   output$medg<- renderText({
     
     media()$media
     
   })
  
   
   var <- reactive(covid %>% 
              mutate(anno = year(dtacc)) %>% 
              filter(Prova %in% c( "SARS-CoV-2: identificazione varianti", 
                                   "SARS-CoV-2: identificazione varianti N501Y") & anno == 2021) %>% 
              summarise(var = sum(Tot_Eseguiti, na.rm = TRUE)))
   
   output$vart<- renderText({
     var()$var})
   
   seq <- reactive(covid %>% 
                     mutate(anno = year(dtacc)) %>% 
                     filter(Prova %in% c( "Sequenziamento acidi nucleici", 
                                          "Sequenziamento genomico SARS-CoV-2 - Illumina - Miseq",
                                          "Sequenziamento genomico SARS-CoV-2 - Illumina - Nextseq") & anno == 2021) %>% 
                     summarise(seq = sum(Tot_Eseguiti, na.rm = TRUE)))
   
   output$seqt<- renderText({
     seq()$seq})
   
   
   
  
# Laboratori Covid----
  
}
  
  



