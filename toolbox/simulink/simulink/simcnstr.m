function [x, OPTIONS,lambda, HESS]=simcnstr(caller,FUN,x,OPTIONS,...
                                            VLB,VUB,GRADFUN,varargin)
%SIMCNSTR Used by trim.m and ncd/nlinopt.m.
%   SIMCNSTR is a helper function used by the TRIM function and the Nonlinear
%   Control Design (NCD) Toolbox function NLINOPT.
%
%   See also TRIM.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.43 $

if nargin < 2, error('simcnstr requires two input arguments'); end
if nargin < 3, OPTIONS=[]; end
if nargin < 4, VLB=[]; end
if nargin < 5, VUB=[]; end
if nargin < 6, GRADFUN=[]; end

lenVarIn = length(varargin);

% Convert to inline function as needed.
[funfcn,msg] = prefcnchk(FUN,caller,lenVarIn);
if ~isempty(msg)
  error(msg);
end

if ~isempty(GRADFUN)
  [gradfcn,msg] = prefcnchk(GRADFUN,caller,lenVarIn);
  if ~isempty(msg)
    error(msg);
  end
else
  gradfcn = [];
end

[x,OPTIONS,lambda,HESS]=nlconst(funfcn,x,OPTIONS,VLB,VUB,gradfcn,varargin{:});

