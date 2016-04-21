function sys = loadobj(s)
%LOADOBJ  Load filter for SS objects

%   Author(s): G. Wolodkin 4-17-98
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2003/01/07 19:32:40 $

% Pull versioning info from LTI parent and update its version
[s.lti,loadver,newver] = revise(s.lti);
if loadver<newver
   % Issue warning
   updatewarn
   % Create object of latest version
   sys = dss(s.a,s.b,s.c,s.d,s.e,s.lti);
   sys.StateName = s.StateName;
else 
   sys = s;
end