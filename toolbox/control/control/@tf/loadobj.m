function sys = loadobj(s)
%LOADOBJ  Load filter for tf objects

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/01/07 19:32:46 $
sys = s;
% Update LTI parent's version
[sys.lti,loadver,newver] = revise(s.lti);
if loadver<newver
   % Issue warning
   updatewarn
end