setwd("~/nsaph_projects/rcadei/medicare/")
library(ggplot2)
library(gridExtra)
library(tools)

plot <- function(object, region) {
  
  `%>%` <- magrittr::`%>%`
  
  Rule <- Estimate <- CI_lower <- CI_upper <- NULL
  
  gg_labs <- gg_title <- NULL
  
  cate <- object[["CATE"]]
  ate <- cate[1, ]
  aate <- cate[2:nrow(cate), ]
  aate <- aate[order(aate$Estimate, decreasing = TRUE), ]
  rownames(aate) <- 1:nrow(aate)
  
  g <- ggplot2::ggplot(data = aate) +
    ggplot2::geom_hline(yintercept = 0, color = "dark grey", lty = 2) +
    ggplot2::geom_linerange(ggplot2::aes(x = reorder(Rule, Estimate),
                                         ymin = CI_lower,
                                         ymax = CI_upper),
                            lwd = 1,
                            position = ggplot2::position_dodge(width = 1 / 2)) +
    ggplot2::geom_pointrange(ggplot2::aes(x = reorder(Rule, Estimate),
                                          y = Estimate,
                                          ymin = CI_lower,
                                          ymax = CI_upper),
                             lwd = 1 / 2,
                             position = ggplot2::position_dodge(width = 1 / 2),
                             shape = 21, 
                             size = 0.2,
                             fill = "WHITE") +
    ggplot2::xlab("") +
    ggplot2::ylab("AATE") +
    ggplot2::coord_flip(ylim = c(-0.12, 0.12)) +
    ggplot2::theme_bw() +
    ggplot2::ggtitle(paste(toTitleCase(region),
                           "\n\nATE = ", round(ate[["Estimate"]], 3),
                           " [", round(ate[["CI_lower"]], 3), ",",
                           round(ate[["CI_upper"]], 3), "]", sep = "")) +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))
  
  return(g)
}

regions <- c("midwest","northeast","west","south")
cutoff <- 0.8
binary <- TRUE
t_pm25 <- 12
q <- 0
estimator <- "xlearner"
B <- 100
subsample <- 0.1

plots <- list()
for (i in 1:4) {
  setwd(paste("~/nsaph_projects/rcadei/medicare/",regions[i],sep=''))
  exp_name <- paste("CRE_pm25",t_pm25,
                    "q",q,
                    estimator,
                    "bin",binary,
                    "cutoff",cutoff,
                    "B",B,
                    "subsample",subsample,
                    sep="_")
  load(paste(exp_name, ".RData", sep=""))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_white<=0.5", "low % white", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_white>0.5", "high % white", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_black<=0.5", "low % black", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_black>0.5", "high % black", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_hispanic<=0.5", "low % hispanic", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_hispanic>0.5", "high % hispanic", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_poverty<=0.5", "not poor area", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_poverty>0.5", "poor area", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_density<=0.5", "low pop. density", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_density>0.5", "high pop. density", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_nodiploma<=0.5", "low % w/o diploma", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_nodiploma>0.5", "high % w/o diploma", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_household_income<=0.5", "low income", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_household_income>0.5", "high income", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_house_value<=0.5", "cheap house", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("zc_house_value>0.5", "expensive house", x)))
  
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("other_race>0.5", "other race", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("white<=0.5", "not white", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("white>0.5", "white", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("black<=0.5", "not black", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("black>0.5", "black", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("old<=0.5", "not old", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("old>0.5", "old", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("medicaid<=0.5", "medicaid=0", x)))
  
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("low % black & high % hispanic", "            low % black & high % hispanic", x)))
  cre_result$CATE$Rule <- unlist(lapply(cre_result$CATE$Rule, function(x) gsub("expensive house & low pop. density", "   expensive house & low pop. density", x)))
  
  plots[[i]] <- plot(cre_result, regions[i])
}
pdf("~/nsaph_projects/rcadei/medicare/results_census.pdf", width = 10, height = 6)
grid.arrange(grobs = plots, ncol = 2, nrow = 2)
dev.off()

