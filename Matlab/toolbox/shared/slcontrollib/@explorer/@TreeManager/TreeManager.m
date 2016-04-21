function this = TreeManager( root )
% TREEMANAGER Constructor for @TreeManager object

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:20 $

% Create class instance
this = explorer.TreeManager;

% Set properties
this.Root = root;

% Create explorer
import com.mathworks.toolbox.control.explorer.*;
this.ExplorerPanel = ExplorerPanel( root.getTreeNodeInterface );
this.Explorer      = Explorer( this.ExplorerPanel );

% Add Java related callbacks
this.addCallbacks;

% Add UDD related listeners
this.addListeners

% Initially select the top node
this.ExplorerPanel.setSelected( this.Root.getTreeNodeInterface );
