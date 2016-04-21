function [varargout] = rcond(varargin)
%RCOND  LAPACK reciprocal condition estimator.
%   RCOND(X) is an estimate for the reciprocal of the
%   condition of X in the 1-norm obtained by the LAPACK
%   condition estimator. If X is well conditioned, RCOND(X)
%   is near 1.0. If X is badly conditioned, RCOND(X) is
%   near EPS.
%
%   See also COND, NORM, CONDEST, NORMEST.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.2 $  $Date: 2004/04/16 22:07:32 $
%   Built-in function.

if nargout == 0
  builtin('rcond', varargin{:});
else
  [varargout{1:nargout}] = builtin('rcond', varargin{:});
end
