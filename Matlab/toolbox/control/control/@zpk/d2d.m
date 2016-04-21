function sys = d2d(sys,Ts,Nd)
%D2D  Resample discrete LTI system.
%
%   SYS = D2D(SYS,TS) resamples the discrete-time LTI model SYS 
%   to produce an equivalent discrete system with sample time TS.
%
%   See also D2C, C2D, LTIMODELS.

%	Andrew C. W. Grace 2-20-91, P. Gahinet 8-28-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.15 $  $Date: 2002/04/10 06:13:04 $

ni = nargin;
error(nargchk(2,3,ni));
% Trap 4.0 syntax D2D(SYS,[],Nd) where Nd = input delays
if ni==3,
   if any(abs(Nd-round(Nd))>1e3*eps*abs(Nd)),
      error('Last argument ND must be a vector of integers.')
   elseif ~isequal(size(Nd),[1 1]) & length(Nd)~=size(sys,2),
      error('Length of ND must match number of inputs.')
   end
   set(sys,'inputdelay',round(Nd));
   % Call DELAY2Z
   sys = delay2z(sys);
   return
end

% Call ss/d2d
try
   sys = zpk(d2d(ss(sys),Ts));
catch
   rethrow(lasterror)
end

