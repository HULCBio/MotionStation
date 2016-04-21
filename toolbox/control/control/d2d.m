function [a, b] = d2d(phi, gamma, t1, t2)
%D2D  Resample discrete LTI system.
%
%   SYS = D2D(SYS,TS) resamples the discrete-time LTI model SYS 
%   to produce an equivalent discrete system with sample time TS.
%
%   See also D2C, C2D, LTIMODELS.

%Old help
%D2D	Conversion of discrete state-space models to models with diff. sampling times.
%	[A2, B2] = D2D(A1, B1, T1, T2)  converts the discrete-time system:
%
%		x[n+1] = A1 * x[n] + B1 * u[n]
%
%	with a sampling rate of T1 to a discrete system with a sampling rate of T2.
%	The method is accurate for constant inputs. For non-integer multiples of T1
%	and T2, D2D may return complex A and B matrices. 
%
%	See also D2C and C2D.

%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.12 $
%	Andrew C. W. Grace 2-20-91

error(nargchk(4,4,nargin));
error(abcdchk(phi,gamma));

[m,n] = size(phi);
[m,nb] = size(gamma);

nz = nb;
nonzero = [1:nb];

s = [[phi gamma(:,nonzero)]; zeros(nz,n) eye(nz)]^(t2/t1);
a = s(1:n,1:n);
if length(nonzero)
	b(:,nonzero) = s(1:n,n+1:n+nz);
end
