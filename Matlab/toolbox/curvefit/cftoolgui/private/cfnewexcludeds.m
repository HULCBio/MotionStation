function cfnewexcludeds
%CFNEWEXCLUDEDS Called when the exclusion dataset changes

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.3.2.1 $  $Date: 2004/02/01 21:39:58 $

% Find the exclusion graph's figure window, and delete it
t = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
c = get(0,'Child');
f = findobj(c,'flat','Type','figure','Tag','cfexcludegraph');
set(0,'ShowHiddenHandles',t);
delete(f);
