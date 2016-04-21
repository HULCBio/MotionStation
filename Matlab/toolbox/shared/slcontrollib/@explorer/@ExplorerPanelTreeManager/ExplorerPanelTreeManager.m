function this = ExplorerPanelTreeManager( root, ExplorerPanel )
% EXPLORERPANELTREEMANAGER Constructor for @ExplorerPanelTreeManager object

% Author(s): John Glass
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:03 $

% Create class instance
this = explorer.ExplorerPanelTreeManager;

% Set properties
this.Root = explorer.Workspace;
% Set the passed root to be a child of this.Root
this.Root.addNode(root);

% Add the explorer panel
this.ExplorerPanel = ExplorerPanel;

% Add Java related callbacks
this.addCallbacks;

% Add UDD related listeners
this.addListeners

% Initially select the top node
this.ExplorerPanel.setRoot(this.Root.getTreeNodeInterface);
sel=ExplorerPanel.getSelector;
sel.getTree.setRootVisible(false)
this.ExplorerPanel.setSelected( root.getTreeNodeInterface );
