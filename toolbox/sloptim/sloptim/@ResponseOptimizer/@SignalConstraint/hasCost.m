function boo = hasCost(this)
% Returns true if contributes to optimization constraints.

%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:45:59 $
%   Copyright 1986-2004 The MathWorks, Inc.
boo = strcmp(this.Enable,'on') && ...
   strcmp(this.CostEnable,'on') && ~isempty(this.ReferenceX);
