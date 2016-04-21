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

%	Copyright 1984-2003 The MathWorks, Inc. 
%	$Revision: 1.1.6.1 $  $Date: 2003/10/07 04:56:00 $

% MIMOFR is a built-in function

if nargout == 0
  builtin('mimofr', varargin{:});
else
  [varargout{1:nargout}] = builtin('mimofr', varargin{:});
end
