library(devtools)
library(dplyr)
library(SuperLearner)
library(CRE)
set.seed(2023)

# Set Experiment Parameter
regions <- c("northeast","south","midwest","west")
region <- regions[4]

binary <- TRUE
t_pm25 <- 12
q <- 0
#pfer <- 1.5
B <- 100
subsample <- 0.1
cutoff <- 0.8
estimator <- "xlearner"
xgboost <- function(nthread = 40, ...) {
  SuperLearner::SL.xgboost(nthread = nthread, ...)
}

# Load (preprocessed) Medicare
setwd(paste("~/nsaph_projects/rcadei/medicare/",region,sep=''))

ite_file <- paste("ite_",estimator,"_",t_pm25,".RData",sep="")
if (!file.exists(ite_file)) {
  load("medicare.RData")
  X <- select(medicare, -dead_in_5, -pm25)
  z <- ifelse((medicare$pm25 <= t_pm25), 0, 1)
  y <- medicare$dead_in_5
  ite <- estimate_ite(y, z, X, estimator,
                      oreg_method = "xgboost",
                      ps_method = "xgboost")
  save(ite, file = ite_file)
} else {
  load(ite_file)
}

if (binary) {
  load("medicare_bin.RData")
  X <- select(medicare, -dead_in_5, -pm25)
  z <- ifelse((medicare$pm25 <= t_pm25), 0, 1)
  y <- medicare$dead_in_5
} else {
  load("medicare.RData")
  X <- select(medicare, -dead_in_5, -pm25)
  z <- ifelse((medicare$pm25 <= t_pm25), 0, 1)
  y <- medicare$dead_in_5
}


if (q>0) {
  ps_file <- "ps.RData"
  if (!file.exists(ps_file)) {
    ps <- estimate_ps(z, X, "xgboost")
    save(ps, file = ps_file)
  } else {
    load(ps_file)
  }
  lower_q <- quantile(ps, q)
  upper_q <- quantile(ps, 1-q)
  X <- X[which(ps >= lower_q & ps <= upper_q),]
  z <- z[which(ps >= lower_q & ps <= upper_q)]
  y <- y[which(ps >= lower_q & ps <= upper_q)]
  ite <- ite[which(ps >= lower_q & ps <= upper_q)]
}

intervention_vars <- c('male', 'white', 'black', 'hispanic', 'other_race',
                       'age', 'medicaid', 'zc_household_income', 'zc_house_value',
                       'zc_poverty', 'zc_nodiploma', 'zc_density', 
                       'zc_black', 'zc_hispanic')
removed <- c('zc_owner_occupancy')
if (binary) intervention_vars[intervention_vars=="age"] <- "old"

# Set Parameters
method_params = list(ratio_dis = 0.5,
                     ite_method = estimator,
                     learner_ps = "xgboost",
                     learner_y = "xgboost")

hyper_params = list(intervention_vars = intervention_vars,
                    #offset = NULL,
                    ntrees = 50,
                    node_size = 20,
                    max_rules = 50,
                    max_depth = 2,
                    t_decay = 0.002,
                    t_ext = 0.005,
                    t_corr = 1,
                    stability_selection = "vanilla",
                    #pfer = pfer,
                    cutoff = cutoff,
                    B = B,
                    subsample = subsample)

time_start <- proc.time()
cre_result <- cre(y, z, X, method_params, hyper_params, ite)
time_end <- proc.time()
print(paste("Time:",round((time_end - time_start)[[3]],2),"sec"))

summary(cre_result)

exp_name <- paste("CRE_pm25",t_pm25,
                  "q",q,
                  estimator,
                  "bin",binary,
                  "cutoff",cutoff,
                  "B",B,
                  "subsample",subsample,
                  sep="_")

pdf(paste(exp_name,".pdf",sep=""), width = 6.5, height = 4)
plot(cre_result)
dev.off()

plot(cre_result)
save(cre_result, file=paste(exp_name,".RData",sep=""))
