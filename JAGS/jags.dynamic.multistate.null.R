model{
######
# Detection model
######
for(i in 1:nsite) {
  for(ti in 1:nseason) {
    for(survey in 1:nsurvey) {
      y[i, ti, survey] ~ dcat( rdm[i, , z[i, ti], ti ] )
    }
  }
}
#######
# Latent state model
#######
for(i in 1:nsite) {
  # for first season
  z[i, 1] ~ dcat( PSI[i, ] )
  for(t in 2:nseason) {
    z[i, t] ~ dcat( tpm[i, , z[ i, t-1], t-1] )
  }
}
for( i in 1:nsite ) {
######
# Fill in all of the transition probabilities
######
######
# Latent state for first season, PSI = transition vector for season 1
######
# First season probabilities for each state
PSI[i, 1] <- 1 #------------------------------------------------------------|U
PSI[i, 2] <- exp( psi[1, i] ) #---------------------------------------------|D
PSI[i, 3] <- exp( psi[2, i] ) #---------------------------------------------|N
PSI[i, 4] <- exp( psi[1, i] + psi[2, i] ) #---------------------------------|DN
for(t in 2:nseason) {
######
# Latent state for dynamic part of model
# tpm = transition probability matrix. All columns sum to 1.
# dim(tpm)[1] = site i 
# dim(tpm)[2] = state at time t
# dim(tpm)[3] = state at time t-1
# dim(tpm)[4] = time t (for temporally varying covariates)
######
# U to ...
tpm[i, 1, 1, t-1] <- 1 #----------------------------------------------------|U
tpm[i, 2, 1, t-1] <- exp( gam[1, i, t-1] ) #--------------------------------|D
tpm[i, 3, 1, t-1] <- exp(                  gam[2, i, t-1] ) #---------------|N
tpm[i, 4, 1, t-1] <- exp( gam[1, i, t-1] + gam[2, i, t-1] ) #---------------|DN
# D to ...
tpm[i, 1, 2, t-1] <- exp( eps[1, i, t-1] ) #--------------------------------|U
tpm[i, 2, 2, t-1] <- 1 #----------------------------------------------------|D
tpm[i, 3, 2, t-1] <- exp( eps[1, i, t-1] + gam[2, i, t-1] ) #---------------|N
tpm[i, 4, 2, t-1] <- exp(                  gam[2, i, t-1] ) #---------------|DN
# N to ...
tpm[i, 1, 3, t-1] <- exp(                  eps[2, i, t-1] ) #---------------|U
tpm[i, 2, 3, t-1] <- exp( gam[1, i, t-1] + eps[2, i, t-1] ) #---------------|D
tpm[i, 3, 3, t-1] <- 1 #----------------------------------------------------|N
tpm[i, 4, 3, t-1] <- exp( gam[1, i, t-1] ) #--------------------------------|DN
# DN to ..
tpm[i, 1, 4, t-1] <- exp( eps[1, i, t-1] + eps[2, i, t-1] ) #---------------|U
tpm[i, 2, 4, t-1] <- exp( eps[2, i, t-1] ) #--------------------------------|D
tpm[i, 3, 4, t-1] <- exp(                  eps[1, i, t-1] ) #---------------|N
tpm[i, 4, 4, t-1] <- 1 #----------------------------------------------------|DN
} # close t year loop
######
# detection matrix (OS = observed state, TS = true state)
# rdm = rho detection matrix. Each row sums to 1.
# OS along rows, TS along columns
######
# TS = U
for(ti in 1:nseason) {
rdm[i, 1, 1, ti] <- 1 #-------------------------------------------------|OS = U
rdm[i, 2, 1, ti] <- 0 #-------------------------------------------------|OS = D
rdm[i, 3, 1, ti] <- 0 #-------------------------------------------------|OS = N
rdm[i, 4, 1, ti] <- 0 #-------------------------------------------------|OS = DN
# TS = D
rdm[i, 1, 2, ti] <- 1 #-------------------------------------------------|OS = U
rdm[i, 2, 2, ti] <- exp( rho[1, i, ti] ) #------------------------------|OS = D
rdm[i, 3, 2, ti] <- 0 #-------------------------------------------------|OS = N
rdm[i, 4, 2, ti] <- 0 #-------------------------------------------------|OS = DN
# TS = N
rdm[i, 1, 3, ti] <- 1 #-------------------------------------------------|OS = U
rdm[i, 2, 3, ti] <- 0 #-------------------------------------------------|OS = D
rdm[i, 3, 3, ti] <- exp( rho[2, i, ti] ) #------------------------------|OS = N
rdm[i, 4, 3, ti] <- 0 #-------------------------------------------------|OS = DN
# TS = DN
rdm[i, 1, 4, ti] <- 1 #-------------------------------------------------|OS = U
rdm[i, 2, 4, ti] <- exp( rho[1+to_add, i, ti] ) #-----------------------|OS = D
rdm[i, 3, 4, ti] <- exp(                  rho[2+to_add, i, ti] ) #------|OS = N
rdm[i, 4, 4, ti] <- exp( rho[1+to_add, i, ti] +  rho[2+to_add, i, ti] )#|OS = DN
} # close ti year
######
# Fill in the linear predictors for the transition matrices
######
for( s in 1:ncat ) {
# base occupancy
psi[s ,i] <- inprod( a[s, ], psi_cov[i, ] )
for(t in 2:nseason) {
# base colonization
gam[s, i, t-1] <- inprod( b[s, ], gam_cov[i, ,t-1] ) 
# base extinction
eps[s, i, t-1] <- inprod( d[s, ], eps_cov[i, , t-1] )
} # close t
} # close category
for(srho in 1:(ncat+to_add)){
  for(ti in 1:nseason){
    # base detection probability, allowing for non-independent detections
    rho[srho, i, ti] <- inprod( f[srho, ], rho_cov[i, , ti] ) 
  }
}
} # closes for loop for i (sites) all the way up at the top of the model
#####
# Priors
######
  for(s in 1:ncat){
    # Initial Occupancy
    for( psip in 1:ncov_psi ){
      a[s, psip] ~ dlogis(0, 1)
    }
    # Colonization
    for( gamp in 1:ncov_gam ){
      b[s, gamp] ~ dlogis(0, 1)
      #b0[i, gamp] ~ dlogis(0, 1)
    }  
    # Extinction
    for( epsp in 1:ncov_eps ){
      d[s, epsp] ~ dlogis(0, 1)
      #d0[i, epsp] ~ dlogis(0, 1)
    }
  }
  for(srho in 1:(ncat + to_add)){
  # Detection, allowing for non-independent detections
    for( rhop in 1:ncov_rho ){
      f[srho, rhop] ~ dlogis(0, 1)
    }
  }
}