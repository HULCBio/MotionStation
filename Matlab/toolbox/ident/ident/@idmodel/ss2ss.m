function sys = ss2ss(sys,T)
%SS2SS  Change of state coordinates for state-space models.
%
%   MOD = SS2SS(MOD,T) performs the similarity transformation 
%   z = Tx on the state vector x of the state-space model SYS.  
%   The resulting state-space model is described by:
%
%               .       -1        
%               z = [TAT  ] z + [TB] u + [TK] e
%                       -1
%               y = [CT   ] z + D u + e
%
%
%   SS2SS is applicable to both continuous- and discrete-time 
%   models.
%
%   Covariance information is lost in the transformation.

%       Copyright 1986-2001 The MathWorks, Inc.
%    $Revision: 1.3 $  $Date: 2001/04/06 14:22:17 $

if isa(sys,'idgrey')
  sys = idss(sys);
  sys = ss2ss(sys,T);
else
  error('SS2SS is meaningful only for IDGREY and IDSS models.')
end


 