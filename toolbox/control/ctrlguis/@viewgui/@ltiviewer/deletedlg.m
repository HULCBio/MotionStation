function Frame = deletedlg(this)
%DELETEDLG   Opens dialog for deleting systems from the LTI Viewer.

%   Author: Kamesh Subbarao
%   Copyright 1986-2003 The MathWorks, Inc.

%   $Revision: 1.12.4.3 $  $Date: 2004/04/10 23:14:38 $
import com.mathworks.mwt.*;
import java.awt.*;

if isempty(this.Systems)
    errordlg('No systems to delete.','Delete systems');
    Frame = [];
    return;
end

% GUI data structure
s = struct(...
    'Parent',this,...
    'ModelList',[],...
    'Preferences',cstprefs.tbxprefs,...
    'Table',[],...
    'Handles',[],...
    'Listeners',[]);

% Frame
Frame = MWFrame(sprintf('LTI Viewer Delete'));
set(Frame,'HandleVisibility','off');

% Main panel
MainPanel = MWPanel(MWBorderLayout(5,0));
MainPanel.setInsets(Insets(12,5,5,3));
Frame.add(MainPanel,MWBorderLayout.CENTER);
s.Handles = {MainPanel};

% Add list and botton panels
[ListPanel,s] = LocalAddList(Frame,s);
[ButtonPanel,s] = LocalAddButton(Frame,s);
MainPanel.add(ListPanel,MWBorderLayout.CENTER);
MainPanel.add(ButtonPanel,MWBorderLayout.EAST);

% Layout
Frame.pack;

% Center wrt SISO Tool window
centerfig(Frame,this.Figure);

% Install listeners
lsnr(1) = handle.listener(this,...
    'ObjectBeingDestroyed',{@LocalClose Frame});
lsnr(2) = handle.listener(this,findprop(this,'Systems'),...
    'PropertyPostSet',{@LocalRefresh Frame,this});
s.Listeners = lsnr;

% Set callbacks and store handles 
set(Frame,...
    'WindowClosingCallback',{@LocalHide Frame},...
    'WindowActivatedCallback',{@LocalRefresh Frame,this},...
    'UserData',s);
LocalRefresh([],[],Frame,this);  % populate to limit flashing

% Make frame visible
Frame.show;
Frame.toFront;

%--------------------------Callback Functions------------------------

%%%%%%%%%%%%%%%%%
%%% LocalHide %%%
%%%%%%%%%%%%%%%%%
function LocalHide(hSrc,event,f)
% Hide dialog
f.hide;

%%%%%%%%%%%%%%%%%%
%%% LocalClose %%%
%%%%%%%%%%%%%%%%%%
function LocalClose(hSrc,event,f)
% Hide dialog
f.hide;
f.dispose;

%%%%%%%%%%%%%%%%%%%%
%%% LocalRefresh %%%
%%%%%%%%%%%%%%%%%%%%
function LocalRefresh(hSrc,event,Frame,this)
% Refresh export list
s = get(Frame,'UserData');
% If this Frame is not visible then dont do anything    
% Protect against race condition when Viewer is closed
if ~isa(s.Parent,'viewgui.viewer') |  strcmp(get(Frame,'Visible'),'off')
    return
end
% Refresh delete list
s.ModelList = LocalSystemList(this.Systems);

% Adjust table size
t  = s.Table;
td = t.getData;
nrows   = t.getTableSize.height;
nmodels = size(s.ModelList,1);
if nmodels>nrows
    td.addRows(nrows,nmodels-nrows);
end

% Prepare display list
DisplayList      = cell(nmodels,3);
DisplayList(:,1) = reshape({s.ModelList.ModelName},[nmodels 1]);
DisplayList(:,2) = reshape({s.ModelList.Size},[nmodels 1]);
DisplayList(:,3) = reshape({s.ModelList.Class},[nmodels 1]);

% Update table content
for ctcol=1:3,
    for ctrow=1:nmodels
        td.setData(ctrow-1,ctcol-1,DisplayList{ctrow,ctcol});
    end
    for ctrow=nmodels+1:t.getTableSize.height
        td.setData(ctrow-1,ctcol-1,'');
    end
end

% Store modified data
set(Frame,'UserData',s);

%%%%%%%%%%%%%%%%%%%
%%% LocalDelete %%%
%%%%%%%%%%%%%%%%%%%
function LocalDelete(hSrc,event,Frame);
% Deletes selected models

s = get(Frame,'UserData');
this      = s.Parent;
if isempty(this.Systems)
    Frame.hide;
    errordlg('No systems to delete.','Delete systems');
    return;
end
ModelList = s.ModelList;

% Get selection
t = s.Table;
Selection = 1+double(t.getSelectedRows);
Selection(Selection>size(ModelList,1)) = [];  % ignore blank line selections
numSel = length(Selection);
if numSel==0
    warndlg('You have not specified which models to delete.','Delete Warning','modal');
    return
end

% Get delete names and models
ModelInfo = cell(numSel,1);  % {Delete Name}
ModelInfo(1:numSel,1) = get(this.Systems(Selection),{'Name'});

% Delete
try
    % Delete from Viewer
    this.deletesys(ModelInfo);
    % Store modified data
    set(Frame,'UserData',s);
    Frame.hide;
catch
    errordlg(lasterr,'Delete Error');
end

%--------------------------Utility Functions------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSystemList %%%
%%%%%%%%%%%%%%%%%%%%%%%
function ModelList = LocalSystemList(Systems)
% Constructs systems list
if isempty(Systems)
    ModelList.ModelName = '';
    ModelList.Size      = '';
    ModelList.Class     = '';
    return
end
nsave = length(Systems);
for ct = 1:nsave
    [size_str,class_str] = LocalCreateStr(Systems(ct).Model);
    ModelList(ct,1) = struct(...
        'ModelName', Systems(ct).Name,...
        'Size',      size_str,...
        'Class',     class_str);
end

%--------------------------Rendering Functions------------------------

%%%%%%%%%%%%%%%%%%%%
%%% LocalAddList %%%
%%%%%%%%%%%%%%%%%%%%
function [Panel,s] = LocalAddList(Frame,s)
% Adds Export List panel
import com.mathworks.mwt.*;
import java.awt.*;

% Main panel
Panel = MWGroupbox(sprintf(' Select Models to Delete '));
Panel.setLayout(MWBorderLayout(0,5));
Panel.setFont(s.Preferences.JavaFontB);
Panel.setInsets(Insets(5,5,5,5));

% Table view
Table = MWTable(20,3);

Table.setPreferredTableSize(10,4);
Table.getTableStyle.setFont(s.Preferences.JavaFontP);
Table.getColumnOptions.setResizable(1);
Table.getHScrollbarOptions.setMode(-1);

Table.setColumnHeaderData(0,sprintf('Model'));
Table.setColumnHeaderData(1,sprintf('Size'));
Table.setColumnHeaderData(2,sprintf('Class'));

Table.setColumnWidth(0,105);
Table.setColumnWidth(1,75);
Table.setColumnWidth(2,75);

Cstyle = table.Style(table.Style.BACKGROUND);
Cstyle.setBackground(java.awt.Color(.94,.94,.94));
Table.setColumnStyle(0,Cstyle);

Cstyle = table.Style(table.Style.BACKGROUND);
Cstyle.setBackground(java.awt.Color(.94,.94,.94));
Table.setColumnStyle(1,Cstyle);

Cstyle = table.Style(table.Style.BACKGROUND);
Cstyle.setBackground(java.awt.Color(.94,.94,.94));
Table.setColumnStyle(2,Cstyle);
Table.setAutoExpandColumn(2);

Table.getRowOptions.setHeaderVisible(0);
Topt = Table.getSelectionOptions;
Topt.setMode(3);      % complex
Topt.setSelectBy(1);  % by row
s.Table = Table;

% Connect components
Panel.add(Table,MWBorderLayout.CENTER);

% Store handle for persistency
s.Handles = [s.Handles ; {Panel}];


%%%%%%%%%%%%%%%%%%%%%%
%%% LocalAddButton %%%
%%%%%%%%%%%%%%%%%%%%%%
function [Panel,s] = LocalAddButton(Frame,s)
% Adds control buttons
import com.mathworks.mwt.*;
import java.awt.*;

% Main panel
Panel = MWPanel(MWBorderLayout);
Panel.setInsets(Insets(25,5,25,5)); % top,left,bottom,right

% Button panel
GL = GridLayout(2,1,0,5);
BP1 = MWPanel(GL);
BP2 = MWPanel(GL);

% Buttons
B1 = MWButton(sprintf('  Delete  '));  
B1.setFont(s.Preferences.JavaFontP);
set(B1,'ActionPerformedCallback',{@LocalDelete Frame })

B2 = MWButton(sprintf('Cancel'));  
B2.setFont(s.Preferences.JavaFontP);
set(B2,'ActionPerformedCallback',{@LocalHide Frame})

B3 = MWButton(sprintf('Help'));       
B3.setFont(s.Preferences.JavaFontP);
set(B3,'ActionPerformedCallback','ctrlguihelp(''viewer_delete'');')

% Connect components
Panel.add(BP1,MWBorderLayout.NORTH);
Panel.add(BP2,MWBorderLayout.SOUTH);
BP1.add(B1);
BP2.add(B2);
BP2.add(B3);

% Store handle for persistency
s.Handles = [s.Handles ; {Panel;BP1;BP2;B1;B2;B3}];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCALCREATESIZESTR creates the size string for display in the table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [size_str,VarClass] = LocalCreateStr(WorkspaceVars)
% 
VarClass=class(WorkspaceVars);
wsize = size(WorkspaceVars);
if any(strcmpi(VarClass,{'ss';'tf';'zpk';'frd'}))
    if isequal(length(wsize),2)
        s = mat2str(wsize);
        s = strrep(s,' ','x');
        size_str = s(2:end-1);
    else
        size_str = [num2str(length(wsize)),'-D'];
    end
elseif any(strcmpi(VarClass,{'idpoly';'idss';'idarx'}))
    if isequal(wsize([1 2 4]),[1 1 1])
        s = mat2str(wsize([1 2]));
        s = strrep(s,' ','x');
        size_str = s(2:end-1);
    else
        size_str = '4-D';
    end
end
