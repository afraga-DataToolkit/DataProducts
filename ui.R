#----------------------------------
# Alejandro Fraga
# College Cost Forecast
# Sep 9 2016
# Coursera - Developing Data Products
#----------------------------------

library(shiny)
library(dplyr)
library(forecast)

# Define UI for application that draws a histogram
ui <-navbarPage(
  
  # Application title
  title="College Cost Estimation Tool",
  
  tabPanel("Instructions",
           fluidRow(             
             column(12,
                 mainPanel(
                   h2("Overview"),
                   p("This application was created to help parents estimate the cost of college in US for their kids"),
                   p("College tuition data was analized to create a linear model for each country analyzed"),
                   h2("Instructions"),
                   p("Switch to the My Estimates Tab and enter the information requested. You will be requested to enter your childs age and the location where you plan them to attend college"),
                   h3("Assumptions:"),
                   p("- The child age assumed for college is 18 years"),
                   p("- A 4yr degree program is considered"),
                   p("- Tuition, Fees, Room and Boarding in 2015 dollars is used for the model")                   
                 )      
              )
           )

  ), # End Tab1
  
  tabPanel("My Estimates",
           sidebarLayout(
             sidebarPanel(
               h3("Tool Configuration"),


               selectInput("tab2_kidage", label = h4("Child Age today:"), 
                           choices = list("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17"), 
                           selected = "9"),

               selectInput("tab2_collegetype", label = h4("Which College type are you planning:"), 
                           choices = list("Public","Private"), 
                           selected = "Public"),
               
               selectInput("tab2_tuition", label = h4("Tuition Calculation"), 
                           choices = list("Tuition","Tuition+Room+Board"), 
                           selected = "Tuition+Room+Board"),

               selectInput("tab2_inflation", label = h4("Expected Inflation Rate:"), 
                           choices = list("0.090", "0.095", "1", "1.01", "1.02", "1.025", "1.03"), 
                           selected = "1.025")

             ),
             mainPanel(
               
               h3("College Cost Calculations"),
 #              h4("Summary of Data provided"),
#               textOutput('sel_kidage'),
#               textOutput('sel_collegetype'),
#               textOutput('sel_tuition'),
#               textOutput('sel_inflation'),

               h4("Your Estimated Costs Projection"),
               plotOutput('cost_chart'),
               h4("Your Estimated Costs each college year and Total College Costs"),
               tableOutput('cost_table')
               
             )
           ) # End Sidebar Layout
  ) # End Tab Panel
  

  
) # End NavBar Page



