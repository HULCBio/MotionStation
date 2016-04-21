function this = ProjectManager
% Parameter Tuning Project Constructor

%   Author(s): Kamesh Subbarao
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:16 $
%   Copyright 1986-2003 The MathWorks, Inc.
mlock
persistent h

if isempty(h)
   h = srogui.ProjectManager;
end
this = h;
