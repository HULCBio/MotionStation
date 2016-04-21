function h = getChildren(this)
% GETCHILDREN Gets all the immediate children under this node.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:41 $

h = this.children(false);
