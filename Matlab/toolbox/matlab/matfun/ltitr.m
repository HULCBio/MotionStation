function [varargout] = ltitr(varargin)
%LTITR	Linear time-invariant time response kernel.
%
%   X = LTITR(A,B,U) calculates the time response of the
%   system:
%           x[n+1] = Ax[n] + Bu[n]
%
%   to input sequence U.  The matrix U must have as many columns as
%   there are inputs u.  Each row of U corresponds to a new time 
%   point.  LTITR returns a matrix X with as many columns as the
%   number of states x, and with LENGTH(U) rows.
%
%   LTITR(A,B,U,X0) can be used if initial conditions exist.
%   Here is what it implements, in high speed:
%
%	for i=1:n
%          x(:,i) = x0;
%          x0 = a * x0 + b * u(i,:).';
%	end
%	x = x.';

%	Copyright 1984-2003 The MathWorks, Inc. 
%	$Revision: 1.1.6.1 $  $Date: 2003/10/07 04:55:59 $

% built-in function

if nargout == 0
  builtin('ltitr', varargin{:});
else
  [varargout{1:nargout}] = builtin('ltitr', varargin{:});
end
