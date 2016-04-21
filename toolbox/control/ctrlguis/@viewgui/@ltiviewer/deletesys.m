function deletesys(this,SystemNames)
% DELETESYS deletes LTI systems from the LTIVIEWER
%   Author: Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/05/04 02:09:23 $

%Find to be deleted list of systems in h.Systems
[sysRemaining,indKeep] = setdiff(get(this.Systems,{'Name'}),SystemNames); 
this.Systems = this.Systems(sort(indKeep));
plural = 's';
statstr = sprintf('%d system%s deleted from the Viewer.',length(SystemNames),...
    plural(:,(length(SystemNames)~=1)));
this.EventManager.newstatus(statstr);
