# Causal Rule Ensemble: Applications
Collection of simulations and real world experiments on Interpretable Inference of Heterogeneous Treatment Effects by [Causal Rule Ensemble](https://nsaph-software.github.io/CRE/).

## Installation
Installing from CRAN.
```r
install.packages("CRE")
```

Installing the latest developing version. 
```r
library(devtools)
install_github("NSAPH-Software/CRE", ref="develop")
```

## Simulations

### Discovery
Evaluate the decision rules discovery performances (i.e. Recall, Precision, Jaccard Index) of Causal Rule Ensemble using different ITE estimators (i.e. S-Learner, T-Learner, X-Learner, Augmented Inverse Propability Weighting, Causal Forest, Bayesian Causal Forest and Bayesian Regression Tree) and (Honest) Causal Tree, varying the magnitude of the Causal Effect in [0,4].
```r
"CRE_applications/simulations/discovery.R"
```

Different experiment setting varying the dataset are considered:
- `main`: main experiment (2 rules, 2000 individuals, linear confounding),
- `small_sample`: small sample (2 rules, 1000 individuals, linear confounding),
- `big_sample`: big sample (2 rules, 5000 individuals, linear confounding),
- `more_rules`: more rules (4 rules, 2000 individuals, linear confounding),
- `rct`: randomized controlled trial (2 rules, 2000 individuals, no confounding),
- `nonlin_conf`: non linear confounding (2 rules, 2000 individuals, non linear confounding).

Customize your own experiment filling the parameters in `personalize` experiment option.

### Estimation
Evaluate the ITE estimation performances (i.e. Root Mean Squared Error and Bias) of Causal Rule Ensemble using different internal ITE estimators (i.e. S-Learner, T-Learner, X-Learner, Augmented Inverse Propability Weighting, Causal Forest, Bayesian Causal Forest and Bayesian Regression Tree), the corresponding ITE estimators alone [1], and (Honest) Causal Tree. For the experiments on Causal Rule Ensemble retriving the correct decision rules also compute the corresponding (normalized) biases of their coefficients in the linear CATE decmposition. 
```r
"CRE_applications/simulations/estimation.R"
```

Different experiment setting varying the dataset are considered:
- `main`: main experiment (2 rules, 2000 individuals, linear confounding),
- `small_sample`: small sample (2 rules, 1000 individuals, linear confounding),
- `big_sample`: big sample (2 rules, 5000 individuals, linear confounding),
- `more_rules`: more rules (4 rules, 2000 individuals, linear confounding),
- `rct`: randomized controlled trial (2 rules, 2000 individuals, no confounding),
- `nonlin_conf`: non linear confounding (2 rules, 2000 individuals, non linear confounding).

Customize your own experiment filling the parameters in `personalize` experiment option.

[1] Run using the internal CRE function `estimate_ite()`. To reproduce the same analysis, either download the [CRE GitHub repository](https://github.com/NSAPH-Software/CRE) in local, or replace `estimate_ite()` with the corresponding function of your favorite library for ITE estimation, or discard this comparison (commenting [this piece of code](https://github.com/riccardocadei/CRE_applications/blob/b4e53c9cc3e3552f7c40af3bbb9d4a607812c22d/simulations/estimation.R#L167)).

## Experiments

### MEDICARE: Air Pollution Exposure -> Mortality

Individual-level analysis of the heterogeneity in the exposure to PM2.5 effect on mortality using Medicare. 
All data needed to evaluate the conclusions in the paper are present in the paper and/or the Supplementary Materials. Medicare patient individual-level data are stored at a Level-3 secured data platform on Research Computing Environment, supported by the Institute for Quantitative Social Science in the Faculty of Arts and Sciences at Harvard University. Those interested in the original data can contact the corresponding author.
```r
"CRE_applications/experiments/medicare.R"
```



