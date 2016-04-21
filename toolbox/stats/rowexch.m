function [settings, X] = rowexch(nfactors,nruns,model,varargin)
%ROWEXCH D-Optimal design of experiments (row exchange algorithm).
%   [SETTINGS, X] = ROWEXCH(NFACTORS,NRUNS,MODEL) generates a D-optimal
%   design having NRUNS runs for NFACTORS factors.  SETTINGS is the
%   matrix of factor settings for the design, and X is the matrix of
%   term values (often called the design matrix).  MODEL is an optional
%   argument that controls the order of the regression model.  By default,
%   ROWEXCH returns the design matrix for a linear additive model with a
%   constant term.  MODEL can be any of the following strings:
%
%     'linear'        constant and linear terms (the default)
%     'interaction'   includes constant, linear, and cross product terms
%     'quadratic'     interactions plus squared terms
%     'purequadratic' includes constant, linear and squared terms
%
%   Alternatively MODEL can be a matrix of term definitions as
%   accepted by the X2FX function.
%
%   [SETTINGS, X] = ROWEXCH(...,'PARAM1',VALUE1,'PARAM2',VALUE2,...)
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
%   The ROWEXCH function searches for a D-optimal design using a row-
%   exchange algorithm.  It first generates a candidate set of points that
%   are eligible to be included in the design, and then iteratively
%   exchanges design points for candidate points in an attempt to reduce the
%   variance of the coefficients that would be estimated using this design.
%   If you need to use a candidate set that differs from the default one,
%   you can call the CANDGEN and CANDEXCH functions in place of ROWEXCH.
%
%   See also CORDEXCH, CANDGEN, CANDEXCH, X2FX.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.2.1 $  $Date: 2003/11/01 04:29:03 $

% Get default values for optional arguments
if nargin < 3
  model = 'linear';
end

% We care about the init parameter, but not the others
[eid,emsg,settings,restargs] = statgetargs({'init'}, {[]}, varargin{:});
if ~isempty(emsg)
   error(sprintf('stats:rowexch:%s',eid),emsg);
end

% Generate a candidate set appropriate for this model,
% and get a matrix of model terms
[xcand,fxcand] = candgen(nfactors,model);

% Get a starting design chosen at random within factor range
% (may be overridden in varargin), plus model terms for this design
if isempty(settings)
   settings = unifrnd(-1,1,nruns,nfactors);
elseif size(settings,1)~=nruns | size(settings,2)~=nfactors
   error('stats:rowexch:BadDesign',...
         'Initial design must be a %d-by-%d matrix.',nruns,nfactors);
end
X = x2fx(settings,model);

% Call candexch to generate design
rowlist = candexch(fxcand,nruns,'init',X,restargs{:});

% Return factor settings and model term values if requested
settings = xcand(rowlist,:);
if nargout>1
   X = fxcand(rowlist,:);
end
