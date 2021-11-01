ui<-navbarPage("IZSLER: Attività dei laboratori COVID-19",
    theme = shinytheme("cerulean"),
# SITUAZIONE GENERALE----
    tabPanel("Situazione generale",
              
                fluidPage(
                    
                  wellPanel(  
                    fluidRow(
                        br(), 
                     
                          column(2, 
                                 selectInput("Regione", "Regione sede prelievo", 
                                         choices =  c("Dati Complessivi", "Lombardia", "Emilia Romagna"))), 
                          column(4, 
                            plotlyOutput("serie")), 
                          
                         column(6, 
                                fluidRow (  
                                valueBox(value = "tottamp",
                                         subtitle = "N.Tamponi processati",
                                         icon = "flask",
                                         color = "green"), 
                                valueBox(value = "medg",
                                           subtitle = "Media giornaliera tamponi processati",
                                           icon = "flask",
                                           color = "green")
                                ),
                                br(),br(),br(),br(),
                                fluidRow (  
                                  valueBox(value = "vart",
                                           subtitle = "Identificazione Varianti",
                                           icon = "dna",
                                           color = "lightblue"), 
                                  valueBox(value = "seqt",
                                           subtitle = "Sequenziamento",
                                           icon = "dna",
                                           color = "lightblue")
                                  )
                                )
                      
                        )
                    ), 
           
                  fluidRow(
                    DTOutput("tabella")
                  )
                )
             ), 
# LABORATORIO BRESCIA----
    tabPanel("Laboratorio Covid-Brescia", 
             fluidPage(
               
               wellPanel(  
                 fluidRow(
                   br(), 
                   column(6, 
                          plotlyOutput("serieBS"))#, 
                   # 
                   # column(6, 
                   #        fluidRow (  
                   #          valueBox(value = "tottamp",
                   #                   subtitle = "N.Tamponi processati",
                   #                   icon = "flask",
                   #                   color = "green"), 
                   #          valueBox(value = "medg",
                   #                   subtitle = "Media giornaliera tamponi processati",
                   #                   icon = "flask",
                   #                   color = "green")
                   #        ),
                   #        br(),br(),br(),br(),
                   #        fluidRow (  
                   #          valueBox(value = "vart",
                   #                   subtitle = "Identificazione Varianti",
                   #                   icon = "dna",
                   #                   color = "lightblue"), 
                   #          valueBox(value = "seqt",
                   #                   subtitle = "Sequenziamento",
                   #                   icon = "dna",
                   #                   color = "lightblue")
                   #        )
                   )),
                   
                 #)
              # ), 
               
               fluidRow(
                 DTOutput("tabella2")
               )
             )
             ), 
    tabPanel("Laboratorio Covid-Pavia"), 
    tabPanel("Laboratorio Covid-Modena"), 
    tabPanel("Analisi del Rischio ed Epidemiologia Genomica")
     
    
     
    )     

             

