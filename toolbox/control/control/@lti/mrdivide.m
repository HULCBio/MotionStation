function sys = mrdivide(sys2,sys1)
%MRDIVIDE  Right division for LTI models.
%
%   SYS = MRDIVIDE(SYS1,SYS2) is invoked by SYS=SYS1/SYS2.
%   and is equivalent to SYS = SYS1*INV(SYS2).
%
%   See also MLDIVIDE, INV, MTIMES, LTIMODELS.

%   Author(s): A. Potvin, 3-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 05:49:25 $


% Simplify delays when SYS1 is SISO and delayed
if isa(sys1,'lti') & isa(sys2,'lti')
   [sys1,sys2] = simpdelay(sys1,sys2);
end

% Handle case where SYS1 still has delays
d2z = 0;
if isa(sys1,'lti') & hasdelay(sys1)
   if sys1.Ts,
      sys1 = delay2z(sys1);
      d2z = 1;
   elseif issiso(sys1)
      error('In SYS1/SYS2, resulting model is non causal.')
   else
      % SYS1 is MIMO 
      error('In SYS1/SYS2, MIMO model SYS2 must be delay free.')
   end
end

% Perform product SYS2*INV(SYS1)
try
   sys = sys2*inv(sys1);
catch
   if d2z, 
      % Case where mapping of delays to poles at z=0 result
      % in non-invertible SS model
      error('In SYS1/SYS2, model SYS2 cannot be inverted.')
   else
      rethrow(lasterror)
   end
end

