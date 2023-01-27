library(devtools)
library(dplyr)
library(SuperLearner)
library(CRE)
set.seed(2022)

statename <- "united_states"
t_pm25 <- 8
outcome <- "mean"
zip <- FALSE
q <- 0.1
pfer <- 10
estimator <- "aipw"
n_cores <- 8


# Load (preprocessed) Medicare
setwd(paste("/n/home_fasse/rcadei/medicare/",statename,sep=''))
if (zip){
  load("medicare_zip.RData")
  medicare_zip <- medicare_zip[medicare_zip$log_dead!=-Inf,]
  X <- select(medicare_zip, -dead_in_5, -pm25)
  z <- ifelse((medicare_zip$pm25 <= t_pm25), 0, 1)
  if (outcome=="mean"){
    y <- medicare_zip$dead_in_5
  } else if (outcome=="log_mean"){
    y <- log(medicare_zip$dead_in_5)
  } else if (outcome=="logit_mean") {
    y <- log(medicare_zip$dead_in_5/(1-medicare_zip$dead_in_5))
  } else {
    stop("Unkown Outcome. Please select between 'mean', 'loag_mean' or 'logit_mean'.")
  }
} else {
  load("medicare.RData")
  X <- select(medicare, -dead_in_5, -pm25)
  z <- ifelse((medicare$pm25 <= t_pm25), 0, 1)
  y <- medicare$dead_in_5
  outcome <- "unit"
}

m_xgboost <- function(nthread = n_cores, ...) {
  SuperLearner::SL.xgboost(nthread = nthread, ...)
}
if (q>0) {
  ps_hat <- estimate_ps(z, X, "m_xgboost")
  lower_q <- quantile(ps_hat, q)
  upper_q <- quantile(ps_hat, 1-q)
  X <- X[which(ps_hat >= lower_q & ps_hat <= upper_q),]
  z <- z[which(ps_hat >= lower_q & ps_hat <= upper_q)]
  y <- y[which(ps_hat >= lower_q & ps_hat <= upper_q)]
}


intervention_vars <- c('male', 'white', 'black', 'hispanic', 'other_race',
                       'old', 'medicaid', 'zc_household_income', 'zc_house_value',
                       'county_bmi', 'county_smoke', 'zc_poverty', 'zc_nodiploma',
                       'zc_density', 'zc_black','zc_hispanic','zc_owner_occupancy')

# Set Parameters
method_params = list(ratio_dis = 0.5,
                     ite_method_dis = estimator,
                     ps_method_dis = "m_xgboost",
                     ps_method_inf = "m_xgboost",
                     oreg_method_dis = "m_xgboost",
                     oreg_method_inf = "m_xgboost",
                     ite_method_inf = estimator)

hyper_params = list(intervention_vars = intervention_vars,
                    offset = NULL,
                    ntrees_rf = 100,
                    ntrees_gbm = 100,
                    node_size = 20,
                    max_nodes = 4,
                    max_depth = 2,
                    replace = FALSE,
                    t_decay = 0.5,
                    t_ext = 0.005,
                    t_corr = 0.5,
                    t_pvalue = 0.05,
                    stability_selection = TRUE,
                    pfer = pfer,
                    penalty_rl = 1)

time_start <- proc.time()
cre_result <- cre(y, z, X, method_params, hyper_params)
time_end <- proc.time()
print(paste("Time:",round((time_end - time_start)[[3]],2),"sec"))

summary(cre_result)

exp_name <- paste("CRE_pm25",t_pm25,outcome,estimator,"pfer",pfer,sep="_")
pdf(paste(exp_name,".pdf",sep=""), width = 6.5, height = 4)
plot(cre_result)
dev.off()

plot(cre_result)
