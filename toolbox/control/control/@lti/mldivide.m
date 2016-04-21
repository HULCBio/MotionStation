function sys = mldivide(sys1,sys2)
%MLDIVIDE  Left division for LTI models.
%
%   SYS = MLDIVIDE(SYS1,SYS2) is invoked by SYS=SYS1\SYS2
%   and is equivalent to SYS = INV(SYS1)*SYS2.
%
%   See also MRDIVIDE, INV, MTIMES, LTIMODELS.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 05:49:34 $


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
      error('In SYS1\SYS2, resulting model is non causal.')
   else
      % SYS1 is MIMO 
      error('In SYS1\SYS2, MIMO model SYS1 must be delay free.')
   end
end


% Perform product INV(SYS1)*SYS2
try
   sys = inv(sys1)*sys2;
catch
   if d2z, 
      % Case where mapping of delays to poles at z=0 result
      % in non-invertible SS model
      error('In SYS1\SYS2, model SYS1 cannot be inverted.')
   else
      error('%s', lasterr)
   end
end
