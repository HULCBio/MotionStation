function cline = changedependvar(cline,newvar);
% CHANGEDEPENDVAR  Change dependent variable.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $  $Date: 2004/03/30 13:07:10 $

cline.DependVar = newvar;
update(cline);