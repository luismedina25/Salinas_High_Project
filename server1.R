#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
 output$contents <- renderTable({
  
   #input$file1 will be NULL initially. After the user selects and uploads a 
   #file, it will be a data frame with 'name', 'size', 'type', and 'datapath'
   #columns. The 'datapath' column will contain the local filenames where the data can be found
   
   inFile <- input$file1
   
   if(is.null(inFile))
     return(NULL)
   
   read.csv(inFile$datapath, header=input$header, sep=input$sep, quote=input$quote)
   
  })
  
 #Creates the plot for Individual ball touches
 #output$ball_touch_individual <- renderPlot({
   #bp = barplot( temp1, names.arg=temp2, ylab="Count", main="Ball Touch (Individual)", col="gold", ylim=c(0,1.5*max(temp1)) )
   #text( bp, 0, temp1, cex=1, pos=3 )
 #})
 
 #Creates the plot for Successful pass for individuals
 #output$success_pass_individual <- renderPlot({
  
 #})
 
 #Creates the plot for Ball touches for the team
 #output$ball_touch_team <- renderPlot({
  
 #})
 
 #Creates the plot for Successful pass for the team
 #output$successful_pass_team <- renderPlot({

#})
 
 
})
