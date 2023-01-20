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
Evaluate the ITE estimation performances (i.e. Root Mean Squared Error and Bias) of Causal Rule Ensemble using different internal ITE estimators (i.e. S-Learner, T-Learner, X-Learner, Augmented Inverse Propability Weighting, Causal Forest, Bayesian Causal Forest and Bayesian Regression Tree), the corresponding ITE estimators alone, and (Honest) Causal Tree. For the experiments on Causal Rule Ensemble retriving the correct decision rules also compute the corresponding (normalized) biases of their coefficients in the linear CATE decmposition. 
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

## Experiments

### MEDICARE: Air Pollution Exposure -> Mortality

Individual Level Analysis



