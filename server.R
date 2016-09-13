library(shiny)
library(dplyr)
source("Cost_Calculations.R")

# Source the College Data
college_data<-get_college_data()
# Global Variable to hold the results
#college_analysis <- list(ts(college_data$Tuition_Fees_Room_Board_Public_4yr, start=1972,frequency = 1),data.frame(matrix(ncol=3,nrow=4)))

# Define server logic required to return the information needed
shinyServer(function(input, output) {
  
  # Reactive Operation
  dataInput <- reactive({
        # Calculate the forecast based on parameters received
        if (input$tab2_tuition == 'Just Tuition') {
          analysis <- us_college_tuition_forecast(college_data, input$tab2_inflation, input$tab2_collegetype, input$tab2_kidage)
          assign("college_analysis", analysis, envir = .GlobalEnv)
        }
        if (input$tab2_tuition == 'Tuition+Room+Board') {
          analysis <- us_college_all_forecast(college_data, input$tab2_inflation, input$tab2_collegetype, input$tab2_kidage)
          assign("college_analysis", analysis, envir = .GlobalEnv)
        }
  })
  
  # Display the selections
  
  output$sel_kidage <- renderText({ 
    dataInput()
  })
  output$sel_collegetype <- renderText({ 
    dataInput()
  })  
  output$sel_tuition <- renderText({ 
    dataInput()
  })  
  output$sel_inflation <- renderText({ 
    dataInput()
  })

  
  output$cost_chart <- renderPlot({
    dataInput()
    plot(college_analysis[[1]], ylab="Cost[USD]", main="US College Cost Forecast")
  })
  
  output$cost_table <- renderTable({
    dataInput()
    college_analysis[[2]]
    })
  
  

  
  # Display the Manager Summary table
#  output$tblManagerSummary = renderTable({    
#    manSummary <- manager_summary_analysis_table(input$tab2_manselection, input$tab2_monthselection, input$tab2_relselector,  run_mode)  
#    manSummary
#  }) 
  
#  output$tblOverview = renderDataTable({    
#    manOverview <- manager_Overview(input$tab2_manselection, input$tab2_monthselection, run_mode)  
#    manOverview
#  })  
  
})



