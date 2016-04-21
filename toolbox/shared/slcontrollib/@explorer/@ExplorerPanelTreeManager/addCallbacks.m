function addCallbacks( this )
% ADDCALLBACKS Add Java related callbacks

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2001 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/19 01:31:12 $

% Add event listeners
Tree = this.ExplorerPanel.getSelector.getTree;
set( Tree, 'MousePressedCallback',  @LocalMousePressed );
set( Tree, 'MouseReleasedCallback', @LocalMouseReleased );
this.Handles.Tree = Tree;

Selector = this.ExplorerPanel.getSelector;
set( Selector, 'SelectionChangedCallback', {@LocalValueChanged, this} );
set( Selector, 'PopupTriggeredCallback',   {@LocalPopupTriggered, this} );
this.Handles.Selector = Selector;

TreeCellEditor = this.Handles.Tree.getCellEditor;
set( TreeCellEditor, 'EditingStoppedCallback', @LocalEditingStopped )
this.Handles.TreeCellEditor = TreeCellEditor;

% ---------------------------------------------------------------------------- %
function LocalPopupTriggered(hSrc, hData, this)
% disp('popup triggered')
node = hData.getNode;
h = find(this.Root, 'TreeNode', node);

popup = h.getPopupInterface( this );
if ~isempty(popup)
    popup.show( hData.getSource, 40, 40 )
end

% ---------------------------------------------------------------------------- %
function LocalValueChanged(hSrc, hData, this)

h = handle( hData.getNode.getObject );
ExplorerPanel = this.ExplorerPanel;
Explorer      = slctrlexplorer;

try
    % Get the panel
    Panel = getDialogInterface( h, this );

    % Set the panel
    ExplorerPanel.getDisplayer.setDialog( Panel );
    %% Used to post a PropertyView refresh event for the linearization
    %% inspector.
    if isa(h,'GenericLinearizationNodes.SubsystemMarker')
        awtinvoke(Panel.pv,'triggerRefresh')
    end
catch
  import javax.swing.JOptionPane;
  util = slcontrol.Utilities;
  beep;
  JOptionPane.showMessageDialog( this.Explorer, util.getLastError, ...
                                 'Tools Manager Error', ...
                                 JOptionPane.WARNING_MESSAGE );
  Panel = com.mathworks.mwswing.MJPanel;
  % Set the panel
  ExplorerPanel.getDisplayer.setDialog( Panel );
end

% ---------------------------------------------------------------------------- %
function LocalMousePressed(hSrc, hData)
% disp('mouse pressed')


% ---------------------------------------------------------------------------- %
function LocalMouseReleased(hSrc, hData)
% disp('mouse released.')


% ---------------------------------------------------------------------------- %
function LocalEditingStopped(hSrc, hData)
% disp('editing stopped')

