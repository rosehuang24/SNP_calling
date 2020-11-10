# what you need to do:
# 1. set working dirctory
# 2. run the script first to get the 
# mean F for each population 
# with or without plotting
# 3. run the script again to set the order 
# x-axis mannually


setwd("~/Desktop")
library(ggplot2)
library(dplyr)


dF<-read.delim("F_het_from_input2.het", sep="",header=T, check.names = F,stringsAsFactors = F)
level_order <- c('GJF','WLH','GGS','GGJ','EJVC','NAA','TBC','EHVC','SAVC','SK','DL','YVC','YNLC','SLVC') 
level_order <- c('GJF','WLH','GGS','GGJ','TBC','EJVC','NAA','SK','EHVC','SAVC','YVC','DL','YNLC','SLVC') 

pdf(file = "159_F.pdf", width = 6,height = 4) 

fun_mean <- function(x){
  return(data.frame(y=mean(x),label=mean(x,na.rm=T)))}

ggplot(dF, aes(x = factor(breed, level = level_order), y = F_pass))+
  geom_boxplot(outlier.shape = NA)+
  geom_jitter(colour="darkred", alpha=0.6)+
  stat_summary(fun = mean, geom="point",colour="darkred", size=3) +
  stat_summary(fun.data = fun_mean, geom="text", vjust=-0.7, aes(label=round(..y.., digits=3)),fontface = "bold")+
  labs(x="Breed",y="F coefficient", title = "Inbreeding Coefficient_pass")

dev.off()



dF %>% 
  mutate(avg=mean(F)) %>% 
  group_by(breed) %>% 
  summarise(Avg_group=mean(F),Total_Mean=first(avg))
