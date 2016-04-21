function [Phi, Gamma] = c2d(a, b, t)
%C2D	Conversion of state space models from continuous to discrete time.
%	[Phi, Gamma] = C2D(A,B,T)  converts the continuous-time system:
%		.
%		x = Ax + Bu
%
%	to the discrete-time state-space system:
%
%		x[n+1] = Phi * x[n] + Gamma * u[n]
%
%	assuming a zero-order hold on the inputs and sample time T.
%
%	See also D2C.

%	J.N. Little 4-21-85
%	Copyright 1990-2002 The MathWorks, Inc.
%	$Revision: 1.6 $  $Date: 2002/04/10 18:28:51 $

error(nargchk(3,3,nargin));
error(abcdchk(a,b));

[m,n] = size(a);
[m,nb] = size(b);
s = expm([[a b]*t; zeros(nb,n+nb)]);
Phi = s(1:n,1:n);
Gamma = s(1:n,n+1:n+nb);

% end c2d
