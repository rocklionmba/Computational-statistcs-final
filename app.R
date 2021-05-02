if(!require(shiny)) install.packages("shiny")
if(!require(leaps)) install.packages("leaps")
if(!require(class)) install.packages("class")
if(!require(ggplot2)) install.packages("ggplot2")
if(!require(ISLR)) install.packages("ISLR")
if(!require(tidyverse)) install.packages('tidyverse')

library(tidyverse)
library(shiny)
library(leaps)
library(class)
library(ggplot2)
library(ISLR)


ui <- fluidPage(

    titlePanel("Find best linear model"),

    sidebarLayout(
        sidebarPanel(
            selectInput("featureSelection", "Choose with feature selection to run:",
                               c("Best Fit Selection" = "bf",
                                 "Forward Selection" = "f",
                                 "Backwards Selection" = "b")),
            selectInput("dataSet", "Choose which dataset to use",
                               c("College" = "College",
                                 "Hitters" = "Hitters",
                                 "Diamonds" = "Diamonds")),
            textInput("responseName","Enter the response name"),
            p("Note: If copying the formula for a model, do not include the NA in the formula.")
        ),
        
        mainPanel(
            tabsetPanel(
                tabPanel("r2",
                    plotOutput("r2Plot"),
                    p("The best formulas based on the adjusted R^2:"),
                    code(textOutput("r2Formula"))
                ),
                tabPanel("bic",
                     plotOutput("bicPlot"),
                     p("The best formulas based on the Bayesian information criterion:"),
                     code(textOutput("bicFormula"))
                ),
                tabPanel("cp",
                     plotOutput("cpPlot"),
                     p("The best formulas based on Mallows' C_p:"),
                     code(textOutput("cpFormula"))
                )
            ),
        )
    )
)

server <- function(input, output) {
    getDataSetFrame = function (){
        dataSetFrame = NULL
        if(input$dataSet == "College"){
            dataSetFrame = College
        }
        else if (input$dataSet == "Hitters"){
            dataSetFrame = Hitters
        }
        else if (input$dataSet == "Diamonds"){
            dataSetFrame = diamonds
        }
        return(dataSetFrame)
    }
    
    get_features = function(){
        modelFormula = as.formula(paste(input$responseName,"~."))
        dataSetFrame = getDataSetFrame()
        validate(need(colnames(dataSetFrame) %in% input$responseName,"There is no column with this name."))
        modelFormula = as.formula(paste(input$responseName,"~."))
        
        selectionResults = switch(input$featureSelection,
                                  "bf" = summary(regsubsets(modelFormula, data = dataSetFrame, nvmax = length(colnames(Auto)))),
                                  "f" = summary(regsubsets(modelFormula, data = dataSetFrame, nvmax = length(colnames(Auto)), method = "forward")),
                                  "b" = summary(regsubsets(modelFormula, data = dataSetFrame, nvmax = length(colnames(Auto)), method = "backward")),
        )
        return(selectionResults)
    }
    
    
    output$r2Plot <- renderPlot({
        selectionResults = get_features()
        
        ggplot(mapping = aes(x = selectionResults$adjr2,y = 1:length(selectionResults$adjr2))) + geom_point(mapping = aes(x = selectionResults$adjr2,y = 1:length(selectionResults$adjr2))) +  geom_point(mapping = aes(x = max(selectionResults$adjr2),y = which.max(selectionResults$adjr2)), color="red",size = 3)+ labs(x="R^2", y="")
    })
    
    output$bicPlot <- renderPlot({
        selectionResults = get_features()
        
        ggplot(mapping = aes(x = selectionResults$bic,y = 1:length(selectionResults$bic))) + geom_point(mapping = aes(x = selectionResults$bic,y = 1:length(selectionResults$bic))) +  geom_point(mapping = aes(x = min(selectionResults$bic),y = which.min(selectionResults$bic)), color="red",size = 3)+ labs(x="BIC", y="")
    })
    
    output$cpPlot <- renderPlot({
        selectionResults = get_features()
        
        ggplot(mapping = aes(x = selectionResults$cp,y = 1:length(selectionResults$cp))) + geom_point(mapping = aes(x = selectionResults$cp,y = 1:length(selectionResults$cp))) +  geom_point(mapping = aes(x = min(selectionResults$cp),y = which.min(selectionResults$cp)), color="red",size = 3)+ labs(x="C_P", y="")
    })
    output$r2Formula <- renderText({
        selectionResults = get_features()
        dataSetFrame = getDataSetFrame()
        dataSetColNames = colnames(dataSetFrame)
        dataSetColNames = dataSetColNames[!dataSetColNames %in% input$responseName]
        paste(input$responseName,paste("~",paste(dataSetColNames[selectionResults$which[which.max(selectionResults$adjr2),-1]],collapse="+"),sep = ""))
    })
    output$bicFormula <- renderText({
        selectionResults = get_features()
        dataSetFrame = getDataSetFrame()
        dataSetColNames = colnames(dataSetFrame)
        dataSetColNames = dataSetColNames[!dataSetColNames %in% input$responseName]
        paste(input$responseName,paste("~",paste(dataSetColNames[selectionResults$which[which.min(selectionResults$bic),-1]],collapse="+"),sep = ""))
    })
    output$cpFormula <- renderText({
        selectionResults = get_features()
        dataSetFrame = getDataSetFrame()
        dataSetColNames = colnames(dataSetFrame)
        dataSetColNames = dataSetColNames[!dataSetColNames %in% input$responseName]
        paste(input$responseName,paste("~",paste(dataSetColNames[selectionResults$which[which.min(selectionResults$cp),-1]],collapse="+"),sep = ""))
    })
}

shinyApp(ui = ui, server = server)
