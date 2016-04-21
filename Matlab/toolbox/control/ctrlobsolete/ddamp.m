function [magout,wn,z] = ddamp(a,Ts)
%DDAMP  Natural frequency and damping factor for discrete systems.
%   [MAG,Wn,Z] = DDAMP(A,Ts) returns vectors MAG, Wn and Z containing
%   the z-plane magnitude, and the equivalent s-plane natural 
%   frequency and damping factors of A.  Ts is the sample time.  The
%   variable A can be in one of several formats:
%       1) If A is square, it is assumed to be the state-space
%          "A" matrix.
%       2) If A is a row vector, it is assumed to be a vector of
%          the polynomial coefficients from a transfer function.
%       3) If A is a column vector, it is assumed to contain
%          root locations.
%
%   Without the sample time, DDAMP(A) returns the magnitude only.  
%   When invoked without left hand arguments DDAMP prints the 
%   eigenvalues with their magnitude, natural frequency and damping
%   factor in a tabular format on the screen.
%
%   For a discrete system eigenvalue, lambda, the equivalent s-plane
%   natural frequency and damping ratio are
%
%       Wn = abs(log(lamba))/Ts    Z = -cos(angle(log(lamba)))
%
%   See also: EIG and DAMP.

%   Clay M. Thompson  7-23-90
%   Copyright 1986-2002 The MathWorks, Inc.  
%   $Revision: 1.13 $  $Date: 2002/04/10 06:34:40 $

error(nargchk(1,2,nargin));
if nargin==1
   Ts = -1;  % unspecified
end

% Compute Wn and Z
try
   [wn,z,r] = damp(a,Ts);
catch
   rethrow(lasterror)
end

if nargout==0,      
   % Print results on the screen. First generate corresponding strings:
   printdamp(r,wn,z,Ts)
else
   magout = abs(r); 
end

