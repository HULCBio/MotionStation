function [settings, X] = dcovary(nfactors,covs,model,varargin)
%DCOVARY D-Optimal design with fixed covariates.
%   [SETTINGS, X] = DCOVARY(NFACTORS,COVARIATES,MODEL) uses a coordinate
%   exchange algorithm to generate a D-optimal design for NFACTORS factors,
%   subject to the constraint that it also include the fixed covariate
%   values in the input matrix COVARIATES.  The number of runs in the design
%   is taken to be the number of rows in the COVARIATES matrix.  The output
%   matrix SETTINGS is the matrix of factor settings for the design,
%   including the fixed covariates.  X is the matrix of term values (often
%   called the design matrix).  MODEL is an optional argument that controls
%   the order of the regression model.  MODEL can be any of the following
%   strings:
%
%     'linear'        constant and linear terms (the default)
%     'interaction'   includes constant, linear, and cross product terms.
%     'quadratic'     interactions plus squared terms.
%     'purequadratic' includes constant, linear and squared terms.
%
%   Alternatively MODEL can be a matrix of term definitions as
%   accepted by the X2FX function.  The model is applied to the fixed
%   covariates as well as the regular factors.  If you want to treat
%   the fixed covariates specially, for example by including linear
%   terms for them but quadratic terms for the regular factors, you can
%   do this by creating the proper MODEL matrix.
%
%   [SETTINGS, X] = DCOVARY(...,'PARAM1',VALUE1,'PARAM2',VALUE2,...)
%   provides more control over the design generation through a set of
%   parameter/value pairs.  Valid parameters are the following:
%
%      Parameter    Value
%      'display'    Either 'on' or 'off' to control display of
%                   iteration counter (default = 'on').
%      'init'       Initial design as an NRUNS-by-NFACTORS matrix
%                   (default is a randomly selected set of points).
%      'maxiter'    Maximum number of iterations (default = 10).
%
%   The DCOVARY function creates a starting design that includes the
%   fixed covariate values, and then iterates by changing the non-fixed
%   cordinates of each design point in an attempt to reduce the variance
%   of the coefficients that would be estimated using this design.
%
%   Example:  Generate a design for three factors in 2 blocks of 4 runs.
%      blk = [-1 -1 -1 -1  1 1 1 1]';
%      dsgn = dcovary(3,blk);
%
%   See also CORDEXCH, DAUGMENT, ROWEXCH, X2FX.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.9.2.1 $  $Date: 2004/01/24 09:33:18 $

[nruns,ncov] = size(covs);
if nargin<3, model='linear'; end
[settings,X] = cordexch(nfactors,nruns,model,'covariates',covs,varargin{:});
