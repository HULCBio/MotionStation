function [out] = uigettool(fig,id)
% This undocumented function may change in a future release.

% C = UIGETTOOL(H,'GroupName.ComponentName')
%     H is a toolbar handle
%     'GroupName' is the name of the toolbar group
%     'ComponentName' is the name of the toolbar component
%     C is a toolbar component
%
% See also UITOOLFACTORY

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2003/10/30 18:45:27 $

% Note: All code here must have fast performance
% since this function will be used in callbacks.
htoolbar = findall(fig,'type','uitoolbar');
out = findall(htoolbar,'Tag',id);
