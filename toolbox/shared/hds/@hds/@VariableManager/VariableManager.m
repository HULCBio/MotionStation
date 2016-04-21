function this = VariableManager
% Returns handle of Variable Manager object.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:29:08 $
mlock
persistent h
           
if isempty(h)
    % Create singleton class instance (first time an HDS dataset is
    % created)
    h = hds.VariableManager;
end

this = h;

