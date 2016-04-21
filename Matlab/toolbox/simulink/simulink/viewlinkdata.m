function varargout = viewlinkdata(varargin)
%VIEWLINKDATA controls and manages the display of LinkData information

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.10 $
%   Sanjai Singh 12-12-99

% Userdata to cache information
% Contains following fields : BLOCK, DATA and GUI
persistent USERDATA

% lock to prevent tampering
mlock

error(nargchk(2, 2, nargin));

% Determine action to be performed
if strcmp(varargin{1}, 'Callback')
  Action = varargin{2};
else
  Action = varargin{1};
  arg    = varargin{2};
end
  
% Process action
switch (Action)
 case 'Create'
  % Test for existence of java
  if ~usejava('MWT')
    error(['The link data dialog requires Java support. ' ...
	   'Use set_param/get_param of the ''LinkData'' property instead'])
  end
    
  % If we already have a dialog for this block, update it
  ud_idx   = i_FindBlockInUserData(USERDATA, get_param(arg, 'Handle'));
  
  if (ud_idx < 1)
    % Add this to userdata and create dialog
    idx = length(USERDATA) + 1;  
    USERDATA(idx).BLOCK = get_param(arg, 'Handle');
    USERDATA(idx).DATA  = get_param(arg, 'LinkData');
    USERDATA(idx).GUI   = i_CreateViewer;
    i_SetViewerLocation(USERDATA(idx).BLOCK, USERDATA(idx).GUI.FRAME);
  else
    % Use existing GUI and poluate with new data
    idx = ud_idx;
    USERDATA(idx).DATA  = get_param(arg, 'LinkData');
  end
  i_PopulateViewer(USERDATA(idx).GUI, USERDATA(idx).DATA, get_param(arg, 'Name'));
  frame = USERDATA(idx).GUI.FRAME;
  frame.show;
  
 case 'Delete'
  idx   = i_FindBlockInUserData(USERDATA, arg);
  if (idx > 0)
    frame = USERDATA(idx).GUI.FRAME;
    frame.dispose;
    USERDATA(idx) = [];
  end
  
 case 'OK'
  idx   = i_FindUserDataIndex(USERDATA, 'OK_BUTTON', gcbo);
  frame = USERDATA(idx).GUI.FRAME;
  data  = USERDATA(idx).DATA;
  set_param(USERDATA(idx).BLOCK, 'LinkData', data);
  frame.dispose;
  USERDATA(idx) = [];
  
 case 'CloseWindow'
  idx   = i_FindUserDataIndex(USERDATA, 'FRAME', gcbo);
  frame = USERDATA(idx).GUI.FRAME;
  frame.dispose;
  USERDATA(idx) = [];
  
 case 'Cancel'
  idx   = i_FindUserDataIndex(USERDATA, 'CANCEL_BUTTON', gcbo);
  frame = USERDATA(idx).GUI.FRAME;
  frame.dispose;
  USERDATA(idx) = [];
  
 case 'Apply'
  idx   = i_FindUserDataIndex(USERDATA, 'APPLY_BUTTON', gcbo);
  frame = USERDATA(idx).GUI.FRAME;
  data  = USERDATA(idx).DATA;
  set_param(USERDATA(idx).BLOCK, 'LinkData', data);
  apply = USERDATA(idx).GUI.APPLY_BUTTON;
  apply.setEnabled(0);
  
 case 'BlockChanged'
  % Determine which block changed
  ud_idx     = i_FindUserDataIndex(USERDATA, 'BLOCK_LIST', gcbo);
  block_list = USERDATA(ud_idx).GUI.BLOCK_LIST;

  % Proceed if something is selected
  selectedRow= block_list.getFirstSelectedRow;
  if (selectedRow >= 0)
    name = i_getSelectedItemFullname(block_list);
    data = USERDATA(ud_idx).DATA;
    idx  = find(strcmp(name,{data.BlockName}));

    % Remove existing data in Parameters list
    param_list = USERDATA(ud_idx).GUI.PARAM_LIST;
    param_list.removeAllItems;

    % Add data to Parameters list
    if (~isempty(idx)) 
      bData  = data(idx).DialogParameters;
      fields = fieldnames(bData);
      for i = 1:length(fields)
	param_list.addItem({fields{i}, eval(['bData.' fields{i}])});
      end
    else
      param_list.addItem('No changes');
    end
  
    % Enable delete button
    listDeleteButton = USERDATA(ud_idx).GUI.BLOCK_LIST_DELETE;
    listDeleteButton.setEnabled(1);
  end
  
 case 'BlockListDelete'
    % Determine which block to delete
    ud_idx     = i_FindUserDataIndex(USERDATA, 'BLOCK_LIST_DELETE', gcbo);
    block_list = USERDATA(ud_idx).GUI.BLOCK_LIST;

    % Update data
    selectedRow= block_list.getFirstSelectedRow;
    if (selectedRow >= 0)
      selectedId = block_list.getItemId(selectedRow);
      name       = i_getSelectedItemFullname(block_list);
      data       = USERDATA(ud_idx).DATA;
      idx        = find(strncmp(name,{data.BlockName},length(name)));
      
      % Delete item and its children and data
      block_list.removeItem(selectedId);
      data(idx)  = [];
      USERDATA(ud_idx).DATA = data;
      param_list = USERDATA(ud_idx).GUI.PARAM_LIST;
      param_list.removeAllItems;

      % Set selection to next row which is now in same location
      block_list.select(selectedRow, 0);

      % Disable delete button if nothing was selected
      if (block_list.getFirstSelectedRow < 0)
	listDeleteButton = USERDATA(ud_idx).GUI.BLOCK_LIST_DELETE;
	listDeleteButton.setEnabled(0);
      end

      % Enable Apply button
      apply = USERDATA(ud_idx).GUI.APPLY_BUTTON;
      apply.setEnabled(1);
    end
    
 case 'GetUserData'
  varargout{1} = USERDATA;
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_PopulateViewer(gui, data, name)

import com.mathworks.mwt.table.LabeledImageResource;

% Set name of Frame
frame = gui.FRAME;
name = strrep(name, sprintf('\n'), ' ');
frame.setTitle(['Link changes: ' name])

% Fill data in treeview
fList = gui.BLOCK_LIST;
fList.getTreeData.removeChildren(-1); % Delete all existing items
imageLoc = '/com/mathworks/toolbox/simulink/finder/resources/block.gif';
for i = 1:length(data)
  [parents bName] = list_parents(data(i).BlockName);
  node = LabeledImageResource(imageLoc, bName);
  if isempty(parents)
    fList.addItem(-1, node, 0);
  else
    parentId = i_FindParentId(fList, -1, parents);
    fList.addItem(parentId, node, 0);
    fList.getTreeData.setBranch(parentId, 1);
  end
end

% Disable OK button if no data exists
if isempty(data) 
  okButton = gui.OK_BUTTON;
  okButton.setEnabled(0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fgui = i_CreateViewer

% Import java classes needed for the GUI
import java.awt.*;
import com.mathworks.mwt.*;
import com.mathworks.mwt.table.*;

% Create the Frame
fFrame = MWFrame;
fFrame.setLayout(BorderLayout);
fFrame.setBounds(200,200,500,300);
set(fFrame,'WindowClosingCallback', 'viewlinkdata Callback CloseWindow');

% Create Treeview of blocks in LinkData
fListPanel = MWGroupbox('Modifed blocks');
fListPanel.setLayout(BorderLayout);
fList      = MWTreeView;
% Add Delete button to bottom of this panel
fListButtonPanel = MWPanel;
fListButtonPanel.setInsets(Insets(0,0,0,0));
fListButtonPanel.setLayout(BorderLayout);
fListDeleteButton = MWButton('Remove changes in selected block');
fListDeleteButton.setEnabled(0);
set(fListDeleteButton,'ActionPerformedCallback','viewlinkdata Callback BlockListDelete');
fListButtonPanel.add(fListDeleteButton, java_field('java.awt.BorderLayout','CENTER'));

fListPanel.add(fList, java_field('java.awt.BorderLayout','CENTER'));
fListPanel.add(fListButtonPanel, java_field('java.awt.BorderLayout','SOUTH'));
set(fList,'ItemStateChangedCallback','viewlinkdata Callback BlockChanged');

% Create Listbox of parameter/value pairs
fParamPanel = MWGroupbox('Parameters of selected block');
fParamPanel.setLayout(BorderLayout);
fParam = MWListbox;
fParam.setColumnCount(2);
fParam.setColumnHeaderData(0, 'Parameter name');
fParam.setColumnWidth(0,120);
fParam.setColumnHeaderData(1, 'Value');
fParam.getColumnOptions.setHeaderVisible(1);
fParam.getTableStyle.setHGridVisible(1);
fParam.getTableStyle.setVGridVisible(1);
fParam.getColumnOptions.setResizable(1);
fParamPanel.add(fParam, java_field('java.awt.BorderLayout','CENTER')); 

% Setup column styles for the Parameter listbox
styleLoc = 'com.mathworks.mwt.table.Style';
% Parameter name column
col0Style = Style(java_field(styleLoc,'EDITABLE') + java_field(styleLoc,'BACKGROUND'));
col0Style.setEditable(0);
col0Style.setBackground(Color.lightGray);
fParam.setColumnStyle(0, col0Style);
% Parameter value column
col1Style = Style(java_field(styleLoc,'EDITABLE'));
col1Style.setEditable(0); % Not editable for now
fParam.setColumnStyle(1, col1Style);

% Create main Panel
fPanel = MWPanel;
fPanel.setLayout(GridLayout(1,2));
fPanel.setInsets(Insets(5,5,5,5));
fPanel.add(fListPanel);
fPanel.add(fParamPanel);

% Add button panel
fButtonPanel = MWPanel;
fButtonPanel.setLayout(FlowLayout(java_field('java.awt.FlowLayout','RIGHT')));
fOK     = MWButton('OK');
fCancel = MWButton('Cancel');
fApply  = MWButton('Apply');
fApply.setEnabled(0);
set(fOK    ,'ActionPerformedCallback','viewlinkdata Callback OK');
set(fCancel,'ActionPerformedCallback','viewlinkdata Callback Cancel');
set(fApply ,'ActionPerformedCallback','viewlinkdata Callback Apply');
fButtonPanel.add(fOK);
fButtonPanel.add(fCancel);
fButtonPanel.add(fApply);

% Show the frame
fFrame.add(fPanel, java_field('java.awt.BorderLayout','CENTER'));
fFrame.add(fButtonPanel, java_field('java.awt.BorderLayout','SOUTH'));

% Store values
fgui.FRAME         = fFrame;
fgui.BLOCK_LIST    = fList;
fgui.BLOCK_LIST_DELETE = fListDeleteButton;
fgui.PARAM_LIST    = fParam;
fgui.OK_BUTTON     = fOK;
fgui.CANCEL_BUTTON = fCancel;
fgui.APPLY_BUTTON  = fApply;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_SetViewerLocation(block, frame)

parent= get_param(block, 'Parent'); 

% Set the right location
location       = get_param(block, 'Position');
parentLocation = get_param(parent, 'Location');
screenSize     = get(0,'ScreenSize');

dims   = frame.getBounds;
width  = dims.width; 
height = dims.height;

xLoc = min(parentLocation(1) + location(3) + width, screenSize(3)) - width;
yLoc = min(parentLocation(2) + location(2) + height, screenSize(4)) - height;
frame.setLocation(max(xLoc,0), max(yLoc,0));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = java_field(className, fieldName)
% workaround until we can access constants of java classes
obj = javaObject(className);
s   = struct(obj);
out = getfield(s,fieldName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, bName] = list_parents(name)
% Returns a cell array of parents and the block name

single_slash = findstr(name, '/');
double_slash = findstr(name, '//');
ignore_slash = [double_slash double_slash+1];

idx = setdiff(single_slash, ignore_slash);
num = length(idx);
out = cell(num, 1);
idx = [0 idx];
for i = 1:num
  out{i} = name(idx(i)+1:idx(i+1)-1);
end
if (num==0)
  bName = name;
else
  bName = name(idx(end)+1:end);
end
out   = strrep(out, '//', '/');
bName = strrep(bName, '//', '/');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function idx = i_FindParentId(tree, id, strCell)

idx = -1;
for i = 1:length(strCell)
  id = locateItem(tree, id, strCell{i});
end
idx = id;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newId = locateItem(tree, id, str)

import com.mathworks.mwt.table.LabeledImageResource;

newId = -5; % a bogus value

children = tree.getChildren(id);
for i = 1:length(children)
  obj = tree.getItem(children(i));
  objStr = get(obj,'Label');
  if strcmp(objStr, str)
    newId = children(i);
    break;
  end
end

% Create one if it doesn't exist
if (newId == -5)
  imageLoc = '/com/mathworks/toolbox/simulink/finder/resources/block.gif';
  d = LabeledImageResource(imageLoc, str);
  newId = tree.addItem(id, d, 0);
  tree.getTreeData.setBranch(newId, 1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function name = i_getSelectedItemFullname(tree)

import com.mathworks.mwt.table.LabeledImageResource;

name = '';

selectedRow = tree.getFirstSelectedRow;
if (selectedRow < 0)
  return;
end

childId = tree.getItemId(selectedRow);
obj     = tree.getItem(childId);
name    = strrep(get(obj,'Label'),'/','//');

while (childId ~= -1)
  childId = tree.getTreeData.getParent(childId);
  if (childId ~= -1)
    obj  = tree.getItem(childId);
    name = [strrep(get(obj,'Label'),'/','//') '/' name];
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function idx = i_FindUserDataIndex(userdata, type, objectH)

idx = -1;

for i = 1:length(userdata)
  H = findobj(eval(['userdata(i).GUI.' type]));
  if isequal(H, objectH)
    idx = i;
    break;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function idx = i_FindBlockInUserData(userdata, blockH)

idx = -1;

for i = 1:length(userdata)
  if isequal(blockH, userdata(i).BLOCK)
    idx = i;
    break;
  end
end

