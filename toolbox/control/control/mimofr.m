function [varargout] = mimofr(varargin)
%MIMOFR	 Linear time-invariant frequency response.
%
%   H = MIMOFR(A,B,C,E,S) calculates the frequency response of the
%   continuous- or discrete-time system:
%
%   	 G(s) = C*(s*E - A)\B
%
%   for the complex frequencies in vector S.  You can set C=[] or E=[]
%   when C or E are the identity matrix.
%
%   See also: FREQRESP.

%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.5.4.2 $  $Date: 2004/04/10 23:13:42 $

% MIMOFR is a built-in function

if nargout == 0
  builtin('mimofr', varargin{:});
else
  [varargout{1:nargout}] = builtin('mimofr', varargin{:});
end
