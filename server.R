server<-function(input, output) {
  
  
  
  output$tabella <- renderDataTable(
    datatable(covid)
    
  )
  
  output$serie <- renderPlot(
    
    covid %>% 
      mutate(anno = year(dtacc)) %>% 
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
        title = "Andamento del numero di tamponi naso-faringei processati dai laboratori COVID dell'IZSLER nel 2020 e primi mesi del 2021", 
        subtitle = " I punti rappresentano il numero di tamponi giornalieri, la linea blu la media mobile mensile"
      )+
      theme_ipsum_rc(base_size = 14,  axis_title_size = 15, 
                     plot_title_size = 12)+
      theme(
        axis.text.x=element_text(size = 14),
        
      )
  )
  
  
}


