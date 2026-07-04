library(ggplot2)


cverrors.seed1 <- c()
cverrors.seed2 <- c()
cverrors.seed3 <- c()

for(k in 2:6){
	cmd <- paste0("grep 'K=", k, "' allsamples/seed1/log", k, ".out | awk '{print $4}'")
	cv <- as.numeric(system(cmd, intern = TRUE))
	cverrors.seed1 <- append(cverrors.seed1, cv)
}

for(k in 2:6){
        cmd <- paste0("grep 'K=", k, "' allsamples/seed2/log", k, ".out | awk '{print $4}'")
        cv <- as.numeric(system(cmd, intern = TRUE)) 
        cverrors.seed2 <- append(cverrors.seed2, cv)
}

for(k in 2:6){
        cmd <- paste0("grep 'K=", k, "' allsamples/seed3/log", k, ".out | awk '{print $4}'")
        cv <- as.numeric(system(cmd, intern = TRUE)) 
        cverrors.seed3 <- append(cverrors.seed3, cv)
}


combined <- data.frame(k = c(2:6,2:6,2:6), error = c(cverrors.seed1, cverrors.seed2, cverrors.seed3))
combined$seed <- c(rep("1",5), rep("2",5), rep("3",5))
plot <- ggplot(data = combined, aes(x=k,y=error,color=seed))+
	geom_point()+
	geom_line()+
	scale_color_manual(values = c('red','blue','yellow'))+
	theme_minimal()+
	xlab("K")+
	ylab("CV Error")+
	ggtitle("Cross Validation Error Across K (all samples)")

ggsave(plot = plot, filename = "/media/maxlaubstein/data1/STJARangewideGenomics/plots/cverror_allsamples.pdf", device = "pdf", height = 7, width = 7, units = "in")



#####
#No meso
####

cverrors.seed1 <- c()
cverrors.seed2 <- c()
cverrors.seed3 <- c()

for(k in 2:6){
        cmd <- paste0("grep 'K=", k, "' nomeso/seed1/log", k, ".out | awk '{print $4}'")
        cv <- as.numeric(system(cmd, intern = TRUE))
        cverrors.seed1 <- append(cverrors.seed1, cv)
}

for(k in 2:6){
        cmd <- paste0("grep 'K=", k, "' nomeso/seed2/log", k, ".out | awk '{print $4}'")
        cv <- as.numeric(system(cmd, intern = TRUE))
        cverrors.seed2 <- append(cverrors.seed2, cv)
}

for(k in 2:6){
        cmd <- paste0("grep 'K=", k, "' nomeso/seed3/log", k, ".out | awk '{print $4}'")
        cv <- as.numeric(system(cmd, intern = TRUE))
        cverrors.seed3 <- append(cverrors.seed3, cv)
}


combined <- data.frame(k = c(2:6,2:6,2:6), error = c(cverrors.seed1, cverrors.seed2, cverrors.seed3))
combined$seed <- c(rep("1",5), rep("2",5), rep("3",5))
plot <- ggplot(data = combined, aes(x=k,y=error,color=seed))+
        geom_point()+
        geom_line()+
        scale_color_manual(values = c('red','blue','yellow'))+
        theme_minimal()+
        xlab("K")+
        ylab("CV Error")+
        ggtitle("Cross Validation Error Across K (all samples)")

ggsave(plot = plot, filename = "/media/maxlaubstein/data1/STJARangewideGenomics/plots/cverror_nomeso.pdf", device = "pdf", height = 7, width = 7, units = "in")


####
#Just seed 1 no meso for figure
####

cverrors.seed1 <- data.frame(K = 2:6, CV = cverrors.seed1)

plot <- ggplot(data = cverrors.seed1,aes(x=K,y=CV))+
	geom_point(color = 'black')+
	geom_line(color = 'black',linetype = "dashed")+
	theme_minimal()+
	xlab("K")+
	ylab("Cross Validation Error")+
	#ggtitle("ADMIXTURE CV Error vs. K")+
	theme(
		 axis.text.y = element_blank(),
	         axis.ticks.y = element_blank()   )


ggsave(plot=plot, filename = "/media/maxlaubstein/data1/STJARangewideGenomics/plots/cverrors_seed1.pdf", height = 2.25, width = 2.25, units = "in")
