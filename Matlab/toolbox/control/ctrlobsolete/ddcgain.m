function k = ddcgain(a,b,c,d)
%DDCGAIN D.C. gain of discrete system.
%	K = DDCGAIN(A,B,C,D) computes the steady state (D.C. or low 
%	frequency) gain of the discrete state-space system (A,B,C,D).
%
%	K = DDCGAIN(NUM,DEN) computes the steady state gain of the 
%	discrete polynomial transfer function system G(z) = NUM(z)/DEN(z)
%	where NUM and DEN contain the polynomial coefficients in 
%	descending powers of z.
%
%	See also: DCGAIN.

%	Clay M. Thompson  7-6-90
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.9 $  $Date: 2002/04/10 06:34:38 $

error(nargchk(2,4,nargin));

if (nargin==2), % Transfer function description
  k = dcgain(tf(a,b,1));

elseif nargin==4, % State space description
  k = dcgain(ss(a,b,c,d,1));

else
  error('Wrong number of input arguments.');
end
