function [settings, X] = daugment(startdes,nruns,model,varargin)
%DAUGMENT Augment D-Optimal design.
%   [SETTINGS, X] = DAUGMENT(STARTDES,NRUNS,MODEL) adds NRUNS runs
%   to an experimental design using the coordinate exchange D-optimal
%   algorithm.  STARTDES is a matrix of factor settings in the original
%   design.  Outputs are the factor settings matrix SETTINGS, and the
%   associated matrix of model terms X (oftens called the design matrix).
%   MODEL is an optional argument that controls the order of the
%   regression model.  By default, DAUGMENT returns the design matrix
%   for a linear additive model with a constant term.  MODEL can be any
%   of the following strings:
%
%     'linear'        constant and linear terms (the default)
%     'interaction'   includes constant, linear, and cross product terms.
%     'quadratic'     interactions plus squared terms.
%     'purequadratic' includes constant, linear and squared terms.
%
%   Alternatively MODEL can be a matrix of term definitions as
%   accepted by the X2FX function.
%
%   [SETTINGS, X] = DAUGMENT(...,'PARAM1',VALUE1,'PARAM2',VALUE2,...)
%   provides more control over the design generation through a set of
%   parameter/value pairs.  Valid parameters are the following:
%
%      Parameter    Value
%      'display'    Either 'on' or 'off' to control display of
%                   iteration counter (default = 'on').
%      'init'       Initial design as a matrix with NRUNS rows
%                   (default is a randomly selected set of points).
%      'maxiter'    Maximum number of iterations (default = 10).
%
%   See also CORDEXCH, X2FX.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.2.1 $  $Date: 2004/01/24 09:33:17 $

[nobs,nfactors] = size(startdes);
if nargin<3, model='linear'; end
[settings,X] = cordexch(nfactors,nruns,model,'start',startdes,varargin{:});
