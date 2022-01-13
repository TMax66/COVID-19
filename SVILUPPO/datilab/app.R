
library(shiny)
library(tidyverse)
library(here)
library(readxl)
library(rpivotTable)
library(readxl)
library(here)

# Define UI for application that draws a histogram
ui <-  fluidPage(  
    column(2, 
           dateRangeInput("datarange", "Seleziona il periodo:", 
                          start = "2021-01-01",
                          end = "2023-12-31", 
                          format = "dd/mm/yy", 
                          separator = " - ")), 
    
    column(5, offset = 1,
           rpivotTableOutput("pivot") 
    )
)
    

# Define server logic required to draw a histogram
server <- function(input, output) {
    
dtBT <- read_excel(here("SVILUPPO","datilab.xlsx"), sheet = "BT")
dtBT$n.esami <- rnorm(dim(dtBT)[1], 200, 50)
        
  

    output$pivot <- renderRpivotTable({
        rpivotTable(dtBT %>% 
                        filter(giorno >= input$datarange[1] & giorno <= input$datarange[2]), 
                    aggregatorName="Sum", vals = "n.esami")
    })
   
}

# Run the application 
shinyApp(ui = ui, server = server)
