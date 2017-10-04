
library(ggplot2)

themePaul <- function () {
    theme_bw(base_size=12) %+replace%
        theme(
            legend.position = "bottom",
            plot.background = element_blank(),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.border= element_blank(),     
            axis.line = element_line(colour = "black"),
            axis.text=element_text(size=10),
            axis.title=element_text(size=10))
}


data1987 <- as.data.frame(read.csv("~/Dropbox/IPEDS_NoahSmith/Data/s1987_data_stata.csv"))
data1991 <- as.data.frame(read.csv("~/Dropbox/IPEDS_NoahSmith/Data/s1991_a_data_stata.csv"))
data1997 <- as.data.frame(read.csv("~/Dropbox/IPEDS_NoahSmith/Data/s97_s_data_stata.csv"))
data2001cn <- as.data.frame(read.csv("~/Dropbox/IPEDS_NoahSmith/Data/s2001_cn_data_stata.csv"))
data2001abd <- as.data.frame(read.csv("~/Dropbox/IPEDS_NoahSmith/Data/s2001_abd.csv"))

data2007abd <- as.data.frame(read.csv("~/Dropbox/IPEDS_NoahSmith/Data/s2007_abd_data_stata.csv"))

data2007cn <- as.data.frame(read.csv("~/Dropbox/IPEDS_NoahSmith/Data/s2007_cn_data_stata.csv"))
data2010f <- as.data.frame(read.csv("~/Dropbox/IPEDS_NoahSmith/Data/s2010_f_data_stata.csv"))
data2010cn <- as.data.frame(read.csv("~/Dropbox/IPEDS_NoahSmith/Data/s2010_cn_data_stata.csv"))
data2015 <- as.data.frame(read.csv("~/Dropbox/IPEDS_NoahSmith/Data/s2015_oc_data_stata.csv"))

colnames(data1987)

parsed1987 <- data1987  %>% summarize(numFullWomen = sum(al02c02,  na.rm=TRUE), numFullMen = sum(al02c01, na.rm=TRUE), numPartTimeWomen = sum(al02c01, na.rm=TRUE), numPartTimeMen = sum(al02c03, na.rm=TRUE)) %>% mutate(numFull = numFullMen + numFullWomen, numPart = numPartTimeWomen + numPartTimeMen)
parsed1991 <-data1991 %>% summarize(numFullWomen = sum(ftwom2,  na.rm=TRUE), numFullMen = sum(ftmen2, na.rm=TRUE), numPartTimeWomen = sum(ptwom2, na.rm=TRUE), numPartTimeMen = sum(ptmen2, na.rm=TRUE)) %>% mutate(numFull = numFullMen + numFullWomen, numPart = numPartTimeWomen + numPartTimeMen)
parsed1997 <- data1997 %>% group_by(part, line) %>% summarize(numMen = sum(staff15,  na.rm=TRUE), numWomen = sum(staff16, na.rm=TRUE)) %>% filter(line ==22 | line == 77 ) %>% mutate(numAll = numMen + numMen) 
parsed2001 <- data2001abd %>% group_by(line) %>% summarize(numMen = sum(staff15,  na.rm=TRUE), numWomen = sum(staff16, na.rm=TRUE))  %>% filter(line == 18 | line == 68) %>% mutate(numAll = numMen + numWomen) 
parsed2007 <- data2007abd %>% group_by(SABDTYPE) %>% summarize(numMen = sum(STAFF15,  na.rm=TRUE), numWomen = sum(STAFF16, na.rm=TRUE))  %>% filter((SABDTYPE ==11) | SABDTYPE == 70) %>% mutate(numAll = numMen + numWomen) 
parsed2015 <- data2015 %>% group_by(STAFFCAT) %>% summarize(numMen = sum(HRTOTLM,  na.rm=TRUE), numWomen = sum(HRTOTLW, na.rm=TRUE))  %>% filter((STAFFCAT ==2210) | STAFFCAT == 3200) %>% mutate(numAll = numMen + numWomen)



## Spot Check
fig1987 <- parsed1987 %>% select(numFull, numPart) %>% mutate(year = 1987)
fig1991 <- parsed1991 %>% select(numFull, numPart) %>% mutate(year = 1991)
fig1997 <- parsed1997 %>% select(part, numAll) %>% spread(part, numAll) %>% mutate(year = 1997)
fig2001 <- parsed2001 %>% select(line, numAll) %>% spread(line, numAll) %>% mutate(year = 2001)
fig2007 <- parsed2007 %>% select(SABDTYPE, numAll) %>% spread(SABDTYPE, numAll) %>% mutate(year = 2007)
fig2015 <- parsed2015 %>% select(STAFFCAT, numAll) %>% spread(STAFFCAT, numAll) %>% mutate(year = 2015)
colnames(fig1987) <- c("FullTime", "PartTime", "year")
colnames(fig1991) <- c("FullTime", "PartTime", "year")
colnames(fig1997) <- c("FullTime", "PartTime", "year")
colnames(fig2001) <- c("FullTime", "PartTime", "year")
colnames(fig2007) <- c("FullTime", "PartTime", "year")
colnames(fig2015) <- c("FullTime", "PartTime", "year")


fig1 <- rbind(fig1987, fig1991, fig1997, fig2001, fig2007, fig2015)
fig1 <- fig1 %>% gather(type, num, -year) %>% group_by(year) %>% mutate(share = num / sum(num))

g <- ggplot(data = fig1, aes(y=share, x=as.factor(year), fill=as.factor(type)))
g +  geom_bar(position = "dodge", stat="identity") +
         xlab("Year") + ylab("Share of Instructors (excluding Graduate Students") + 
            scale_fill_manual(values = c("#0072B2", "#E69F00"), name = "", 
                              labels = c("Full Time ", "Part Time"))+
                    scale_y_continuous(expand = c(0,0))+
                        themePaul()

ggsave("~/Dropbox/IPEDS_NoahSmith/Writeup/bar_part_full_overtime.pdf", width=16.4,height=10, units="cm")
ggsave("~/Dropbox/IPEDS_NoahSmith/Writeup/bar_part_full_overtime.png", width=16.4,height=10, units="cm")


## Decompose
parsed1987 <- data1987  %>%
    mutate(numFullWomen = al02c02, numFullMen = al02c01, numPartTimeWomen = al02c01, numPartTimeMen = al02c03) %>%
        mutate(numFull = numFullMen + numFullWomen, numPart = numPartTimeWomen + numPartTimeMen) %>%
            select(numFull, numPart, unitid) %>% mutate(year = 1987)
parsed1991 <-data1991 %>%
    mutate(numFullWomen = ftwom2, numFullMen = ftmen2, numPartTimeWomen = ptwom2, numPartTimeMen = ptmen2) %>%
        mutate(numFull = numFullMen + numFullWomen, numPart = numPartTimeWomen + numPartTimeMen) %>%
            select(numFull, numPart, unitid) %>% mutate(year = 1991)
colnames(parsed1987) <- c("id", "FullTime", "PartTime", "year")
colnames(parsed1991) <- c("id", "FullTime", "PartTime", "year")
parsed1997 <- data1997 %>% group_by(part) %>% mutate(numMen = staff15, numWomen = staff16) %>%
    filter(line ==22 | line == 77 ) %>% mutate(numAll = numMen + numMen)  %>% select(numAll, unitid, part)  %>%
        spread(part, numAll) %>% mutate(year = 1997)
colnames(parsed1997) <- c("id", "FullTime", "PartTime", "year")
parsed2001 <- data2001abd %>% group_by(line) %>%
    mutate(numMen = staff15, numWomen = staff16) %>%
        filter(line == 18 | line == 68) %>% mutate(numAll = numMen + numWomen)  %>% select(line, unitid, numAll)  %>%
            spread(line, numAll) %>% mutate(year = 2001)        
colnames(parsed2001) <- c("id", "FullTime", "PartTime", "year")
parsed2007 <- data2007abd %>% group_by(SABDTYPE) %>%
    mutate(numMen = STAFF15, numWomen = STAFF16)  %>%
        filter((SABDTYPE ==11) | SABDTYPE == 70) %>% mutate(numAll = numMen + numWomen)  %>%
            select(UNITID, numAll, SABDTYPE) %>% mutate(year = 2007) %>%select(SABDTYPE, UNITID, numAll)  %>%
                spread(SABDTYPE, numAll) %>% mutate(year = 2007)
colnames(parsed2007) <- c("id", "FullTime", "PartTime", "year")
parsed2015 <- data2015 %>% group_by(STAFFCAT) %>%
    mutate(numMen = HRTOTLM, numWomen = HRTOTLW)  %>%
        filter((STAFFCAT ==2210) | STAFFCAT == 3200) %>%
            mutate(numAll = numMen + numWomen) %>% select(numAll, UNITID, STAFFCAT)  %>% 
                spread(STAFFCAT, numAll)   %>% mutate(year = 2015)
colnames(parsed2015) <- c("id", "FullTime", "PartTime", "year")

parsed <- rbind(parsed1987, parsed1991, parsed1997, parsed2001, parsed2007, parsed2015)

parsed <- parsed[order(parsed$id,parsed$year),]  %>% filter(id > 10860)

fig1 <- parsed %>% group_by(year) %>% summarize(FullTime = sum(FullTime,na.rm=TRUE ), PartTime = sum(PartTime,na.rm=TRUE)) %>% gather(type, num, -year) %>% group_by(year) %>% mutate(share = num / sum(num))

g <- ggplot(data = fig1, aes(y=share, x=as.factor(year), fill=as.factor(type)))
g +  geom_bar(position = "dodge", stat="identity") +
         xlab("Year") + ylab("Share of Instructors (excluding Graduate Students") + 
            scale_fill_manual(values = c("#0072B2", "#E69F00"), name = "", 
                              labels = c("Full Time ", "Part Time"))+
                    scale_y_continuous(expand = c(0,0))+
                        themePaul()

ggsave("~/Dropbox/IPEDS_NoahSmith/Writeup/bar_part_full_overtime_panel.png", width=16.4,height=10, units="cm")
                                        

group_number = (function(){i = 0; function() i <<- i+1 })()
parsed <- parsed %>% group_by(year) %>% mutate(t = group_number())


fig2 <- parsed %>% group_by(id) %>% mutate(dFull = FullTime - lag(FullTime), dPart = PartTime - lag(PartTime)) %>%
    group_by(year) %>%
        summarize(numUniv = n(), dFull = sum(dFull, na.rm=TRUE), dPart = sum(dPart, na.rm=TRUE), FullTime = sum(FullTime,na.rm=TRUE ), PartTime = sum(PartTime,na.rm=TRUE)) %>%
            mutate(dFull2 = FullTime - lag(FullTime), dPart2 = PartTime - lag(PartTime)) %>%
                mutate(withinSharePart = dPart / dPart2, withinShareFull = dFull / dFull2) %>%
                    gather(type, num, -year) %>% group_by(year) 

g <- ggplot(data = fig1 %>% mutate(num = num / 1000), aes(y=num, x=as.factor(year), fill=as.factor(type)))
g +  geom_bar(position = "dodge", stat="identity") +
         xlab("Year") + ylab("Thousands of Instructors (excluding Graduate Students") + 
            scale_fill_manual(values = c("#0072B2", "#E69F00"), name = "", 
                              labels = c("Full Time ", "Part Time"))+
                    scale_y_continuous(expand = c(0,0))+
                        themePaul()
ggsave("~/Dropbox/IPEDS_NoahSmith/Writeup/bar_part_full_overtime_panel_number.png", width=16.4,height=10, units="cm")
g <- ggplot(data = fig2 %>% filter(type == "dFull" | type=="dFull2"), aes(y=num, x=as.factor(year), fill=as.factor(type)))
g +  geom_bar(position = "dodge", stat="identity") +
         xlab("Year") + ylab("Change in Full-Time Instructors") + 
            scale_fill_manual(values = c("#0072B2", "#E69F00", "black", "blue", "green"), name = "", 
                              labels = c("Change (within)", "Change (overall)"))+
                    scale_y_continuous(expand = c(0,0))+
                        themePaul()
ggsave("~/Dropbox/IPEDS_NoahSmith/Writeup/bar_full_panel_number_change.png", width=16.4,height=10, units="cm")
g <- ggplot(data = fig2 %>% filter(type == "dPart" | type=="dPart2"), aes(y=num, x=as.factor(year), fill=as.factor(type)))
g +  geom_bar(position = "dodge", stat="identity") +
         xlab("Year") + ylab("Change in Part-Time Instructors") + 
            scale_fill_manual(values = c("#0072B2", "#E69F00", "black", "blue", "green"), name = "", 
                              labels = c("Change (within)", "Change (overall)"))+
                    scale_y_continuous(expand = c(0,0))+
                        themePaul()
ggsave("~/Dropbox/IPEDS_NoahSmith/Writeup/bar_part_panel_number_change.png", width=16.4,height=10, units="cm")

g <- ggplot(data = fig2 %>% filter(type == "withinShareFull" | type=="withinSharePart"), aes(y=num, x=as.factor(year), fill=as.factor(type)))
g +  geom_bar(position = "dodge", stat="identity") +
         xlab("Year") + ylab("Pct. Share of Change from Existing Institutions") + 
            scale_fill_manual(values = c("#0072B2", "#E69F00", "black", "blue", "green"), name = "", 
                              labels = c("Full-Time", "Part-Time"))+
                    scale_y_continuous(expand = c(0,0))+
                        themePaul()
ggsave("~/Dropbox/IPEDS_NoahSmith/Writeup/bar_partfull_panel_number_pctchange.png", width=16.4,height=10, units="cm")

