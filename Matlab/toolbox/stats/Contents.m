% Statistics Toolbox
% Version 5.0 (R14) 05-May-2004
%
% Distributions.
%  Parameter estimation.
%   betafit     - Beta parameter estimation.
%   binofit     - Binomial parameter estimation.
%   dfittool    - Distribution fitting tool.
%   evfit       - Extreme value parameter estimation.
%   expfit      - Exponential parameter estimation.
%   gamfit      - Gamma parameter estimation.
%   lognfit     - Lognormal parameter estimation.
%   mle         - Maximum likelihood estimation (MLE).
%   mlecov      - Asymptotic covariance matrix of MLE.
%   nbinfit     - Negative binomial parameter estimation.
%   normfit     - Normal parameter estimation.
%   poissfit    - Poisson parameter estimation.
%   raylfit     - Rayleigh parameter estimation.
%   unifit      - Uniform parameter estimation.
%   wblfit      - Weibull parameter estimation.
%
%  Probability density functions (pdf).
%   betapdf     - Beta density.
%   binopdf     - Binomial density.
%   chi2pdf     - Chi square density.
%   evpdf       - Extreme value density.
%   exppdf      - Exponential density.
%   fpdf        - F density.
%   gampdf      - Gamma density.
%   geopdf      - Geometric density.
%   hygepdf     - Hypergeometric density.
%   lognpdf     - Lognormal density.
%   mvnpdf      - Multivariate normal density.
%   nbinpdf     - Negative binomial density.
%   ncfpdf      - Noncentral F density.
%   nctpdf      - Noncentral t density.
%   ncx2pdf     - Noncentral Chi-square density.
%   normpdf     - Normal (Gaussian) density.
%   pdf         - Density function for a specified distribution.
%   poisspdf    - Poisson density.
%   raylpdf     - Rayleigh density.
%   tpdf        - T density.
%   unidpdf     - Discrete uniform density.
%   unifpdf     - Uniform density.
%   wblpdf      - Weibull density.
%
%  Cumulative Distribution functions (cdf).
%   betacdf     - Beta cdf.
%   binocdf     - Binomial cdf.
%   cdf         - Specified cumulative distribution function.
%   chi2cdf     - Chi square cdf.
%   ecdf        - Empirical cdf (Kaplan-Meier estimate).
%   evcdf       - Extreme value cumulative distribution function.
%   expcdf      - Exponential cdf.
%   fcdf        - F cdf.
%   gamcdf      - Gamma cdf.
%   geocdf      - Geometric cdf.
%   hygecdf     - Hypergeometric cdf.
%   logncdf     - Lognormal cdf.
%   nbincdf     - Negative binomial cdf.
%   ncfcdf      - Noncentral F cdf.
%   nctcdf      - Noncentral t cdf.
%   ncx2cdf     - Noncentral Chi-square cdf.
%   normcdf     - Normal (Gaussian) cdf.
%   poisscdf    - Poisson cdf.
%   raylcdf     - Rayleigh cdf.
%   tcdf        - T cdf.
%   unidcdf     - Discrete uniform cdf.
%   unifcdf     - Uniform cdf.
%   wblcdf      - Weibull cdf.
%
%  Critical Values of Distribution functions.
%   betainv     - Beta inverse cumulative distribution function.
%   binoinv     - Binomial inverse cumulative distribution function.
%   chi2inv     - Chi square inverse cumulative distribution function.
%   evinv       - Extreme value inverse cumulative distribution function.
%   expinv      - Exponential inverse cumulative distribution function.
%   finv        - F inverse cumulative distribution function.
%   gaminv      - Gamma inverse cumulative distribution function.
%   geoinv      - Geometric inverse cumulative distribution function.
%   hygeinv     - Hypergeometric inverse cumulative distribution function.
%   icdf        - Specified inverse cdf.
%   logninv     - Lognormal inverse cumulative distribution function.
%   nbininv     - Negative binomial inverse distribution function.
%   ncfinv      - Noncentral F inverse cumulative distribution function.
%   nctinv      - Noncentral t inverse cumulative distribution function.
%   ncx2inv     - Noncentral Chi-square inverse distribution function.
%   norminv     - Normal (Gaussian) inverse cumulative distribution function.
%   poissinv    - Poisson inverse cumulative distribution function.
%   raylinv     - Rayleigh inverse cumulative distribution function.
%   tinv        - T inverse cumulative distribution function.
%   unidinv     - Discrete uniform inverse cumulative distribution function.
%   unifinv     - Uniform inverse cumulative distribution function.
%   wblinv      - Weibull inverse cumulative distribution function.
%
%  Random Number Generators.
%   betarnd     - Beta random numbers.
%   binornd     - Binomial random numbers.
%   chi2rnd     - Chi square random numbers.
%   evrnd       - Extreme value random numbers.
%   exprnd      - Exponential random numbers.
%   frnd        - F random numbers.
%   gamrnd      - Gamma random numbers.
%   geornd      - Geometric random numbers.
%   hygernd     - Hypergeometric random numbers.
%   iwishrnd    - Inverse Wishart random matrix.
%   lognrnd     - Lognormal random numbers.
%   mvnrnd      - Multivariate normal random numbers.
%   mvtrnd      - Multivariate t random numbers.
%   nbinrnd     - Negative binomial random numbers.
%   ncfrnd      - Noncentral F random numbers.
%   nctrnd      - Noncentral t random numbers.
%   ncx2rnd     - Noncentral Chi-square random numbers.
%   normrnd     - Normal (Gaussian) random numbers.
%   poissrnd    - Poisson random numbers.
%   randg       - Gamma random numbers (unit scale).
%   random      - Random numbers from specified distribution.
%   randsample  - Random sample from finite population.
%   raylrnd     - Rayleigh random numbers.
%   trnd        - T random numbers.
%   unidrnd     - Discrete uniform random numbers.
%   unifrnd     - Uniform random numbers.
%   wblrnd      - Weibull random numbers.
%   wishrnd     - Wishart random matrix.
%
%  Statistics.
%   betastat    - Beta mean and variance.
%   binostat    - Binomial mean and variance.
%   chi2stat    - Chi square mean and variance.
%   evstat      - Extreme value mean and variance.
%   expstat     - Exponential mean and variance.
%   fstat       - F mean and variance.
%   gamstat     - Gamma mean and variance.
%   geostat     - Geometric mean and variance.
%   hygestat    - Hypergeometric mean and variance.
%   lognstat    - Lognormal mean and variance.
%   nbinstat    - Negative binomial mean and variance.
%   ncfstat     - Noncentral F mean and variance.
%   nctstat     - Noncentral t mean and variance.
%   ncx2stat    - Noncentral Chi-square mean and variance.
%   normstat    - Normal (Gaussian) mean and variance.
%   poisstat    - Poisson mean and variance.
%   raylstat    - Rayleigh mean and variance.
%   tstat       - T mean and variance.
%   unidstat    - Discrete uniform mean and variance.
%   unifstat    - Uniform mean and variance.
%   wblstat     - Weibull mean and variance.
%
%  Likelihood functions.
%   betalike    - Negative beta log-likelihood.
%   evlike      - Negative extreme value log-likelihood.
%   explike     - Negative exponential log-likelihood.
%   gamlike     - Negative gamma log-likelihood.
%   lognlike    - Negative lognormal log-likelihood.
%   nbinlike    - Negative likelihood for negative binomial distribution.
%   normlike    - Negative normal likelihood.
%   wbllike     - Negative Weibull log-likelihood.
%
% Descriptive Statistics.
%   bootstrp    - Bootstrap statistics for any function.
%   corr        - Linear or rank correlation coefficient.
%   corrcoef    - Linear correlation coefficient with confidence intervals.
%   cov         - Covariance.
%   crosstab    - Cross tabulation.
%   geomean     - Geometric mean.
%   grpstats    - Summary statistics by group.
%   harmmean    - Harmonic mean.
%   iqr         - Interquartile range.
%   kurtosis    - Kurtosis.
%   mad         - Median Absolute Deviation.
%   mean        - Sample average (in MATLAB toolbox).
%   median      - 50th percentile of a sample.
%   moment      - Moments of a sample.
%   nanmax      - Maximum ignoring NaNs.
%   nanmean     - Mean ignoring NaNs.
%   nanmedian   - Median ignoring NaNs.
%   nanmin      - Minimum ignoring NaNs.
%   nanstd      - Standard deviation ignoring NaNs.
%   nansum      - Sum ignoring NaNs.
%   nanvar      - Variance ignoring NaNs.
%   prctile     - Percentiles.
%   quantile    - Quantiles.
%   range       - Range.
%   skewness    - Skewness.
%   std         - Standard deviation (in MATLAB toolbox).
%   tabulate    - Frequency table.
%   trimmean    - Trimmed mean.
%   var         - Variance (in MATLAB toolbox).
%
% Linear Models.
%   addedvarplot - Created added-variable plot for stepwise regression.
%   anova1      - One-way analysis of variance.
%   anova2      - Two-way analysis of variance.
%   anovan      - n-way analysis of variance.
%   aoctool     - Interactive tool for analysis of covariance.
%   dummyvar    - Dummy-variable coding.
%   friedman    - Friedman's test (nonparametric two-way anova).
%   glmfit      - Generalized linear model fitting.
%   glmval      - Evaluate fitted values for generalized linear model.
%   kruskalwallis - Kruskal-Wallis test (nonparametric one-way anova).
%   leverage    - Regression diagnostic.
%   lscov       - Least-squares estimates with known covariance matrix.
%   lsqnonneg   - Non-negative least-squares.
%   manova1     - One-way multivariate analysis of variance.
%   manovacluster - Draw clusters of group means for manova1.
%   multcompare - Multiple comparisons of means and other estimates.
%   polyconf    - Polynomial evaluation and confidence interval estimation.
%   polyfit     - Least-squares polynomial fitting.
%   polyval     - Predicted values for polynomial functions.
%   rcoplot     - Residuals case order plot.
%   regress     - Multivariate linear regression.
%   regstats    - Regression diagnostics.
%   ridge       - Ridge regression.
%   robustfit   - Robust regression model fitting.
%   rstool      - Multidimensional response surface visualization (RSM).
%   stepwise    - Interactive tool for stepwise regression.
%   stepwisefit - Non-interactive stepwise regression.
%   x2fx        - Factor settings matrix (x) to design matrix (fx).
%
% Nonlinear Models.
%   nlinfit     - Nonlinear least-squares data fitting.
%   nlintool    - Interactive graphical tool for prediction in nonlinear models.
%   nlpredci    - Confidence intervals for prediction.
%   nlparci     - Confidence intervals for parameters.
%
% Design of Experiments (DOE).
%   bbdesign    - Box-Behnken design.
%   candexch    - D-optimal design (row exchange algorithm for candidate set).
%   candgen     - Candidates set for D-optimal design generation.
%   ccdesign    - Central composite design.
%   cordexch    - D-optimal design (coordinate exchange algorithm).
%   daugment    - Augment D-optimal design.
%   dcovary     - D-optimal design with fixed covariates.
%   ff2n        - Two-level full-factorial design.
%   fracfact    - Two-level fractional factorial design.
%   fullfact    - Mixed-level full-factorial design.
%   hadamard    - Hadamard matrices (orthogonal arrays).
%   lhsdesign   - Latin hypercube sampling design.
%   lhsnorm     - Latin hypercube multivariate normal sample.
%   rowexch     - D-optimal design (row exchange algorithm).
%
% Statistical Process Control (SPC).
%   capable     - Capability indices.
%   capaplot    - Capability plot.
%   ewmaplot    - Exponentially weighted moving average plot.
%   histfit     - Histogram with superimposed normal density.
%   normspec    - Plot normal density between specification limits.
%   schart      - S chart for monitoring variability.
%   xbarplot    - Xbar chart for monitoring the mean.
%
% Multivariate Statistics.
%  Cluster Analysis.
%   cophenet    - Cophenetic coefficient.
%   cluster     - Construct clusters from LINKAGE output.
%   clusterdata - Construct clusters from data.
%   dendrogram  - Generate dendrogram plot.
%   inconsistent - Inconsistent values of a cluster tree.
%   kmeans      - k-means clustering.
%   linkage     - Hierarchical cluster information.
%   pdist       - Pairwise distance between observations.
%   silhouette  - Silhouette plot of clustered data.
%   squareform  - Square matrix formatted distance.
%
%  Dimension Reduction Techniques.
%   factoran    - Factor analysis.
%   pcacov      - Principal components from covariance matrix.
%   pcares      - Residuals from principal components.
%   princomp    - Principal components analysis from raw data.
%   rotatefactors - Rotation of FA or PCA loadings.
%
%  Plotting.
%   andrewsplot - Andrews plot for multivariate data.
%   biplot      - Biplot of variable/factor coefficients and scores.
%   glyphplot   - Plot stars or Chernoff faces for multivariate data.
%   gplotmatrix - Matrix of scatter plots grouped by a common variable.
%   parallelcoords - Parallel coordinates plot for multivariate data.
%
%  Other Multivariate Methods.
%   barttest    - Bartlett's test for dimensionality.
%   canoncorr   - Cannonical correlation analysis.
%   cmdscale    - Classical multidimensional scaling.
%   classify    - Linear discriminant analysis.
%   mahal       - Mahalanobis distance.
%   manova1     - One-way multivariate analysis of variance.
%   mdscale     - Metric and non-metric multidimensional scaling.
%   procrustes  - Procrustes analysis.
%
% Decision Tree Techniques.
%   treedisp    - Display decision tree.
%   treefit     - Fit data using a classification or regression tree.
%   treeprune   - Prune decision tree or creating optimal pruning sequence.
%   treetest    - Estimate error for decision tree.
%   treeval     - Compute fitted values using decision tree.
%
% Hypothesis Tests.
%   ranksum     - Wilcoxon rank sum test (independent samples).
%   signrank    - Wilcoxon sign rank test (paired samples).
%   signtest    - Sign test (paired samples).
%   ztest       - Z test.
%   ttest       - One sample t test.
%   ttest2      - Two sample t test.
%
% Distribution Testing.
%   jbtest      - Jarque-Bera test of normality
%   kstest      - Kolmogorov-Smirnov test for one sample
%   kstest2     - Kolmogorov-Smirnov test for two samples
%   lillietest  - Lilliefors test of normality
%
% Nonparametric Functions.
%   friedman    - Friedman's test (nonparametric two-way anova).
%   kruskalwallis - Kruskal-Wallis test (nonparametric one-way anova).
%   ksdensity   - Kernel smoothing density estimation.
%   ranksum     - Wilcoxon rank sum test (independent samples).
%   signrank    - Wilcoxon sign rank test (paired samples).
%   signtest    - Sign test (paired samples).
%
% Hidden Markov Models.
%   hmmdecode   - Calculate HMM posterior state probabilities.
%   hmmestimate - Estimate HMM parameters given state information.
%   hmmgenerate - Generate random sequence for HMM.
%   hmmtrain    - Calculate maximum likelihood estimates for HMM parameters.
%   hmmviterbi  - Calculate most probable state path for HMM sequence.
%
% Statistical Plotting.
%   andrewsplot - Andrews plot for multivariate data.
%   biplot      - Biplot of variable/factor coefficients and scores.
%   boxplot     - Boxplots of a data matrix (one per column).
%   cdfplot     - Plot of empirical cumulative distribution function.
%   ecdfhist    - Histogram calculated from empirical cdf.
%   fsurfht     - Interactive contour plot of a function.
%   gline       - Point, drag and click line drawing on figures.
%   glyphplot   - Plot stars or Chernoff faces for multivariate data.
%   gname       - Interactive point labeling in x-y plots.
%   gplotmatrix - Matrix of scatter plots grouped by a common variable.
%   gscatter    - Scatter plot of two variables grouped by a third.
%   hist        - Histogram (in MATLAB toolbox).
%   hist3       - Three-dimensional histogram of bivariate data.
%   lsline      - Add least-square fit line to scatter plot.
%   normplot    - Normal probability plot.
%   parallelcoords - Parallel coordinates plot for multivariate data.
%   probplot    - Probability plot.
%   qqplot      - Quantile-Quantile plot.
%   refcurve    - Reference polynomial curve.
%   refline     - Reference line.
%   surfht      - Interactive contour plot of a data grid.
%   wblplot     - Weibull probability plot.
%
% Statistics Demos.
%   aoctool     - Interactive tool for analysis of covariance.
%   disttool    - GUI tool for exploring probability distribution functions.
%   polytool    - Interactive graph for prediction of fitted polynomials.
%   randtool    - GUI tool for generating random numbers.
%   rsmdemo     - Reaction simulation (DOE, RSM, nonlinear curve fitting).
%   robustdemo  - Interactive tool to compare robust and least squares fits.
%
% File Based I/O.
%   tblread     - Read in data in tabular format.
%   tblwrite    - Write out data in tabular format to file.
%   tdfread     - Read in text and numeric data from tab-delimitted file.
%   caseread    - Read in case names.
%   casewrite   - Write out case names to file.
%
% Utility Functions.
%   combnk      - Enumeration of all combinations of n objects k at a time.
%   grp2idx     - Convert grouping variable to indices and array of names.
%   hougen      - Prediction function for Hougen model (nonlinear example).
%   statget     - Get STATS options parameter value.
%   statset     - Set STATS options parameter value.
%   tiedrank    - Compute ranks of sample, adjusting for ties.
%   zscore      - Normalize matrix columns to mean 0, variance 1.

% Other Utility Functions.
%   betalik1    - Computation function for negative beta log-likelihood.
%   boxutil     - Utility function for boxplot.
%   cdfcalc     - Computation function for empirical cdf.
%   dfgetset    - Getting and setting dfittool parameters.
%   dfswitchyard - Invoking private functions for dfittool.
%   distchck    - Argument checking for cdf, pdf and inverse functions.
%   export2wsdlg - Dialog to export data from gui to workspace.
%   iscatter    - Grouped scatter plot using integer grouping.
%   meansgraph  - Interactive means graph for multiple comparisons.
%   statdisptable - Display table of statistics.
%
% HTML Demo Functions.
%   classdemo   - Classification demo.
%   clusterdemo - Cluster analysis demo.
%   cmdscaledemo - Classical multidimensional scaling demo.
%   copulademo  - Copula simulation demo.
%   customdist1demo - Custom distribution fitting demo.
%   customdist2demo - Custom distribution fitting demo.
%   factorandemo - Factor analysis demo.
%   glmdemo     - Generalized linear model demo.
%   gparetodemo - Generalized Pareto fitting demo.
%   mdscaledemo - Non-classical multidimensional scaling demo.
%   mvplotdemo  - Multidimensional data plotting demo.
%   samplesizedemo - Sample size calculation demo.
%   survivaldemo - Survival data analysis demo.
%
% Obsolete Functions
%   weibcdf     - Weibull cdf, old parameter definitions.
%   weibfit     - Weibull fitting, old parameter definitions.
%   weibinv     - Weibull inv cdf, old parameter definitions.
%   weiblike    - Weibull likelihood, old parameter definitions.
%   weibpdf     - Weibull pdf, old parameter definitions.
%   weibplot    - Weibull prob plot, old parameter definitions.
%   weibrnd     - Weibull random numbers, old parameter definitions.
%   weibstat    - Weibull statistics, old parameter definitions.

% Copyright 1993-2004 The MathWorks, Inc.
% Generated from Contents.m_template revision 2.44.4.7  $Date: 2004/03/22 23:54:54 $
