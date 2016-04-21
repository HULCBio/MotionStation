function flag = isHierarchical(this)
% ISHIERARCHICAL Returns whether the specified node is a hierarchical node.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:49 $

if ~isempty( this.down )
  flag = true;
else
  flag = this.AllowsChildren;
end
