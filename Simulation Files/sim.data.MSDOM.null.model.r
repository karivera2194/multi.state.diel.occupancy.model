#######################################
# Brian D. Gerber 
# 06/29/2020
#
# This script is intended to simulate multi-state occuancy data where the states are defined
# based on temporal use of a site.
#
# 4 States
# 1: No use
# 2: Day only
# 3: Night Only
# 4: Night and Day

#  ****This script simulates data from the Null model without covariates****

# The Null model - the probabiltiy of occurence and detection in each of the used states (2,3,4) 
#                  are all the same.
########################################
#######################################
#Setup the workspace
rm(list=ls())

#Which file name should we save the simulated data
#The saved simulations will be saved within the working directory.
filename="Simulation Files/sim.null.data"

#How many datasets to simualte
n.sim=100

#How many sites and occasions
n.sites=200 #number of sites
n.occs=5    #number of surveys per site
#################################################

#Define the MSTO model type
model.type="Null"

#The null model assumed the probability of occupancy in state 2,3, and 4 are all the same

#Define the logit-value for the probability of occurrence in each state (2,3,4)
alpha=1.2
mat=c(log(3),alpha,alpha,alpha)
mat=exp(mat)


#Omega are the probability of site i for each state - in order  - states 1,2,3,4
#These are mutually exclusive probabilities and must sum to 1
omega=mat/sum(mat)
sum(omega)

#Alternative specification for the same model
# psi.overall=sum(omega[2:4])
# omega[2]=psi.overall/3
# omega[3]=psi.overall/3
# omega[4]=psi.overall/3
# omega[1]=1-omega[2]-omega[3]-omega[4]

psi0=omega[1]
psiDay=omega[2]
psiNight=omega[3]
psiND=omega[4]

#################################################
#Define the state-dependent detection matrix

#probability of detection of the species, regardless of the state
pdet=0.7

#These need to be equivalent
pDay=pdet          #probability of detecting state 2 when in state 2
pNight=pdet         #probability of detecting state 3 when in state 3

#Probability of detection in state 4
#State 2,3,4 detection should be equivalent and the sum should add to pdet
mat=c(log(3),qlogis(pdet),qlogis(pdet),qlogis(pdet))
mat=exp(mat)
omega.det=mat/sum(mat)
sum(omega.det)

#This should be equal to pdet
sum(omega.det[2:4])

pND.ND=omega.det[4]
pND.0=omega.det[1]
pND.D=omega.det[2]
pND.N=omega.det[3]

#This would be true if there was state dependent detection, but there is not in the NUll model:
# pND.ND=pdet*pdet    #probabilty of detecting state 4 when in state 4
# pND.0=(1-pdet)*(1-pdet) #probabilty of detecting state 1 when in state 4
# pND.D=(1-pdet)*pdet #probabilty of detecting state 2 when in state 4
# pND.N=pdet*(1-pdet) #probabilty of detecting state 3 when in state 4


#This function creates the detection matrix
source("Simulation Files/det.matrix.func.r")
det.matrix=det.matrix.func(pNight,pDay,pND.N,pND.D,pND.ND,pND.0)
det.matrix

#Check to make sure the sums of the rows (true states) equal one and no negative values
rowSums(det.matrix)

length(which(det.matrix<0))

#################################################
#Setup storage of simulation information
names.list=c("Model","n.sim","n.sites","n.occs","omega","marginal.probs","det.matrix",
             "state.occ.matrix","state.occurence","obs.matrix")

sim.data=vector("list",length(names.list))
names(sim.data)=names.list

#Save defined inputs of simulation
sim.data$Full.Model=model.type
sim.data$n.sim=n.sim
sim.data$n.sites=n.sites
sim.data$n.occs=n.occs
sim.data$omega=omega
sim.data$det.matrix=det.matrix

#True occurence and observed data change for each iteration of n.sim
sim.data$state.occ.matrix=vector("list",n.sim)
sim.data$state.occurence=vector("list",n.sim)
sim.data$obs.matrix=vector("list",n.sim)

#start data simulation loop
for(z in 1:n.sim){
  
  #Simulate true occurrence states using the omega probs
  state.occurence.matrix=rmultinom(n.sites,1,prob=omega)
  rownames(state.occurence.matrix)=rownames(det.matrix)
  
  #reduced matrix to simple vector format
  state.occurence=apply(state.occurence.matrix,2,FUN=function(x){which(x==1)})
  
  #save true occurrences
  sim.data$state.occ.matrix[[z]]=state.occurence.matrix
  sim.data$state.occurence[[z]]=state.occurence
  
  #Simulate the detection process
  obs.matrix=matrix(0,nrow=n.sites,ncol=n.occs)
  for(i in 1:n.sites){
    for(j in 1:n.occs){
      temp=rmultinom(1,1,state.occurence.matrix[,i]%*%det.matrix)
      obs.matrix[i,j]= apply(temp,2,FUN=function(x){which(x==1)})
    }
  }
  
  #Here is the data we observe, n.sites by n.occs
  
  sim.data$obs.matrix[[z]]=obs.matrix
  print(z)
} ##END SIMULATION LOOP
########################################
########################################

#save sim.data to the correct directory
save(sim.data,file=paste(filename))

