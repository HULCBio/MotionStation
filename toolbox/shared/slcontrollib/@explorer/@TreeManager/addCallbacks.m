function addCallbacks( this )
% ADDCALLBACKS Add Java related callbacks

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:21 $

% Add event listeners
h = handle( this.Explorer, 'callbackproperties' );
h.WindowClosingCallback = { @LocalWindowClosing, this };

h = handle( this.ExplorerPanel.getSelector, 'callbackproperties' );
h.SelectionChangedCallback = { @LocalSelectionChanged, this};
h.PopupTriggeredCallback   = { @LocalPopupTriggered,   this};

% ---------------------------------------------------------------------------- %
function LocalWindowClosing(hSrc, hData, this)

% Force the focus to the frame so that ant focusloast events are processed
% before the save and none of the focuslost callbacks will fire after nodes
% have been deleted
this.Explorer.requestFocus
drawnow

% Get the children of the workspace
children = this.Root.getChildren;
for k = 1:length(children)
  abortFlag = LocalSaveProject(this, children(k));
  if abortFlag
    return;
  end
end

% Remove all children
for k = length(children):-1:1
  this.Root.removeNode( children(k) );
  % children(k).delete;
end

% Set the workspace node to be the one selected
this.ExplorerPanel.setSelected( this.Root.getTreeNodeInterface );

% Clear the status area
this.Explorer.clearText;
drawnow

this.Explorer.setVisible(false);

% ---------------------------------------------------------------------------- %
function abortFlag = LocalSaveProject(this, node)
abortFlag = false;
if node.Dirty
  message   = sprintf('Do you want to save the changes to %s?', node.Label);
  selection = questdlg(message, 'Save Project', 'Yes', 'No', 'Cancel', 'Yes');
  
  switch selection
  case 'Yes', 
    this.saveas(node, true)
  case 'No',
    % no action
  case 'Cancel'
    abortFlag = true;
  end
end

% ---------------------------------------------------------------------------- %
function LocalPopupTriggered(hSrc, hData, this)
h = handle( hData.getNode.getObject );
e = hData.getEvent;

popup = h.getPopupInterface( this );
if ~isempty(popup) 
  popup.show( hData.getSource, e.getX, e.getY );
  popup.repaint;
end

% ---------------------------------------------------------------------------- %
function LocalSelectionChanged(hSrc, hData, this)
h = handle( hData.getNode.getObject );
ExplorerPanel = this.ExplorerPanel;
Explorer      = this.Explorer;

% Set explorer components
if ~isempty( Explorer )
  [menubar, toolbar] = getMenuToolBarInterface( h.getRoot, this );
  Explorer.setExplorerComponents(menubar, toolbar, h.Status, ...
                                          h.getRoot.getGUIResources);
end

% Set explorer panel
busy   = java.awt.Cursor( java.awt.Cursor.WAIT_CURSOR );
normal = java.awt.Cursor( java.awt.Cursor.DEFAULT_CURSOR );

Explorer.setCursor(busy)
Explorer.setEnabled(0);

try
  % Get the panel
  Panel = getDialogInterface( h, this );
catch
  import javax.swing.JOptionPane;
  util = slcontrol.Utilities;
  beep;
  JOptionPane.showMessageDialog( this.Explorer, util.getLastError, ...
                                 'Tools Manager Error', ...
                                 JOptionPane.WARNING_MESSAGE );
  Panel = com.mathworks.mwswing.MJPanel;
end

% Set the panel
ExplorerPanel.getDisplayer.setDialog( Panel );

Explorer.setEnabled(1)
Explorer.setCursor(normal)
