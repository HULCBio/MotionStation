function [sys1,g,T,Ti] = balreal(sys)
%BALREAL  Gramian-based balancing of state-space realizations.
%   Requires the Control Systems Toolbox.
%
%   MODb = BALREAL(MOD) returns a balanced state-space realization 
%   of the reachable, observable, stable model MOD, given as an
%   IDSS or IDGREY model.
%
%   [MODb,G,T,Ti] = BALREAL(MOD) also returns a vector G containing
%   the diagonal of the Gramian of the balanced realization.  The
%   matrices T is the state transformation xb = Tx used to convert SYS
%   to SYSb, and Ti is its inverse.  
%
%   If the system is normalized properly, small elements in the balanced
%   Gramian G indicate states that can be removed to reduce the model 
%   to lower order.
%
%   The noise input contributions are also balanced. To obtain a
%   balanced model with just measured inputs, use BALREAL(MOD('m')).
%
%   The covariance information is lost in the transition.

%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.5.4.1 $  $Date: 2004/04/10 23:17:17 $

if ~(isa(sys,'idss')|isa(sys,'idgrey'))
  error('BALREAL applies only to IDGREY and IDSS models.')
end
try
sys1 = ss(sys);
nx = size(sys,'nx');
catch
  error(lasterr)
end
if nargout == 1
sys1 = balreal(sys1);
else
  [sys1,g,T,Ti] = balreal(sys1);
end
sys1 = idss(sys1);
sys1=pvset(sys1,'DisturbanceModel',pvget(sys,'DisturbanceModel'),...
    'Algorithm',pvget(sys,'Algorithm'));
