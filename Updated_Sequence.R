### CHANGE THE DATE USING Ctrl + H

##################################
### CODE BOOK (CASE SENSITIVE) ###
##################################

### HOME PLAYERS: JERSEY NUMBER ONLY (e.g. 7)
### GUEST PLAYERS: g
### Goal: goal

############
### DATA ###
############

data = read.csv( "SHS_HomeGame_20200207.csv", header=FALSE )[,1]
data = gsub( "\t", "", data )
data = as.character(data)
data = data[ which( data != "" ) ]

### HERE IS A SAMPLE FOR DEMONSTRATION

#View(data)

###
###### ASSIGN "h" TO HOME PLAYERS
###

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
data.player


pdf( "/Users/luis/Documents/Capstone/Salinas High School/Salinas_High_Project/SHS_HomeGame_20200207.pdf", height=8, width=14 )

par( mfrow=c(2,2) )

jersey = as.numeric( substring( as.character( data.player[-1,1] ), 2, 3 ) )
o = order(jersey)

temp1 = data.player[-1,2][o]
temp2 = as.numeric( substring( data.player[-1,1][o], 2, 3 ) )

bp = barplot( temp1, names.arg=temp2, ylab="Count", main="Ball Touch (Individual)", col="gold", ylim=c(0,1.5*max(temp1)) )
text( bp, 0, temp1, cex=1, pos=3 )

temp1 = data.player[-1,4][o]
temp2 = as.numeric( substring( data.player[-1,1][o], 2, 3 ) )
bp = barplot( temp1, names.arg=temp2, ylab="%", main="Successful Pass (Individual)", ylim=c(0,100), col="gold" )
text( bp, 0, temp1, cex=1, pos=3 )

touch.g = data.player[1,2]
good.g = data.player[1,3]
prob.g = round( good.g / touch.g * 100 )

touch.h = sum( data.player[-1,2] )
clear.h = sum( data.player[-1, 6])
touch.h = touch.h + clear.h
good.h = sum( data.player[-1,3] )
prob.h = round( good.h / touch.h * 100 )

temp = c( touch.h, touch.g )
bp = barplot( temp, names.arg=c("Cowboys","Guest"), ylab="Count", col=c("gold","orange"), ylim=c(0,1.5*max(temp)), main="Ball Touch (Team)" )
mtext( adj=.5, at=bp[1], side=1, line=-2, text=paste( temp[1], " touches (", round(temp[1]/sum(temp)*100), "%)", sep="" ), font=2 )
mtext( adj=.5, at=bp[2], side=1, line=-2, text=paste( temp[2], " touches (", round(temp[2]/sum(temp)*100), "%)", sep="" ), font=2 )
legend( "topright", legend=c("Cowboys","Guest"), fill=c("gold","orange"), bty="n" )

temp = c( prob.h, prob.g )
bp = barplot( temp, names.arg=c("Cowboys","Guest"), ylab="%", col=c("gold","orange"), ylim=c(0,100), main="Successful Pass (Team)" )
mtext( adj=.5, at=bp[1], side=1, line=-2, text=paste( prob.h, "%", sep="" ), font=2 )
mtext( adj=.5, at=bp[2], side=1, line=-2, text=paste( prob.g, "%", sep="" ), font=2 )
legend( "topright", legend=c("Cowboys","Guest"), fill=c("gold","orange"), bty="n" )

dev.off()

### NEXT GOAL

### 1. DISTRIBUTION OF THE LENGTH OF CONSECUTIVE SUCCESSES BY HOME AND GUEST (i.e. NUMBER OF SUCCESSES BEFORE TURNOVER)
### 2. ANYTHING ELSE? CAN WE ADD "shoton", "shotoff", "save", "corner", "foul" AND OTHER LIVE STATS IN THE SEQUENCE?
