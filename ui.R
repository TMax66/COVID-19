ui<-navbarPage("IZSLER: Attività dei laboratori COVID-19",
    theme = shinytheme("cerulean"),
# SITUAZIONE GENERALE----
    tabPanel("Situazione generale",
              
                fluidPage(
                    h1("situazione complessiva"), 
                    h3(uiOutput("agg")), 
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
    tabPanel("Laboratorio Covid-Reparto Tecnologie Biologiche Applicate", 
             fluidPage(
               h1("Laboratorio Covid-Reparto Tecnologie Biologiche Applicate"), 
               h3(uiOutput("aggBS")),
               wellPanel(  
                 fluidRow(
                   br(), 
                   column(6, 
                          plotlyOutput("serieBS")), 
                    
                   column(6, 
                         fluidRow (  
                           valueBox(value = "tottampBS",
                                    subtitle = "N.Tamponi processati",
                                     icon = "flask",
                                     color = "green"),
                             valueBox(value = "medgBS",
                                      subtitle = "Media giornaliera tamponi processati",
                                       icon = "flask",
                                      color = "green")
                           ),
                            br(),br(),br(),br(),
                           fluidRow (  
                            valueBox(value = "varbs",
                                     subtitle = "Identificazione Varianti",
                                     icon = "dna",
                                     color = "lightblue"),
                            valueBox(value = "seqbs",
                                     subtitle = "Sequenziamento",
                                     icon = "dna",
                                     color = "lightblue")
                          )
                   ))),
               
               fluidRow(
                 DTOutput("tabella2")
               )
             )
             ), 

#LABORATORIO PAVIA----
    tabPanel("Laboratorio Covid-Pavia",
             fluidPage(
                 h1("Laboratorio Covid-Pavia"), 
                 h3(uiOutput("aggPV")),
                 wellPanel(  
                     fluidRow(
                         br(), 
                         column(6, 
                                plotlyOutput("seriePV")), 
                         
                         column(6, 
                                fluidRow (  
                                    valueBox(value = "tottampPV",
                                             subtitle = "N.Tamponi processati",
                                             icon = "flask",
                                             color = "green"),
                                    valueBox(value = "medgPV",
                                             subtitle = "Media giornaliera tamponi processati",
                                             icon = "flask",
                                             color = "green")
                                ),
                                br(),br(),br(),br(),
                                fluidRow (  
                                    valueBox(value = "varPV",
                                             subtitle = "Identificazione Varianti",
                                             icon = "dna",
                                             color = "lightblue"),
                                    valueBox(value = "seqPV",
                                             subtitle = "Sequenziamento",
                                             icon = "dna",
                                             color = "lightblue")
                                )
                         ))),
                 
                 fluidRow(
                     DTOutput("tabella3")
                 )
             )
             
             
             
             
             
             
             
             
             ), 

#LABORATORIO MODENA----
    tabPanel("Laboratorio Covid-Modena", 
             fluidPage(
                 h1("Laboratorio Covid-Modena"), 
                 h3(uiOutput("aggMO")),
                 wellPanel(  
                     fluidRow(
                         br(), 
                         column(6, 
                                plotlyOutput("serieMO")), 
                         
                         column(6, 
                                fluidRow (  
                                    valueBox(value = "tottampMO",
                                             subtitle = "N.Tamponi processati",
                                             icon = "flask",
                                             color = "green"),
                                    valueBox(value = "medgMO",
                                             subtitle = "Media giornaliera tamponi processati",
                                             icon = "flask",
                                             color = "green")
                                ),
                                br(),br(),br(),br(),
                                fluidRow (  
                                    valueBox(value = "varMO",
                                             subtitle = "Identificazione Varianti",
                                             icon = "dna",
                                             color = "lightblue"),
                                    valueBox(value = "seqMO",
                                             subtitle = "Sequenziamento",
                                             icon = "dna",
                                             color = "lightblue")
                                )
                         ))),
                 
                 fluidRow(
                     DTOutput("tabella4")
                 )
             )), 
 #TABELLA PIVOT----
 tabPanel("Tools",
    
          
          
fluidPage(
    
    wellPanel(
        fluidRow( 
            column(2, 
            dateRangeInput("datarange", "Seleziona il periodo:", 
                           start = "2020-03-01",
                           end = "2023-12-31", 
                           format = "dd/mm/yy", 
                           separator = " - "), 
            
            
            radioButtons(inputId = "format", label = "Enter the format to download", 
                         choices = c( "csv", "excel"), inline = FALSE, selected = "csv"),
            downloadButton("download_pivot"),
            actionButton("copy_pivot", "Copy")), 
            
            column(5, offset = 1,
            rpivotTableOutput("pivot") %>% 
                 withSpinner(color="blue", type=8)))
     
    )     
)
)
)

