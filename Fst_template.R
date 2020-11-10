#sed AAAA to your target population name


setwd("/pdiskdata/zhenyinggroupADS/huangruoshi/wgsdata/70/snp/Fst/")
library(ggplot2)
library(dplyr)


Fst_AAAA <- read.delim("Fst_RJF_AAAA_40_20.windowed.weir.fst", stringsAsFactors = FALSE)
Fst_AAAA$CHROM=factor(as.character(Fst_AAAA$CHROM), levels=paste0(c(1:28)))
levels(Fst_AAAA$CHROM)
Fst_AAAA <- Fst_AAAA[order(Fst_AAAA[,1]),]
d <-data.frame(chr = Fst_AAAA$CHROM, bp = Fst_AAAA$BIN_START, Fst = Fst_AAAA$WEIGHTED_FST, snps = Fst_AAAA$N_VARIANTS)

sum(d$Fst<0)
d$Zfst <- (d$Fst-mean(d$Fst))/sd(d$Fst)



d$pos <- NA
d$index <- NA

ind = 0
for (i in unique(d$chr)){
  ind = ind + 1
  d[d$chr==i,]$index = ind
}

lastbase = 0
for(i in unique(d$index)){
  if(i==1){
    d[d$index==i, ]$pos=d[d$index==i, ]$bp
  } else {
    lastbase=lastbase+tail(subset(d,index==i-1)$bp,1)
    d[d$index==i, ]$pos=d[d$index==i, ]$bp+lastbase
  }
}



d$cc <-NA
for (i in unique(d$index)){
  d[d$index==i,]$cc = i%%2+1
} 

#pdf(file = "AAAA_Zfst_input2.pdf", width = 16,height = 4) 

pdf(file = "Distribution_AAAA_Zfst_input2.pdf", width = 10,height = 10)

# The actual plotting for Zfst

p<-ggplot(d,aes(pos,Zfst))
p+geom_point(aes(colour=factor(d$cc))) + 
  labs(x='Position', y='Zfst', title = 'AAAA Zfst input2') + 
  geom_hline(yintercept = 6)+
  #ylim(-0.2,1)+
  scale_x_continuous()


# This is for the Distribution 
# to see if it is close to normal distribution


p<-ggplot(d,aes(Fst))
p+geom_histogram(position="identity", binwidth = 0.01) +
  xlim(-0.75,1) +
  labs(title = "Fst Distribution(RJF_AAAA)" )


dev.off()
