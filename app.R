#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaps)
library(class)
library(ggplot2)
library(ISLR)


# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Find best linear model"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput("featureSelection", "Choose with feature selection to run:",
                               c("Best Fit Selection" = "bf",
                                 "Forward Selection" = "f",
                                 "Backwards Selection" = "b")),
            selectInput("dataSet", "Choose which dataset to use",
                               c("College" = "College",
                                 "Hitters" = "Hitters",
                                 "Auto" = "Auto")),
            textInput("responseName","Enter the response name"),
        ),
        
        # Show a plot of the generated distribution
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

# Define server logic required to draw a histogram
server <- function(input, output) {
    get_features = function(){
        modelFormula = as.formula(paste(input$responseName,"~."))
        if(input$dataSet == "College"){
            dataSetFrame = College
        }
        else if (input$dataSet == "Hitters"){
            dataSetFrame = Hitters
        }
        else if (input$dataSet == "Auto"){
            dataSetFrame = Auto
        }
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
        
        ggplot(mapping = aes(x = selectionResults$adjr2,y = 1:length(selectionResults$adjr2))) + geom_point(mapping = aes(x = selectionResults$adjr2,y = 1:length(selectionResults$adjr2))) +  geom_point(mapping = aes(x = max(selectionResults$adjr2),y = which.max(selectionResults$adjr2)), color="red",size = 3)
    })
    
    output$bicPlot <- renderPlot({
        selectionResults = get_features()
        
        ggplot(mapping = aes(x = selectionResults$bic,y = 1:length(selectionResults$bic))) + geom_point(mapping = aes(x = selectionResults$bic,y = 1:length(selectionResults$bic))) +  geom_point(mapping = aes(x = min(selectionResults$bic),y = which.min(selectionResults$bic)), color="red",size = 3)
    })
    
    output$cpPlot <- renderPlot({
        selectionResults = get_features()
        
        ggplot(mapping = aes(x = selectionResults$cp,y = 1:length(selectionResults$cp))) + geom_point(mapping = aes(x = selectionResults$cp,y = 1:length(selectionResults$cp))) +  geom_point(mapping = aes(x = min(selectionResults$cp),y = which.min(selectionResults$cp)), color="red",size = 3)
    })
    output$r2Formula <- renderText({
        selectionResults = get_features()
        if(input$dataSet == "College"){
            dataSetFrame = College
        }
        else if (input$dataSet == "Hitters"){
            dataSetFrame = Hitters
        }
        else if (input$dataSet == "Auto"){
            dataSetFrame = Auto
        }
        dataSetColNames = colnames(dataSetFrame)
        dataSetColNames = dataSetColNames[!dataSetColNames %in% input$responseName]
        paste(input$responseName,paste("~",paste(dataSetColNames[selectionResults$which[which.max(selectionResults$adjr2),-1]],collapse="+"),sep = ""))
    })
    output$bicFormula <- renderText({
        selectionResults = get_features()
        if(input$dataSet == "College"){
            dataSetFrame = College
        }
        else if (input$dataSet == "Hitters"){
            dataSetFrame = Hitters
        }
        else if (input$dataSet == "Auto"){
            dataSetFrame = Auto
        }
        dataSetColNames = colnames(dataSetFrame)
        dataSetColNames = dataSetColNames[!dataSetColNames %in% input$responseName]
        paste(input$responseName,paste("~",paste(dataSetColNames[selectionResults$which[which.min(selectionResults$bic),-1]],collapse="+"),sep = ""))
    })
    output$cpFormula <- renderText({
        selectionResults = get_features()
        if(input$dataSet == "College"){
            dataSetFrame = College
        }
        else if (input$dataSet == "Hitters"){
            dataSetFrame = Hitters
        }
        else if (input$dataSet == "Auto"){
            dataSetFrame = Auto
        }
        dataSetColNames = colnames(dataSetFrame)
        dataSetColNames = dataSetColNames[!dataSetColNames %in% input$responseName]
        paste(input$responseName,paste("~",paste(dataSetColNames[selectionResults$which[which.min(selectionResults$cp),-1]],collapse="+"),sep = ""))
    })
}

# Run the application 
shinyApp(ui = ui, server = server)