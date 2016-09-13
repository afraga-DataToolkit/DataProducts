#-----------------------------
# Cost_Calculations.R
# Author: Alejandro Fraga
# September 2016 v1.0
# This file contains the equations identified by the linear models

library(dplyr)
library(forecast)

# gather_college_data_web()
# This function will gaher the data set from GIT repo
get_college_data_web <- function() {
        url <- "https://raw.githubusercontent.com/afraga-DataToolkit/DataProducts/master/USCollegeCosts.csv"
        f <- file.path(getwd(),"USCollegeCost.csv")
        download.file(url, f)
        dtCosts <- tbl_df(read.csv(f, as.is=TRUE))
        # Convert the cost columns to numeric
        transform(dtCosts, Tuition_Private_4yr=as.numeric(Tuition_Private_4yr))
        transform(dtCosts, Tuition_Public_4yr=as.numeric(Tuition_Public_4yr))
        transform(dtCosts, Tuition_Fees_Room_Board_Private_4yr=as.numeric(Tuition_Fees_Room_Board_Private_4yr))
        transform(dtCosts, Tuition_Fees_Room_Board_Public_4yr=as.numeric(Tuition_Fees_Room_Board_Public_4yr))
        dtCosts        
}


# gather_college_data()
# This function will gaher the data set from GIT repo
get_college_data <- function() {
        dtCosts <- tbl_df(read.csv("data/USCollegeCosts.csv", as.is=TRUE))
        # Convert the cost columns to numeric
        transform(dtCosts, Tuition_Private_4yr=as.numeric(Tuition_Private_4yr))
        transform(dtCosts, Tuition_Public_4yr=as.numeric(Tuition_Public_4yr))
        transform(dtCosts, Tuition_Fees_Room_Board_Private_4yr=as.numeric(Tuition_Fees_Room_Board_Private_4yr))
        transform(dtCosts, Tuition_Fees_Room_Board_Public_4yr=as.numeric(Tuition_Fees_Room_Board_Public_4yr))
        dtCosts        
}

# This function forecast just the college tuition costs based on current child age. 
# It returns a list with two elements:
# [[1]] A time series object to create the plot with plot(output[[1]], ylab="Cost[USD]", main="College Cost Forecast")
# [[2]] A Table that provides the cost of the 4 years of college
us_college_tuition_forecast <- function (data, inflation, collegetype, childage) {
        # Inflation set to 2.5
        yr_inflation <- as.numeric(inflation)
        # Calculate the remaining years
        remyears <- 18-as.numeric(childage)
        #Init return list
        college_forecast<-list()
        #Init total variable
        forecast_tuition_total<-0
        #Init Output Table
        cost_table<-data.frame(matrix(ncol=3,nrow=4))
        #Assign Names
        colnames(cost_table)<-c("Year", "Cost_Yr", "Grand_Total")
        
        #Calculate the college forecast time series based on collegetype
        if (collegetype == "Public") {
                # Convert to time series object
                tuition<-ts(data$Tuition_Public_4yr, start=1972,frequency = 1)
        }
        if (collegetype == "Private") {
                # Convert to time series object
                tuition<-ts(data$Tuition_Private_4yr, start=1972,frequency = 1)
        }
        
        # Forecast function
        forecast_tuition <- HoltWinters(tuition, beta=TRUE, gamma = FALSE)
        # Forecast number of years
        lastattendance_yr <- remyears+3
        forecast_tuition_future <- forecast.HoltWinters(forecast_tuition, h=lastattendance_yr)

        # The expected attendance will be in the future based from the current year
        attendace_yr<-remyears
        for(i in 1:4) {
          cost_table$Year[i]<-i
          cost_table$Cost_Yr[i]<-forecast_tuition_future$mean[attendace_yr]*yr_inflation
          forecast_tuition_total<-forecast_tuition_total+cost_table$Cost_Yr[i]
          attendace_yr<-attendace_yr+1
        }
        cost_table$Grand_Total[1]<-forecast_tuition_total
        # Add the forecast for the plot to the return list
        college_forecast[[1]]<-forecast_tuition_future 
        # Add the table
        college_forecast[[2]]<-cost_table
        # Return the list
        college_forecast
}



# This function forecast the college tuition costs + Room + Board + Fees based on current childage years. 
# It returns a list with two elements:
# [[1]] A time series object to create the plot with plot(output[[1]], ylab="Cost[USD]", main="College Cost Forecast")
# [[2]] A Table that provides the cost of the 4 years of college
us_college_all_forecast <- function (data, inflation, collegetype, childage) {
        # Inflation set to 2.5
        yr_inflation <- as.numeric(inflation)
        # Calculate the remaining years
        remyears <- 18-as.numeric(childage)
        #Init return list
        college_forecast<-list()
        #Init total variable
        forecast_tuition_total<-0
        #Init Output Table
        cost_table<-data.frame(matrix(ncol=3,nrow=4))
        #Assign Names
        colnames(cost_table)<-c("Year", "Cost_Yr", "Grand_Total")
        
        #Calculate the college forecast time series based on collegetype
        if (collegetype == "Public") {
                # Convert to time series object
                tuition<-ts(data$Tuition_Fees_Room_Board_Public_4yr, start=1972,frequency = 1)
        }
        if (collegetype == "Private") {
                # Convert to time series object
                tuition<-ts(data$Tuition_Fees_Room_Board_Private_4yr, start=1972,frequency = 1)
        }
        
        # Forecast function
        forecast_tuition <- HoltWinters(tuition, beta=TRUE, gamma = FALSE)
        # Forecast number of years
        lastattendance_yr <- remyears+3
        forecast_tuition_future <- forecast.HoltWinters(forecast_tuition, h=lastattendance_yr)
        
        # The expected attendance will be in the future based from the current year
        attendace_yr<-remyears
        for(i in 1:4) {
                cost_table$Year[i]<-i
                cost_table$Cost_Yr[i]<-forecast_tuition_future$mean[attendace_yr]*yr_inflation
                forecast_tuition_total<-forecast_tuition_total+cost_table$Cost_Yr[i]
                attendace_yr<-attendace_yr+1
        }
        cost_table$Grand_Total[1]<-forecast_tuition_total
        # Add the forecast for the plot to the return list
        college_forecast[[1]]<-forecast_tuition_future 
        # Add the table
        college_forecast[[2]]<-cost_table
        # Return the list
        college_forecast  
}

# This function calculate the cost based on college type (public or private)
#college_cost_usa <- function (collegetype, childage) {
#        age <- as.numeric(childage)
#        togo = 18-age
#        inflation <- 1.025
        
#        # Get the collegetype and apply the formula
#        if (collegetype == "public") {
#                yr1cost <- 5302.2 + (267.72*togo)
#                yr2cost <- (5302.2 + (267.72*(togo+1)))*inflation
#                yr3cost <- (5302.2 + (267.72*(togo+2)))*inflation
#                yr4cost <- (5302.2 + (267.72*(togo+3)))*inflation
#                totalcost <- yr1cost+yr2cost+yr3cost+yr4cost
#        }
#        if (collegetype == "private") {
#                yr1cost <- 11749 + (666.64*togo)
#                yr2cost <- (11749 + (666.64*(togo+1)))*inflation
#                yr3cost <- (11749 + (666.64*(togo+2)))*inflation
#                yr4cost <- (11749 + (666.64*(togo+3)))*inflation    
#                totalcost <- yr1cost+yr2cost+yr3cost+yr4cost
#        }  
#        totalcost*4  
#} # end of college_cost_usa
