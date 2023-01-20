library("dplyr")
library("CRE")
set.seed(2022)

statename <- "united_states"
t_pm25 <- 10
outcome <- "mean"
zip <- FALSE
q <- 0

# Load (preprocessed) Medicare
setwd(paste("/n/home_fasse/rcadei/medicare/",statename,sep=''))
load("medicare.RData")
X <- select(medicare, -dead_in_5, -pm25, -followup_year_plus_one, -pm25_12)
z <- ifelse((medicare$pm25 <= t_pm25), 0, 1)
y <- medicare$dead_in_5
outcome <- "unit"

if (q>0) {
  ps_hat <- estimate_ps(z, X, "SL.xgboost")
  lower_q <- quantile(ps_hat, q)
  upper_q <- quantile(ps_hat, 1-q)
  X <- X[which(ps_hat >= lower_q & ps_hat <= upper_q),]
  z <- z[which(ps_hat >= lower_q & ps_hat <= upper_q)]
  y <- y[which(ps_hat >= lower_q & ps_hat <= upper_q)]
}

intervention_vars <- c('male', 'white', 'black', 'hispanic', 'other_race',
                       'age', 'dual', 'medhouseholdincome', 'medianhousevalue',
                       'mean_bmi', 'smoke_rate', 'poverty', 'education',
                       'popdensity', 'pct_blk','pct_owner_occ')

# Set Parameters
method_params = list(ratio_dis = 0.5,
                     ite_method_dis = "slearner",
                     ps_method_dis = "SL.xgboost",
                     ps_method_inf = "SL.xgboost",
                     oreg_method_dis = "SL.xgboost",
                     oreg_method_inf = "SL.xgboost",
                     ite_method_inf = "slearner")

hyper_params = list(intervention_vars = intervention_vars,
                    offset = NULL,
                    ntrees_rf = 40,
                    ntrees_gbm = 40,
                    node_size = 20,
                    max_nodes = 4,
                    max_depth = 2,
                    replace = TRUE,
                    t_decay = 0.01,
                    t_ext = 0.005,
                    t_corr = 0.5,
                    t_pvalue = 0.05,
                    stability_selection = TRUE,
                    cutoff = 0.8,
                    pfer = 100,
                    penalty_rl = 1)

time_start <- proc.time()
cre_result <- cre(y, z, X, method_params, hyper_params)
time_end <- proc.time()
print(paste("Time:",round((time_end - time_start)[[3]],2),"sec"))

summary(cre_result)

exp_name <- paste("CRE_pm25",t_pm25,outcome,"q",q,sep="_")
pdf(paste(exp_name,".pdf",sep=""), width = 6.5, height = 4)
plot(cre_result)
dev.off()

plot(cre_result)
