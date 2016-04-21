function hChildren = children(this, flag)
% CHILDREN Private method to get child leaves.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:36 $

hChildren = [];
NextLeaf  = this.down;

while ~isempty( NextLeaf )
  if isa( NextLeaf, 'explorer.node' ) && (~flag || NextLeaf.isHierarchical)
    hChildren = [ hChildren; NextLeaf ];
  end
  NextLeaf = NextLeaf.right;
end
