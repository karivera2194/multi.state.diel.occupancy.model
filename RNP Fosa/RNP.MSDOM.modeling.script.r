#################################################################
#################################################################
#This script fits the Ranomafana National Park fosa occupancy camera trap data - Data from Gerber et al. 2012 and Gerber et al. 2010

#Gerber, B., Karpanty, S. M., Crawford, C., Kotschwar, M., & Randrianantenaina, J. (2010). An assessment of carnivore relative abundance and density in the eastern rainforests of Madagascar using remotely-triggered camera traps. Oryx, 44(2), 219-222.
#Gerber, B. D., Karpanty, S. M., & Randrianantenaina, J. (2012). The impact of forest logging and fragmentation on carnivore species composition, density and occupancy in Madagascar's rainforests. Oryx, 46(3), 414-422.

#Specifically, the data are camera surveys at Sahamalaotra and Valohoaka-Vatoharanana within the park.

#The 4 states are assigned as,

# 1: No use
# 2: Day only
# 3: Night Only
# 4: Night and Day


#Day was assigned as the period between sunrise and sunset
#Nigt was assigned as the period between sunset and sunrise

#Setup the workspace
rm(list=ls())
logit=function(x){log(x/(1-x))}
expit=function(x){exp(x)/(exp(x)+1)}
library(rjags)
library(runjags)
library(coda)
source("RNP Fosa/multi.state.likelihood.r")
source("RNP Fosa/CPO.function.r")

#load the prepared data file
load("RNP Fosa/RNP2.data")

#assign data to objects
y=RNP2.data[[1]] #detection history
covs=RNP2.data[[2]]

#Derive Site/Survey Covariates using effect coding, so the intercept is the mean of all
VOH=1:26
VA=27:53
CVB=54:95
survey=c(rep("VOH",length(VOH)),rep("VA",length(VA)),rep("CVB",length(CVB)))
X.survey=model.matrix(~survey,contrasts = list(survey = "contr.sum"))
head(X.survey)
#################################################################
#################################################################

#Examine covariate data

#FYI-The Locals covariate- all detections of people are during the day. There are no nighttime detections.
#Locals covariate is probably not a good measure of overall human/forest disturbance.

#Look at covariate correlations
cor(covs$DistMatrix,covs$Locals)
cor(covs$DistMatrix,covs$DistTown)
cor(covs$DistTown,covs$Locals)

hist(covs$DistMatrix)
hist(covs$Locals)
hist(covs$DistTown)

#First consider the FUll MSDOM with each covariate separately. Assume that the major source in
#detection is based on the states.

#################################################################
#################################################################
#Setup model fitting values
# Initial values- max state in hierarchy as starting value
zst=rep(4,dim(y)[1])
inits <- function(){list(z = zst)}

# MCMC settings
ni <- 20000  ;       nt <- 2;    nb <- 4000;    nc <- 3;   adapt=4000

#################################################################
#################################################################
#MODEL 1- DistTown covariate - FULL model
cov=covs$DistTown
hist(cov)
cov1.unscaled=as.numeric(cov)
cov1.scaled=as.numeric(scale(cov,center = TRUE,scale = TRUE))

Q=6 # number of alpha parameters

#Package data
data.input <- list(y = y, N = dim(y)[1], K = dim(y)[2],x=cov1.scaled,Q=Q)

# Parameters monitored
params <- c("alpha", "pNight", "pDay","pND","PSI")

#Fit the model to do adapt phase
model.jags <- jags.model(file="JAGS/jags.multistate.occ.full.site.covs.R", 
                         data = data.input,
                         inits=inits,
                         n.chains = nc,
                         n.adapt=adapt)

#burn in period
update(model.jags, n.iter=nb)

#Fit the model and get posterior samples
M1.full <- coda.samples(model.jags, variable.names=params, 
                        n.iter=ni, 
                        thin=nt,
                        progress.bar="text")
save(M1.full,file="RNP Fosa/M1.full.out")

#load("RNP Fosa/M1.full.out")

#plot(M1.full,ask=TRUE)

#Inspect diagnostics
gelman.diag(M1.full,multivariate = FALSE)

#combine the chains
fit <- combine.mcmc(M1.full)

str(fit)
attributes(fit)

dim(fit)
colnames(fit)

#To do model selection with CPO, we need to get site-level occurence and detection
#probabilities.
M1.full.CPO=CPO.function(fit,y,"full")
CPO.out=t(matrix(c("M1.full",M1.full.CPO)))
write.table(CPO.out,file="RNP Fosa/CPO.out.RNP.csv",append=TRUE,col.names = FALSE,sep=",",row.names = FALSE)

############################################################################
############################################################################
############################################################################
#MODEL 2- DistMatrix covariate - FULL model
cov=covs$DistMatrix
hist(cov)
cov1.unscaled=as.numeric(cov)
cov1.scaled=as.numeric(scale(cov,center = TRUE,scale = TRUE))

Q=6 # number of alpha parameters

#package Data
data.input <- list(y = y, N = dim(y)[1], K = dim(y)[2], x=cov1.scaled,Q=Q)

# Parameters monitored
params <- c("alpha", "pNight", "pDay","pND","PSI")  


#Fit the model to do adapt phase
model.jags <- jags.model(file="JAGS/jags.multistate.occ.full.site.covs.R", 
                         data = data.input,
                         inits=inits,
                         n.chains = nc,
                         n.adapt=adapt)

update(model.jags, n.iter=nb)

M2.full <- coda.samples(model.jags, variable.names=params, 
                        n.iter=ni, 
                        thin=nt,
                        progress.bar="text")
save(M2.full,file="RNP Fosa/M2.full.out")

#load("RNP Fosa/M2.full.out")

#plot(M2.full,ask=TRUE)

#Inspect Diagnostics
gelman.diag(M2.full,multivariate = FALSE)


#combine the chains
fit <- combine.mcmc(M2.full)

#To do model selection with CPO, we need to get site-level occurence and detection
#probabilities.
M2.full.CPO=CPO.function(fit,y,"full")
CPO.out=t(matrix(c("M2.full",M2.full.CPO)))
write.table(CPO.out,file="RNP Fosa/CPO.out.RNP.csv",append=TRUE,col.names = FALSE,sep=",",row.names = FALSE)

###################################################################
###################################################################
###################################################################
#Consider the same covariate models as above, but with the Reduced model
#MODEL 3- DistTown covariate - Reduced model
cov=covs$DistTown
hist(cov)
cov1.unscaled=as.numeric(cov)
cov1.scaled=as.numeric(scale(cov,center = TRUE,scale = TRUE))

Q=4 # number of alpha parameters

data.input <- list(y = y, N = dim(y)[1], K = dim(y)[2],x=cov1.scaled,Q=Q)

# Parameters monitored
params <- c("alpha", "pNight", "pDay","PSI") 

model.jags <- jags.model(file="JAGS/jags.multistate.occ.reduced.site.covs.R", 
                         data = data.input,
                         inits=inits,
                         n.chains = nc,
                         n.adapt=adapt)

update(model.jags, n.iter=nb)

M3.red <- coda.samples(model.jags, variable.names=params, 
                       n.iter=ni, 
                       thin=nt,
                       progress.bar="text")
save(M3.red,file="RNP Fosa/M3.red.out")

#load("RNP Fosa/M3.red")

#plot(M3.red,ask=TRUE)

#Inspect Diagnostics
gelman.diag(M3.red,multivariate = FALSE)



#combine the chains
fit <- combine.mcmc(M3.red)

#To do model selection with CPO, we need to get site-level occurence and detection
#probabilities.
M3.red.CPO=CPO.function(fit,y,"reduced")
CPO.out=t(matrix(c("M3.red",M3.red.CPO)))
write.table(CPO.out,file="RNP Fosa/CPO.out.RNP.csv",append=TRUE,col.names = FALSE,sep=",",row.names = FALSE)
#################################################
#################################################
#MODEL 4- DistMatrix covariate - Reduced model
cov=covs$DistMatrix
hist(cov)
cov1.unscaled=as.numeric(cov)
cov1.scaled=as.numeric(scale(cov,center = TRUE,scale = TRUE))

K=4 # number of alpha parameters

#package data
data.input <- list(y = y, N = dim(y)[1], K = dim(y)[2],x=cov1.scaled,Q=Q)

# Parameters monitored
params <- c("alpha", "pNight", "pDay","PSI") 

model.jags <- jags.model(file="JAGS/jags.multistate.occ.reduced.site.covs.R", 
                         data = data.input,
                         inits=inits,
                         n.chains = nc,
                         n.adapt=adapt)


update(model.jags, n.iter=nb)

M4.red <- coda.samples(model.jags, variable.names=params, 
                       n.iter=ni, 
                       thin=nt,
                       progress.bar="text")
save(M4.red,file="RNP Fosa/M4.red.out")

#load("RNP Fosa/M4.red)

#plot(M4.red,ask=TRUE)

#Inspect Diagnostics
gelman.diag(M4.red,multivariate = FALSE)

#combine the chains
fit <- combine.mcmc(M4.red)

#To do model selection with CPO, we need to get site-level occurence and detection
#probabilities.
M4.red.CPO=CPO.function(fit,y,"reduced")
CPO.out=t(matrix(c("M4.red",M4.red.CPO)))
write.table(CPO.out,file="RNP Fosa/CPO.out.RNP.csv",append=TRUE,col.names = FALSE,sep=",",row.names = FALSE)
######################################################
######################################################
#Need to fit the Null model with covariates

#MODEL 5- Distown covariate - Null model
cov=covs$DistTown
hist(cov)
cov1.unscaled=as.numeric(cov)
cov1.scaled=as.numeric(scale(cov,center = TRUE,scale = TRUE))

K=2 # number of alpha parameters

data.input <- list(y = y, N = dim(y)[1], K = dim(y)[2], x=cov1.scaled,Q=Q)

# Initial values- max state in hierachy as starting value
zst=rep(4,dim(y)[1])
inits <- function(){list(z = zst)}

# Parameters monitored
params <- c("alpha","beta" ,"p.overall", "PSI","psi.overall","psi") 

# MCMC settings
ni <- 10000  ;       nt <- 2;    nb <- 2000;    nc <- 3;   adapt=1000

#Fit the model to do adapt phase
#this is the full model
model.jags <- jags.model(file="JAGS/jags.multistate.occ.null.site.covs.R", 
                         data = data.input,
                         inits=inits,
                         n.chains = nc,
                         n.adapt=adapt)


#burn in period
update(model.jags, n.iter=nb)

#Fit the model and get posterior samples
M5.null <- coda.samples(model.jags, variable.names=params, 
                        n.iter=ni, 
                        thin=nt,
                        progress.bar="text")
save(M5.null,file="RNP Fosa/M5.null.out")

#load("RNP Fosa/M5.null.out")

#plot(M5.null)

#Inspect Diagnostics
gelman.diag(M5.null,multivariate = FALSE)

# Summarize posteriors
print(M5.null, dig = 2)

#combine the chains
fit <- combine.mcmc(M5.null)


#To do model selection with CPO, we need to get site-level occurence and detection
#probabilities.
M5.null.CPO=CPO.function(fit,y,"null")
CPO.out=t(matrix(c("M5.null",M5.null.CPO)))
write.table(CPO.out,file="RNP Fosa/CPO.out.RNP.csv",append=TRUE,col.names = FALSE,sep=",",row.names = FALSE)
#####################################
#MODEL 6- DistMatrix covariate - Null model
cov=covs$DistMatrix
hist(cov)
cov1.unscaled=as.numeric(cov)
cov1.scaled=as.numeric(scale(cov,center = TRUE,scale = TRUE))

Q=2 # number of alpha parameters

#package data
data.input <- list(y = y, N = dim(y)[1], K = dim(y)[2], x=cov1.scaled,Q=Q)

# Parameters monitored
params <- c("alpha","beta" ,"p.overall", "PSI","psi.overall","psi") 


model.jags <- jags.model(file="JAGS/jags.multistate.occ.null.site.covs.R", 
                         data = data.input,
                         inits=inits,
                         n.chains = nc,
                         n.adapt=adapt)


#burn in period
update(model.jags, n.iter=nb)

#Fit the model and get posterior samples
M6.null <- coda.samples(model.jags, variable.names=params, 
                        n.iter=ni, 
                        thin=nt,
                        progress.bar="text")
save(M6.null,file="RNP Fosa/M6.null.out")

#load("RNP Fosa/M6.null.out")

#plot(M6.null)

gelman.diag(M6.null,multivariate = FALSE)


#combine the chains
fit <- combine.mcmc(M6.null)

#To do model selection with CPO, we need to get site-level occurence and detection
#probabilities.
M6.null.CPO=CPO.function(fit,y,"null")
CPO.out=t(matrix(c("M6.null",M6.null.CPO)))
write.table(CPO.out,file="RNP Fosa/CPO.out.RNP.csv",append=TRUE,col.names = FALSE,sep=",",row.names = FALSE)

##########################################
##########################################
#Fit the null model with no covariates

#package data
data.input <- list(y = y, N = dim(y)[1], K = dim(y)[2])

# Parameters monitored
params <- c("alpha", "beta", "PSI","p.overall","psi") 

# MCMC settings
ni <- 10000  ;       nt <- 2;    nb <- 2000;    nc <- 3;   adapt=1000

#Fit the model to do adapt phase
#this is the full model
model.jags <- jags.model(file="JAGS/jags.multistate.occ.null.alt.R", 
                         data = data.input,
                         inits=inits,
                         n.chains = nc,
                         n.adapt=adapt)


update(model.jags, n.iter=nb)

M7.null <- coda.samples(model.jags, variable.names=params, 
                        n.iter=ni, 
                        thin=nt,
                        progress.bar="text")
save(M7.null,file="RNP Fosa/M7.null.out")

#load("RNP Fosa/M7.null")

#plot(M7.null)

#Inspect R-hat diagnostics
gelman.diag(M7.null,multivariate = FALSE)

#combine the chains
fit <- combine.mcmc(M7.null)


#To do model selection with CPO, we need to get site-level occurence and detection
#probabilities.
M7.null.CPO=CPO.function(fit,y,"null")
CPO.out=t(matrix(c("M7.null",M7.null.CPO)))
write.table(CPO.out,file="RNP Fosa/CPO.out.RNP.csv",append=TRUE,col.names = FALSE,sep=",",row.names = FALSE)

#############################################################
#################################################################
#################################################################
#MODEL 8- FULL model - no covs
K=3 # number of alpha parameters

data.input <- list(y = y, N = dim(y)[1], K = dim(y)[2])

# Initial values- max state in hierachy as starting value
zst=rep(4,dim(y)[1])
inits <- function(){list(z = zst)}

# Parameters monitored
params <- c("pNight","pDay","pND","PSI") 

# MCMC settings
ni <- 20000  ;       nt <- 2;    nb <- 4000;    nc <- 3;   adapt=4000

#Fit the model to do adapt phase
#this is the full model
model.jags <- jags.model(file="JAGS/jags.multistate.occ.full.R", 
                         data = data.input,
                         inits=inits,
                         n.chains = nc,
                         n.adapt=adapt)


update(model.jags, n.iter=nb)
M8.full.nocovs <- coda.samples(model.jags, variable.names=params, 
                               n.iter=ni, 
                               thin=nt,
                               progress.bar="text")

save(M8.full.nocovs,file="RNP Fosa/M8.full.nocovs.out")

#load("RNP Fosa/M8.full.nocovs.out")

#plot(M8.full.nocovs,ask=TRUE)

#Inspect diagnostics
gelman.diag(M8.full.nocovs,multivariate = FALSE)


#combine the chains
fit <- combine.mcmc(M8.full.nocovs)

M8.full.no.covs.CPO=CPO.function(fit,y,"full")
CPO.out=t(matrix(c("M8.full.no.covs",M8.full.no.covs.CPO)))
write.table(CPO.out,file="RNP Fosa/CPO.out.RNP.csv",append=TRUE,col.names = FALSE,sep=",",row.names = FALSE)

########################################
########################################
#MODEL 9- Reduced model - no covs

data.input <- list(y = y, N = dim(y)[1], K = dim(y)[2])

# Parameters monitored
params <- c("psiNight","psiDay", "pNight", "pDay","PSI")

model.jags <- jags.model(file="JAGS/jags.multistate.occ.reduced.R", 
                         data = data.input,
                         inits=inits,
                         n.chains = nc,
                         n.adapt=adapt)


update(model.jags, n.iter=nb)

M9.red.nocovs <- coda.samples(model.jags, variable.names=params, 
                              n.iter=ni, 
                              thin=nt,
                              progress.bar="text")
save(M9.red.nocovs,file="RNP Fosa/M9.red.nocovs.out")

#load("RNP Fosa/M9.red.nocovs.out")

#plot(M9.red.nocovs,ask=TRUE)

#Inspect diagnostics
gelman.diag(M9.red.nocovs,multivariate = FALSE)


#combine the chains
fit <- combine.mcmc(M9.red.nocovs)

M9.red.no.covs.CPO=CPO.function(fit,y,"reduced")
CPO.out=t(matrix(c("M9.red.no.covs",M9.red.no.covs.CPO)))
write.table(CPO.out,file="RNP Fosa/CPO.out.RNP.csv",append=TRUE,col.names = FALSE,sep=",",row.names = FALSE)


