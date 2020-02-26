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
    
    data <- read.csv(inFile$datapath, header=input$header, sep=input$sep, quote=input$quote)
    
  })
  
  data = gsub( "\t", "", data )
  data = as.character(data)
  data = data[ which( data != "" ) ]
  
  index.home = substring( data, 1, 1 ) != "g"
  data[index.home] = paste( "h", data[index.home], sep="" )
  
  ################
  ### ANALYSIS ###
  ################
  
  player = unique(data) ### UNIQUE PLAYERS
  player = player[ player != "goal" ] ### REMOVE "goal"
  n = length(player) ### NUMBER OF UNIQUE PLAYERS (POSSIBLE TO BE GREATER THAN 22 INCLUDING NON-STARTERS)
  
  touch = good = goal = clear = assist = rep( NA, n ) ### STORAGE
  
  for ( i in 1:n ) {
    
    index.pre = which( data == player[i] ) ### SELECT Ball Touch FOR PLAYER i
    ball = data[index.pre]
    
    
    index.future =  index.pre + 2  ### WHAT HAPPENED TWO AFTER THE TOUCH
    index.before = index.pre - 1 ### WHAT HAPPENED BEFORE THE TOUCH
    index.post = index.pre + 1 ### WHAT HAPPENED AFTER THE TOUCH?
    before = data[index.before]
    then = data[index.post]
    future = data[index.future]
    
    touch[i] = length(ball) ### COUNT BALL TOUCH
    clear[i] = sum( substring(before, 1, 1) == substring(then, 1, 1) & substring(before,1,1) != substring(ball,1,1) & 
                      substring(ball,1,1) != substring(then,1,1), na.rm=TRUE) ### count the number of clears
    good[i] = sum( substring( ball, 1, 1 ) == substring( then, 1, 1 ), na.rm=TRUE ) ### SUCCESS PROBABILITY
    goal[i] = sum( then == "goal", na.rm=TRUE )### NUMBER OF GOALS
    assist[i] = sum(future == "goal" & substring(ball,1,1) == substring(then,1,1), na.rm=TRUE) ### NUMBER OF ASSISTS
    
    
    ### NOTE: SUCCESS IS DEFINED AS PASSING TO OWN TEAM
    
    ### Calculate the corrrect touches for home team
    if(substring(player[i],1,1) != "g")
    {
      touch[i] = touch[i] - clear[i]
    }
    
  }
  
  p.good = round( good / touch * 100 )
  data.player = data.frame( player, touch, good, p.good, goal, clear, assist )
  data.player = data.player[ order(player), ]
  
  jersey = as.numeric( substring( as.character( data.player[-1,1] ), 2, 3 ) )
  o = order(jersey)
  
  temp1 = data.player[-1,2][o]
  temp2 = as.numeric( substring( data.player[-1,1][o], 2, 3 ) )
  
  #Creates the plot for Individual ball touches
  output$ball_touch_individual <- renderPlot({
    bp = barplot( temp1, names.arg=temp2, ylab="Count", main="Ball Touch (Individual)", col="gold", ylim=c(0,1.5*max(temp1)) )
    text( bp, 0, temp1, cex=1, pos=3 )
  })
  
  #Creates the plot for Successful pass for individuals
  output$success_pass_individual <- renderPlot({
    temp1 = data.player[-1,4][o]
    temp2 = as.numeric( substring( data.player[-1,1][o], 2, 3 ) )
    bp = barplot( temp1, names.arg=temp2, ylab="%", main="Successful Pass (Individual)", ylim=c(0,100), col="gold" )
    text( bp, 0, temp1, cex=1, pos=3 )
  })
  
  touch.g = data.player[1,2]
  good.g = data.player[1,3]
  prob.g = round( good.g / touch.g * 100 )
  
  touch.h = sum( data.player[-1,2] )
  clear.h = sum( data.player[-1, 6])
  touch.h = touch.h + clear.h
  good.h = sum( data.player[-1,3] )
  prob.h = round( good.h / touch.h * 100 )
  
  #Creates the plot for Ball touches for the team
  output$ball_touch_team <- renderPlot({
    temp = c( touch.h, touch.g )
    bp = barplot( temp, names.arg=c("Cowboys","Guest"), ylab="Count", col=c("gold","orange"), ylim=c(0,1.5*max(temp)), main="Ball Touch (Team)" )
    mtext( adj=.5, at=bp[1], side=1, line=-2, text=paste( temp[1], " touches (", round(temp[1]/sum(temp)*100), "%)", sep="" ), font=2 )
    mtext( adj=.5, at=bp[2], side=1, line=-2, text=paste( temp[2], " touches (", round(temp[2]/sum(temp)*100), "%)", sep="" ), font=2 )
    legend( "topright", legend=c("Cowboys","Guest"), fill=c("gold","orange"), bty="n" )
  })
  
  #Creates the plot for Successful pass for the team
  output$successful_pass_team <- renderPlot({
    temp = c( prob.h, prob.g )
    bp = barplot( temp, names.arg=c("Cowboys","Guest"), ylab="%", col=c("gold","orange"), ylim=c(0,100), main="Successful Pass (Team)" )
    mtext( adj=.5, at=bp[1], side=1, line=-2, text=paste( prob.h, "%", sep="" ), font=2 )
    mtext( adj=.5, at=bp[2], side=1, line=-2, text=paste( prob.g, "%", sep="" ), font=2 )
    legend( "topright", legend=c("Cowboys","Guest"), fill=c("gold","orange"), bty="n" )
  })
  
  
})


