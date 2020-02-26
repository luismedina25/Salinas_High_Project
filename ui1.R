#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(pageWithSidebar(
  
  # Application title
  titlePanel("Salinas High School Soccer"),
  
  # Sidebar with choose a CSV file
  sidebarPanel(
    fileInput('file1', 'Choose CSV file', accept = c('text/csv', 'text/comma-separated-values, text/plain', '.csv')),
    tags$hr(),
    checkboxInput('header', 'Header', TRUE),
   radioButtons('sep', 'Separator', c(comma=',',
                                      Semicolon=';', 
                                      Tab='\t'),
                                    'Comma'),
              
  ),
 
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Content", tableOutput('contents'))
        #tabPanel("Ball Touch (Individual)", plotOutput('ball_touch_individual')),
        #tabPanel("Successful Pass (Individual)", plotOutput('success_pass_individual')),
        #tabPanel("Ball Touch (Team)", plotOutput('ball_touch_team')),
        #tabPanel("Successful Pass (Team)", plotOutput('successful_pass_team')),
    )
    )
  
))

