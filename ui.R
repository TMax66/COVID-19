ui<-navbarPage("IZSLER: Attività dei laboratori COVID-19",
    theme = shinytheme("cerulean"),
           
    tabPanel("Situazione generale",
              
                fluidPage(
                    
                  wellPanel(  
                    fluidRow(
                        br(), 
                     
                          column(3, 
                                 selectInput("Regione", "Regione sede prelievo", 
                                         choices =  c("Dati complessivi", (unique(factor(covid$Regione)))))), 
                          column(7, 
                            plotOutput("serie")
                        
                          
                        )
                    )
                  ), 
                  fluidRow(
                    DTOutput("tabella")
                  )
                )
             ), 
    tabPanel("Laboratorio Covid-Brescia"), 
    tabPanel("Laboratorio Covid-Pavia"), 
    tabPanel("Laboratorio Covid-Modena")
     
    
     
    )     

             

