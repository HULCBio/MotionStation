function hOut = addNode(this, varargin)
% ADDNODE Adds a leaf node to this node

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:35 $

% If no leaf is supplied, add a default child
if isempty( varargin )
  leaf = this.createChild;
else
  leaf = varargin{1};
end

if isa( leaf, 'explorer.node' )
  if isUniqueName(this, leaf)
    connect( leaf, this, 'up' );
  else
    msg = sprintf( 'The folder %s already contains a node named %s.\n%s', ...
                   this.Label, leaf.Label, ...
                   'Would you like to replace the existing node?' );
    import javax.swing.JOptionPane;
    idx = JOptionPane.showConfirmDialog( [], msg, ...
                                         'Confirm Node Replace', ...
                                         JOptionPane.YES_NO_OPTION );
    switch idx
    case 0
      % 'Yes' selected
      nodes = this.getChildren;
      node = nodes( strcmp(get(nodes, {'Label'}), leaf.Label) );
      this.removeNode(node)
      connect( leaf, this, 'up' );
    case 1
      % 'No' selected
      leaf = [];
    end
  end
elseif isempty(leaf)
  % Do nothing
else
  error( '%s is not of type @explorer/@node', class(leaf) )
end

if nargout > 0
  hOut = leaf;
end

% -----------------------------------------------------------------------------
function flag = isUniqueName(this, leaf)
flag = true;

if isempty(this.getChildren)
  return
end

nodes = this.getChildren;
peers = nodes( leaf ~= nodes );
names = get( peers, {'Label'});

if any( strcmp( leaf.Label, names) )
  flag = false;
end
