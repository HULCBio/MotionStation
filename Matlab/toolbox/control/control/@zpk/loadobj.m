function sys = loadobj(s)
%LOADOBJ  Load filter for zpk objects

%   Author(s): G. Wolodkin 4-17-98
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/01/07 19:32:49 $

% Pull versioning info from LTI parent and update its version
[s.lti,loadver,newver] = revise(s.lti);
if loadver<newver
   % Issue warning
   updatewarn
   % Create object of latest version
   sys = zpk(s.z,s.p,s.k,s.lti);
   sys.Variable = s.Variable;   
else
   sys = s;
end