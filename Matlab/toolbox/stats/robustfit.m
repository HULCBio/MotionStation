function varargout = robustfit(X,y,wfun,tune,const)
%ROBUSTFIT Robust linear regression
%   B = ROBUSTFIT(X,Y) returns the vector B of regression
%   coefficients, obtained by performing robust regression to estimate
%   the linear model Y = Xb, (X is an nxp matrix, Y is the nx1 vector
%   of observations).  The algorithm uses iteratively reweighted
%   least squares with the bisquare weighting function.
%
%   B = ROBUSTFIT(X,Y,'WFUN',TUNE,'CONST') uses the weighting function
%   'WFUN' and tuning constant TUNE.  'WFUN' can be any of
%       'andrews' 'bisquare', 'cauchy', 'fair', 'huber',
%       'logistic', 'talwar', 'welsch'
%   Alternatively 'WFUN' can be a function that takes a residual
%   vector as input and produces a weight vector as output.  The
%   residuals are scaled by the tuning constant and by an estimate of
%   the error standard deviation before the weight function is called.
%   'WFUN' can be specified using @ (as in @myfun) or as an inline
%   function.  TUNE is a tuning constant that is divided into the
%   residual vector before computing the weights, and it is required
%   if 'WFUN' is specified as a function.  'CONST' is 'on' (the
%   default) to include a constant term or 'off' to omit it.  The
%   coefficient of the constant term is the first element of B.  (Do
%   not enter a column of ones directly into the X matrix.)
%
%   [B,STATS] = ROBUSTFIT(...) also returns a STATS structure
%   containing the following fields:
%       stats.ols_s     sigma estimate (rmse) from least squares fit
%       stats.robust_s  robust estimate of sigma
%       stats.mad_s     MAD estimate of sigma; used for scaling
%                       residuals during the iterative fitting
%       stats.s         final estimate of sigma, the larger of robust_s
%                       and a weighted average of ols_s and robust_s
%       stats.se        standard error of coefficient estimates
%       stats.t         ratio of b to stats.se
%       stats.p         p-values for stats.t
%       stats.coeffcorr estimated correlation of coefficient estimates
%       stats.w         vector of weights for robust fit
%       stats.h         vector of leverage values for least squares fit
%       stats.dfe       degrees of freedom for error
%       stats.R         R factor in QR decomposition of X matrix
%   The ROBUSTFIT function estimates the variance-covariance matrix of
%   the coefficient estimates as V=inv(X'*X)*STATS.S^2.  The standard
%   errors and correlations are derived from V.

% References:
%   DuMouchel, W.H., and F.L. O'Brien (1989), "Integrating a robust
%     option into a multiple regression computing environment,"
%     Computer Science and Statistics:  Proceedings of the 21st
%     Symposium on the Interface, American Statistical Association.
%   Holland, P.W., and R.E. Welsch (1977), "Robust regression using
%     iteratively reweighted least-squares," Communications in
%     Statistics - Theory and Methods, v. A6, pp. 813-827.
%   Huber, P.J. (1981), Robust Statistics, New York: Wiley.
%   Street, J.O., R.J. Carroll, and D. Ruppert (1988), "A note on
%     computing robust regression estimates via iteratively
%     reweighted least squares," The American Statistician, v. 42,
%     pp. 152-154.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2003/10/21 12:28:10 $

if  nargin < 2      
    error('stats:robustfit:TooFewInputs',...
          'ROBUSTFIT requires at least two input arguments.');      
end 

if (nargin<3 || isempty(wfun)), wfun = 'bisquare'; end
if (nargin<4 | isempty(tune))
   switch(wfun)
    case 'andrews',  tune = 1.339;
    case 'bisquare', tune = 4.685;
    case 'cauchy',   tune = 2.385;
    case 'fair',     tune = 1.400;
    case 'huber',    tune = 1.345;
    case 'logistic', tune = 1.205;
    case 'ols',      tune = 1;
    case 'talwar',   tune = 2.795;
    case 'welsch',   tune = 2.985;
    otherwise, error('stats:robustfit:TooFewInputs',...
                     'Missing tuning constant for %s function.',wfun);
   end
elseif (tune<=0)
   error('stats:robustfit:BadTuningConstant',...
         'Tuning constant must be positive.');
end
if (nargin<5), const='on'; end
switch(const)
 case {'on' 1},  doconst = 1;
 case {'off' 0}, doconst = 0;
 otherwise,  error('stats:robustfit:BadConst',...
                   'CONST must be ''on'' or ''off''.');
end

% Remove missing values and check dimensions
[anybad wasnan y X] = statremovenan(y,X);
if (anybad==2)
   error('stats:robustfit:InputSizeMismatch',...
         'Lengths of X and Y must match.');
end

varargout=cell(1,max(1,nargout));
[varargout{:}] = statrobustfit(X,y,wfun,tune,wasnan,doconst);
