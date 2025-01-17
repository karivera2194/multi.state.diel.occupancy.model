
# **A repository for the multi-state diel occupancy model (MSDOM):** 

### River, K, Fidino, M, Farris, ZJ, Murphy, A, Magle, SB, and Gerber, BD. Rethinking habitat occupancy modeling and the role of diel activity in an anthropogenic world. In Review.
---


**This repository includes 6 subfolders: Chicago coyote, Data Processing, JAGS, Makira Fosa2, RNP Fosa, and Simulation Files.**
1) The **Chicago coyote** folder includes data, R scripts, and plots specific to case study on coyotes that uses the dynamic MSDOM.
2) The **Data Procesing** folder includes R scripts and example data on how to prepare data for the MSDOM.
3) The **JAGS** folder includes JAGS models for the static and dynamic MSDOM, including the full, reduced, and null parameterizations.
4) The **Makira Fosa2** folder includes fosa data from Makira Natural Park and R scripts for fitting the static MSDOM, including model comparison using CPO.
5) The **RNP Fosa** folder includes fosa data from Ranomafana National Park and R scripts for fitting the MSDOM, including model comparison using CPO.
6) The **Simulation Files** folder includes scripts for simulating data under different versions of the static and dynamic MSDOM (full, reduced, null) and fitting these models using JAGS.


---

<div align="center"><img width="150" height="auto" src="coyote.jpg" alt="A silhouette of a coyote." /></div>
<div align="center"> <h3>Chicago coyote</h3> </div>

If you are interested in fitting the suite of dynamic MSDOMs we did to the coyote
data, then all you need to run is `./Chicago coyote/fit_models.R`.

### Sub-folders

**data** - Folder of coyote data files

**figures** - Folder of dynamic MSDOM results using coyote data

**mcmc_plots** - Folder of MCMC traceplots of model parameters

**pngs** - Folder of icons used in figures

### Scripts

**analysis_utilities.R** - A contains the function `make_model_matrix`, which
is used to make the design matrix for the dynamic MSDOMs across the three models
fit to the coyote data, which makes it possible to fit all the models in a for
loop within `./Chicago coyote/fit_models.R`.

**calculate_steady_state.R** - estimating steady state occupancy from a transition matrix, used after a model has been fit.

**extract_covariates.R** - extracting site-level urbanization covariates. This
script requires you to have the associated raster or shape files downloaded on
your local computer (the script outlines where we downloaded them from).

**fit_models.R** - fits the dynamic MSDOM models to the coyote data. Assumes that 
the repository is the current working directory.

**model_selection.R** - model comparison via CPO, ran after models are fit.

**plot_tpm.R** - evaluating the best fit-model to make figures

**plot_utilities.R** - model output processing for plotting

**prep_objects_for_model.R** - Sourced by fit_models.R and model_selection.R scripts more clear. This script essentially prepares all of the data for analysis. Definitely
something to look through if you are running `./Chicago coyote/fit_models.R` as 
a number of objects are created in here that are used (e.g., a `models` data.frame 
with formulas that specify the models being fit).

**scrub_coyote_data.R** - arrange detection non-detction with observed diel states. This is a good example of how you would prepare your raw camera trap data for analysis with an MSDOM (for the four state model we used).

**spatial_utilities.R** - This contains a suite of functions to extract covariate
data. It's an older working version of https://github.com/mfidino/uwinspatialtools.

**summarise_parameters.R** - processing model fit output. We used this to get
expected parameter estimates for the results section and put them into a 
transition probability matrix (to make is easier to look at).


---

<div align="center"> <h3>Data Processing</h3> </div>

This folder is for the static MSDOM case studies.

**Example_Detection_Matrix.csv** - single state detection/non-detection matrix

**Example_Photo_Data.csv** - original photo data relevant to the example detection matrix

**diel.occ.fun.R** - the function called by Diel.Occ.Script.R

**Diel.Occ.Script.R** - script to convert a single-state occupancy detection matrix into a 4 state diel matrix

---

<div align="center"><img width="150" height="auto" src="raccoon.jpg" alt="A silhouette of a raccoon." /></div>

<div align="center"><h2>JAGS folder</h2></div>

<div align="left"><h3>Dynamic MSDOMs</h3> </div>

Note: These dynamic models have been written in a way to work with the output
from the make_model_matrix function used in `./Chicago coyote/fit_models.R`.  

**jags.dynamic.fake.multistate.R** - standard dynamic occupancy model generalized to be fit with multi-state data

**jags.dynamic.multistate.covars.R** - dynamic MSDOM with second-order
parameters and covariates.

**jags.dynamic.multistate.null.R** - dynamic MSDOM parameterized without second-order parameters


<div align="left"> <h3>Static MSDOM</h3> </div>
<div align="center"> <h4>FULL Model</h3> </div>

**jags.multistate.occ.full.R** - Full MSDOM with probabilities estimated directly (no logit transformation) without site covariates.

**jags.multistate.occ.full.alt.R**- Full MSDOM with probabilities estimated on the logit scale without site covariates. 

**jags.multistate.occ.full.alt.RE.R** - Full MSDOM with probabilities estimated on the logit scale; detection and occupancy parameters are realizations from a higher order Normal distribution (i.e. random effect). No covariates.

**jags.multistate.occ.full.site.covs.by.state.R** - Full MSDOM with probabilities estimated on the logit scale, in which occupancy parameters are modeled using any set or size of site covariates, separately for each state.

**jags.multistate.occ.full.site.covs.R** - Full MSDOM with probabilities estimated on the logit scale, in which occupancy parameters are modeled using the same single site covariate, separately for each state.

**jags.multistate.occ.full.site.covs.RE.R** - Full MSDOM with probabilities estimated on the logit scale, in which occupancy parameters are modeled using separate covariates for each state and detection and occupancy parameters are realizations from a higher order Normal distribution (i.e. random effect).   

<div align="center"> <h4>REDUCED</h3> </div>

**jags.multistate.occ.reduced.R** - Reduced MSDOM with probabilities estimated directly (no transformation).

**jags.multistate.occ.reduced.alt.R** - Reduced MSDOM with occupancy probabilities estimated directly and detection probabilities estimated on the logit scale.

**jags.multistate.occ.red.det.full.R** - Reduced MSDOM with a reduced state occupancy parameterization (no transformation) and full state detection probability parameterization (no transformation).

**jags.multistate.occ.reduced.site.covs.R** - Reduced MSDOM in which logit-scaled occupancy parameters are modeled using the same single site covariate and state detection probabilities are reduced (no transformation).

**jags.multistate.occ.reduced.alt.RE.R** - Reduced MSDOM in which all parameters are estimated on the logit scale and state and detection proabilities are realizations from separate higher order Normal distributions (i.e. random effect).   

**jags.multistate.occ.reduced.site.covs.RE.R** - Reduced MSDOM in which all parameters are estimated on the logit scale and state occupancy parameters are modeled using separate (single) site covariates; detection and occupancy parameters are realizations from separate higher order Normal distributions (i.e. random effect).   

**jags.multistate.occ.reduced.site.covs.by.state.R**- Reduced MSDOM in which all parameters are estimated on the logit scale and state occupancy parameters are modeled using any set and any number of separate site covariates.

<div align="center"> <h4>NULL</h3> </div>

**jags.multistate.occ.null.R** - Null MSDOM, in which there is no state variation in occupancy or detection parameters; parameters are estimated directly (no transformation).

**jags.multistate.occ.null.alt.R** - Null MSDOM, in which there is no state variation in occupancy or detection parameters; parameters are estimated on the logit scale.

**jags.multistate.occ.null.det.null.R** - Null MSDOM, in which there is no state variation in occupancy or detection parameters; occupancy parameters are estimated on the logit scale and detection parameters are estiamted without transformation.

**jags.multistate.occ.null.alt.RE.R** - Null MSDOM, in which there is no state variation in occupancy or detection parameters; detection and occupancy parameters are realizations from separate higher order Normal distributions (i.e. random effect).   

**jags.multistate.occ.null.site.covs.R** - Null MSDOM, in which there is no state variation in occupancy or detection parameters; occupancy parameters are modeled on the logit scale using the same site-covariate and detection parameters are estimated on the logit scale without covariates.   

**jags.multistate.occ.null.site.covs.by.state.R** - Null MSDOM, in which there is no state variation in occupancy or detection parameters; occupancy parameters are modeled on the logit scale using any set of the same site-covariates and detection parameters are estimated on the logit scale without covariates. 

**jags.multistate.occ.null.site.covs.RE.R** - Null MSDOM, in which there is no state variation in occupancy or detection parameters; occupancy parameters are modeled on the logit scale using any set of the same site-covariates and detection parameters are estimated on the logit scale without covariates. Detection and occupancy parameters are realizations from separate higher order Normal distributions (i.e. random effect)

---

<div align="center"> <h3>Makira Fosa2</h3> </div>

**AJB-FRK-LKT-MGB-SLJ-SOA-VIN** - Each folder contains site-level diel detection/non-detection data (4 states) and covariate information for the fosa

**makira.data.script.r** - data script to prepare detection data in a format useable for MSDOM model fitting

**Makira.data2** - R object containing the prepared data for model fitting

**Makira.fosa.det.parms.png** - posterior estimates of detection probabilites from the most supported model

**Makira.fosa.occ.parms.png** - posterior estimates of occupancy probabilites from the most supported model

**makira.modeling.script.r** - static MSDOM model fitting to Makira fosa data

**makira.MSTOM.plotting.r** - basic plotting from model output

**multi.state.likelihood.r** - MSDOM likelihood for 4 states used to compare models

**CPO.function.RE.r** - MSDOM likelihood for 4 states used to compare models

**CPO.out.Makira.csv** - script to calculate CPO from a model with random effects on occupancy and detection parameters


---

<div align="center"> <h3>RNP Fosa</h3> </div>

**CPO.function.r** - model comparison script

**CPO.out.RNP.csv** - results of model comparison using CPO

**GOF.r** - posterior predictive check function

**M1.full.fit** - R object of most supported model used for plotting

**RNP.GOF.r** - script to process posterior predictive check

**RNP.MSDOM.modeling.script.r** - fosa RNP model fitting without an effect for survey

**RNP.MSDOM.modeling.script2.r** - fosa RNP model fitting of the same models but with a categorical effect for survey. 

**RNP.MSTOM.plotting.r** - basic plotting of model object

**RNP.fosa.State.Prob.png** - predicted state probabilities varying by distance to nearest village

**RNP.fosa.det.parms.png** - posterior distributions of detection parameters from the most supported model

**RNP.fosa.parms.png** - posterior distributions of occupancy parameters from the most supported model

**RNP2.data** - R object of fosa RNP data

**RNP2007.csv** - prepared 4-state detection/non-detection data of fosa from RNP

**multi.state.likelihood.r** - MSDOM likelihood function to be used for model comparison 

---

<div align="center"> <h3>Simulation Files</h3> </div>

**dynamic_simulations** - Folder for simulating dynamic MSDOM data. There are four simulation scripts, which can be used to fit the full dynamic MSDOM (with or without
independent detection parameters for the fourth state), as well as the dynamic model
without second order parameters. The final script in here `dynamic_utilities.R`, has
a lot of functions that were written to streamline the simulations, and has some 
functions that are even used in `./Chicago coyote/fit_models.R`.

**MARK.2.species** - Folder containing output results from MARK model fitting using the unconditional 2 species occupancy model

**det.matrix.func.r** - function to put detection parameters into a matrix

**fit.sim.data.MSDOM.r** - fits simulated MSDOM data using JAGS models

**model.comparison.CPO.r** - compares models via CPO

**MSDOM Full comparison with 2.species.occ.model.r** - comparison of the original unconditional two species occupancy model with that of the MSDOM Full model

**MSDOM Full comparison with 2.species.occ.model2.R** - comparison of the conditional two species occupancy model with that of the MSDOM Full model

**multi.state.likelihood.r** - likelihood function for the 4 state MSDOM

**null.model.comparison.r** - compares the null model MSDOM estimates of overall occupancy with estimates of occupancy from simple occupancy model without state designations

**sim.data.MSDOM.full.model.r** - script to simulate data from the full MSDOM

**sim.data.MSDOM.null.model.r** - script to simulate data from the null MSDOM

**sim.data.MSDOM.reduced.model.r** - script to simulate data from the reduced MSDOM

**sim.full.data** - R object of simulated data from the full MSDOM

**sim.null.data** - R object of simulated data from the null MSDOM

**sim.reduced.data** - R object of simulated data from the reduced MSDOM

---