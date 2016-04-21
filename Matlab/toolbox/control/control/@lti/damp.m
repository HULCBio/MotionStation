function [wnout,z,r] = damp(sys)
%DAMP  Natural frequency and damping of LTI model poles.
%
%    [Wn,Z] = DAMP(SYS) returns vectors Wn and Z containing the
%    natural frequencies and damping factors of the LTI model SYS.
%    For discrete-time models, the equivalent s-plane natural 
%    frequency and damping ratio of an eigenvalue lambda are:
%               
%       Wn = abs(log(lambda))/Ts ,   Z = -cos(angle(log(lambda))) .
%
%    Wn and Z are empty vectors if the sample time Ts is undefined.
%
%    [Wn,Z,P] = DAMP(SYS) also returns the poles P of SYS.
%
%    When invoked without left-hand arguments, DAMP prints the poles
%    with their natural frequency and damping factor in a tabular format 
%    on the screen.  The poles are sorted by increasing frequency.
%
%    See also POLE, ESORT, DSORT, PZMAP, ZERO.

%   J.N. Little 10-11-85
%   Revised 3-12-87 JNL
%   Revised 7-23-90 Clay M. Thompson
%   Revised 6-25-96 Pascal Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/10 05:51:22 $

% Compute the pole characteristics
r = pole(sys);
[wn,z] = damp(r,sys.Ts);

% Sort by increasing natural frequency
sr = size(r);
if sys.Ts>=0
   for k=1:prod(sr(3:end))
      % RE: SORT does the right thing with NaNs
      [wn(:,k),perm] = sort(wn(:,k));
      r(:,k) = r(perm,k);
      z(:,k) = z(perm,k);
   end
else
   % Discrete system with unspecified Ts: sort by mag
   for k=1:prod(sr(3:end)),
      ifin = isfinite(r(:,k));
      r(ifin,k) = dsort(r(ifin,k));
   end
end

% Output
if nargout
   wnout = wn;
elseif length(sr)>2
   error('Display not available for model arrays.') 
else   
   printdamp(r,wn,z,sys.Ts)
end

 