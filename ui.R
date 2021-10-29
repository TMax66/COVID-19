ui<-navbarPage("IZSLER: Attività dei laboratori COVID-19",
    theme = shinytheme("cerulean"),
           
    tabPanel("Dataset",
              
                fluidPage(
                    fluidRow(
                    br(), 
                    wellPanel(
                        DTOutput("tabella")   
                    )), 
                    
                    fluidRow(
                        br(), 
                        wellPanel(
                            plotOutput("serie")
                        )
                    )
                )
             ), 
     
    
     
    )     

             

