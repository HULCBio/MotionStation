function boo = isdt(sys)
%ISDT  Check if LTI model is discrete time.
%
%   ISDT(SYS) returns 1 (true) if the LTI model SYS is 
%   discrete, 0 (false) otherwise.  ISDT always returns 1 
%   for empty systems or static gains.
%
%   See also ISCT.

%       Author(s): P. Gahinet, 1-4-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.13.4.1 $


% SYS is discrete if it is a gain or Ts ~= 0
if getst(sys.lti)~=0,
   boo = true;
else
   boo = isstatic(sys);
end

