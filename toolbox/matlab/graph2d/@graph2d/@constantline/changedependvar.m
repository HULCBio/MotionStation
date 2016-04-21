function cline = changedependvar(cline,newvar);
% CHANGEDEPENDVAR  Change dependent variable.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/15 03:58:54 $

cline.DependVar = newvar;
update(cline);