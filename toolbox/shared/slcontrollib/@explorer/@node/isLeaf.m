function flag = isLeaf(this)
% ISLEAF Returns whether the specified node is a leaf node.
   
% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:50 $

if ~isempty( this.down )
  flag = false;
else
  flag = ~this.AllowsChildren;
end
