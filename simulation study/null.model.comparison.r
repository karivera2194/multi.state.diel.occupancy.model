#######################################
# Brian D. Gerber 
# 07/13/2020
########################################

#Assuming data have been simulated and an object has been output that stored the simulated data
# See script   sim.data.MSTOM.null.model.r

#States
#1: No use
#2: Day only
#3: Night Only
#4: Night and Day


#This script comapres the null model multi-state estimates of overall occupancy 
# P(state 2)+P(state 3)+ P(state4) with estimates of psi from simple occupancy model
#without state designations, only occurence and non-occurence. The simple occupancy model
#is estimated in the likelihood framework using the R package unmarked.
################################################
#Setup workspace
rm(list=ls())

#Requires the program JAGS to be installed
library(jagsUI)
library(rjags)

#Load the simulated data - choose one
load("simulation study/sim.data.multistate.null") 

#This is the simulated true logit coeficient
alpha=1.2

#This is the true probability of detection for the simulated data
pdet.truth=0.7

sim.data$omega

overall.occu.true=sum(sim.data$omega[2:4])
overall.occu.true

#which iteration of data sim to use
q=10

# MCMC settings
ni <- 5000  ;       nt <- 1;        nb <- 1000;  nc <- 1;  adapt <- 1000


  #Get the observed data from the simulation output
  obs.matrix=sim.data$obs.matrix[[q]] #observed data
  
  #Bundle data for jags
  data.list <- list(
    y = obs.matrix, 
    R = dim(obs.matrix)[1],
    T = dim(obs.matrix)[2]
  )
  
  #Initial values
  zst=rep(4,dim(data.list$y)[1])
  inits <- function(){list(z = zst)}
  
  ################################################################
  #Fit the Null Model 
  params <- c("psi","pdet","alpha","beta","psi.overall")
  #Prepare the model and data
  model.null <- jags.model(
    file="JAGS/jags.multistate.occ.null.R", 
    data = data.list,
    inits=inits,
    n.chains = nc,
    n.adapt=adapt
  )
  
  #Do a burn in period
  update(model.null,n.iter=nb,progress.bar="none")
  
  #Fit the model  
  model.null.fit <- jags.samples(
    model.null, variable.names=params, 
    n.iter=ni, 
    thin=nt,
    progress.bar="none"
  )
  
  #save the parameters
  alpha.samples=model.null.fit$alpha[,,1]
  beta.samples=model.null.fit$beta[,,1]
  psi.samples=model.null.fit$psi[,,1]
  psi.overall=model.null.fit$psi.overall[,,1]
  pdet.samples=model.null.fit$pdet[,,1]
  
  #We need to derive state occupancy and detection probs
  psiDay=psi.samples
  psiNight=psi.samples
  psiND=psi.samples
  psi0=1-psiDay-psiNight-psiND
  #psi.overall=psiDay+psiNight+psiND
  
  #plot the overall occupancy 
  hist(psi.overall)
  #add lines for the posterior mean and true overall occupancy
  abline(v=mean(psi.overall),lwd=3,col=1)
  abline(v=overall.occu.true,lwd=3,col=2)
  
  hist(pdet.samples)
  abline(v=pdet.truth, lwd=3, col=2)

#Estimate likelihood based overall occurence without states  
#We need to remove the state designations in the data
  library(unmarked)
  y1=obs.matrix
  y1[which(y1==1,arr.ind = TRUE)]=0
  y1[which(y1==2,arr.ind = TRUE)]=1
  y1[which(y1==3,arr.ind = TRUE)]=1
  y1[which(y1==4,arr.ind = TRUE)]=1
  
  #make sure there are only 0 and 1's
  table(y1)
  
  #Put in unmarked framework
  UMF <- unmarkedFrameOccu(y1)
  m1 <- occu(~ 1 ~ 1, UMF,method="Nelder-Mead")
  unmarked.est.psi=backTransform(m1, "state")
  unmarked.est.det=backTransform(m1, "det")
  
  #add the mle estimate
  abline(v=unmarked.est.psi@estimate,lwd=3,col=3,lty=3)
  #Note that the MLE corresponds to the highest posterior value 

  ####################
  #plot the logit coeficient for occurence
  hist(alpha.samples) #posterior samples
  #add the likelihood point estimate- which corresponds to the highest posterior value
  abline(v=m1@estimates@estimates$state@estimates,lwd=3,col=2)
  
  ####################
  #plot the detection probability
  hist(pdet.samples) #posterior samples
  #add the true probability of detection
  abline(v=pdet.truth,lwd=3,col=1)
  #add the likelihood point estimate -which corresponds to the highest posterior value
  abline(v=unmarked.est.det@estimate,lwd=3,col=2)

  ####################
  #plot the logit coeficient for detection
  hist(beta.samples) #posterior samples
  #add the likelihood point estimate-which corresponds to the highest posterior value
  abline(v=m1@estimates@estimates$det@estimates,lwd=3,col=2)
  
  
######################    
#Compare to RMark (MARK.exe needs to be installed)
  # library(RMark)
  # mark_input=as.data.frame(apply(y1,1,paste,collapse=""))
  # mark_input <- data.frame(lapply(mark_input, as.character), stringsAsFactors=FALSE)
  # colnames(mark_input)= c("ch")
  # 
  # psi.dot=list(formula=~1,link="logit")
  # p.dot=list(formula=~1,link="logit")
  # #Run model through RMARK
  # mrk= mark(mark_input,model="Occupancy",profile.int = TRUE,model.parameters=list(p=p.dot, Psi=psi.dot),adjust=FALSE,invisible=TRUE,silent=TRUE,delete=TRUE, 
  #               retry=5,brief=FALSE, output=FALSE)
  # 
  # mrk$results$beta
  # mrk$results$real
  # 