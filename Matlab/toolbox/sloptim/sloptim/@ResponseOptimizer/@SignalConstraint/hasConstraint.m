function boo = hasConstraint(this)
% Returns true if contributes to optimization constraints.

%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:45:58 $
%   Copyright 1986-2004 The MathWorks, Inc.
boo = strcmp(this.Enable,'on') && strcmp(this.ConstrEnable,'on');
