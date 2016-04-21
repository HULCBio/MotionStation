function h = getHierarchicalChildren(this)
% GETHIERARCHICALCHILDREN Gets all the immediate children under this node
% which have children themselves.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:44 $

h = this.children(true);
