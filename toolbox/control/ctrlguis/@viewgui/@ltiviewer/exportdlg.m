function Frame = exportdlg(this)
%EXPORT  Open system-export GUI for LTI Viewer

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2004/04/10 23:14:39 $

import com.mathworks.mwt.*;
import java.awt.*;

if isempty(this.Systems)
    errordlg('No systems to export.','Export systems');
    Frame = [];
    return;
end
% GUI data structure
s = struct(...
    'MatFile','',...
    'ModelList',[],...
    'Preferences',cstprefs.tbxprefs,...
    'Table',[],...
    'Handles',[],...
    'Listeners',[],...
    'Parent',this);

% Frame
Frame = MWFrame(sprintf('LTI Viewer Export'));
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

%%%%%%%%%%%%%%%%%%%%%
%%% LocalEditCell %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalEditCell(hSrc,event,f)
% Edit export name
s = get(f,'UserData');
t = s.Table;
CBdata = get(t,'ValueChangedCallbackData'); % callback data
row = CBdata.row;
col = CBdata.column;

% Check if new name is a valid variable name
NewName = t.getCellData(row,col);
if isvarname(NewName)
    % Replace name in model list
    s.ModelList(row+1).ExportName = strrep(NewName,' ','');
    set(f,'UserData',s)
else
    % Revert to old name
    t.setCellData(row,col,CBdata.previousValue);
end
    
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
% Get new model list
NewModelList = LocalExportList(this.Systems);
% Update data
if ~isempty(s.ModelList)
    % Inherit export names for non modified components
    NewModelList = LocalInherit(NewModelList,s.ModelList);
end
s.ModelList = NewModelList;

% Adjust table size
t  = s.Table;
td = t.getData;
nrows   = t.getTableSize.height;
nmodels = size(s.ModelList,1);
if nmodels>nrows
    td.addRows(nrows,nmodels-nrows);
end

% Prepare display list
DisplayList      = cell(nmodels,4);
ModelIDs         = reshape({s.ModelList.ModelID},[nmodels 1]);
DisplayList(:,1) = reshape({s.ModelList.ModelName},[nmodels 1]);
DisplayList(:,2) = reshape({s.ModelList.Size},[nmodels 1]);
DisplayList(:,3) = reshape({s.ModelList.Class},[nmodels 1]);
DisplayList(:,4) = reshape({s.ModelList.ExportName},[nmodels 1]);

% Update table content
for ctcol=1:4,
    for ctrow=1:nmodels
        td.setData(ctrow-1,ctcol-1,DisplayList{ctrow,ctcol});
    end
    for ctrow=nmodels+1:t.getTableSize.height
        td.setData(ctrow-1,ctcol-1,'');
    end
end

% Store modified data
set(Frame,'UserData',s)

%%%%%%%%%%%%%%%%%%%
%%% LocalExport %%%
%%%%%%%%%%%%%%%%%%%
function LocalExport(hSrc,event,Frame,Target);
% Exports selected models

s = get(Frame,'UserData');
this = s.Parent;
if isempty(this.Systems)
    Frame.hide;
    errordlg('No systems to export.','Export systems');
    return;
end
ModelList = s.ModelList;

% Get selection
t = s.Table;
Selection = 1+double(t.getSelectedRows);
Selection(Selection>size(ModelList,1)) = [];  % ignore blank line selections
numSel = length(Selection);
if numSel==0
    warndlg('You have not specified which models to export.','Export Warning','modal');
    return
end

% Get export names and models
ModelInfo = cell(numSel,2);  % {ExportName ModelData}
ModelInfo(1:numSel,1) = {ModelList(Selection).ExportName}';
ModelInfo(1:numSel,2) = get(this.systems(Selection),{'Model'});

% Export
try
    switch Target
    case 'd'
        % Export to disk
        if ~isempty(s.MatFile)
            fname = s.MatFile; 
        else
            fname = sprintf('%s.mat','Untitled');
        end
        [fname,p] = uiputfile(fname,'Export to Disk');
        if ischar(fname),
            [fname,r] = strtok(fname,'.');
            fname = fullfile(p,[fname '.mat']);
            s.MatFile = fname;
            set(Frame,'UserData',s);
            Protected_File_Name = fname;
            for ct=1:numSel
                eval(sprintf('%s = ModelInfo{%d,2};',ModelInfo{ct,1},ct));
            end    
            save(Protected_File_Name,ModelInfo{:,1});
        end
        
    case 'w',
        %---Callback from the Export to Workspace button
        w = evalin('base','whos');
        VarNames = {w.name};
        % Ask for confirmation if workspace contains variables with the same names 
        if any(ismember(ModelInfo(:,1),VarNames)) & strcmpi(questdlg(...
                {'At least one of the variables you are exporting'
                'already exists in the workspace.'
                ' ';
                'Exporting will overwrite the existing variables.'
                ' '
                'Do you want to continue?'},...
                'Variable Name Conflict','Yes','No','No'),'no')
            % Abort
            return
        end
        for ct=1:numSel
            assignin('base',ModelInfo{ct,1},ModelInfo{ct,2});
        end
    end
    % Store modified data
    set(Frame,'UserData',s)
    Frame.hide;
catch
    errordlg(lasterr,'Export Error');
end

%--------------------------Utility Functions------------------------

%%%%%%%%%%%%%%%%%%%%
%%% LocalInherit %%%
%%%%%%%%%%%%%%%%%%%%
function NewList = LocalInherit(NewList,OldList)
% Inherits export names from old list when model name is the same
[junk,ia,ib] = intersect({NewList.ModelName},{OldList.ModelName});
for ct=1:length(ia)
    % Loop over components
    NewList(ia(ct)).ExportName = OldList(ib(ct)).ExportName;
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalExportList %%%
%%%%%%%%%%%%%%%%%%%%%%%
function ModelList = LocalExportList(Systems)
% Constructs systems list
if isempty(Systems)
    ModelList.ModelID     = '';
    ModelList.ModelName   = '';
    ModelList.Size        = '';
    ModelList.Class       = '';
    ModelList.ExportName  = '';
    return
end
nsave = length(Systems);
for ct = 1:nsave
    [size_str,class_str] = LocalCreateStr(Systems(ct).Model);
    ModelList(ct,1) = struct(...
        'ModelID', '$M',...
        'ModelName', Systems(ct).Name,...
        'Size',      size_str,...
        'Class',     class_str,...
        'ExportName',Systems(ct).Name);
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
Panel = MWGroupbox(sprintf(' Select Models to Export '));
Panel.setLayout(MWBorderLayout(0,5));
Panel.setFont(s.Preferences.JavaFontB);
Panel.setInsets(Insets(5,5,5,5));

% Table view
Table = MWTable(20,4);

Table.setPreferredTableSize(10,4);
Table.getTableStyle.setFont(s.Preferences.JavaFontP);
Table.getColumnOptions.setResizable(1);
Table.getHScrollbarOptions.setMode(-1);

Table.setColumnHeaderData(0,sprintf('Model'));
Table.setColumnHeaderData(1,sprintf('Size'));
Table.setColumnHeaderData(2,sprintf('Class'));
Table.setColumnHeaderData(3,sprintf('Export As'));

Table.setColumnWidth(0,105);
Table.setColumnWidth(1,40);
Table.setColumnWidth(2,40);
Table.setColumnWidth(3,100);

Cstyle = table.Style(table.Style.BACKGROUND);
Cstyle.setBackground(java.awt.Color(.94,.94,.94));
Table.setColumnStyle(0,Cstyle);

Cstyle = table.Style(table.Style.BACKGROUND);
Cstyle.setBackground(java.awt.Color(.94,.94,.94));
Table.setColumnStyle(1,Cstyle);

Cstyle = table.Style(table.Style.BACKGROUND);
Cstyle.setBackground(java.awt.Color(.94,.94,.94));
Table.setColumnStyle(2,Cstyle);

Cstyle = table.Style(table.Style.EDITABLE);
Cstyle.setEditable(1);
Table.setColumnStyle(3,Cstyle);
Table.setAutoExpandColumn(3);
Table.getRowOptions.setHeaderVisible(0);
Topt = Table.getSelectionOptions;
Topt.setMode(3);      % complex
Topt.setSelectBy(1);  % by row
set(Table,'ValueChangedCallback',{@LocalEditCell Frame})
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
B1 = MWButton(sprintf('  Export to Workspace  '));  
B1.setFont(s.Preferences.JavaFontP);
set(B1,'ActionPerformedCallback',{@LocalExport Frame 'w'})
B2 = MWButton(sprintf('Export to Disk ...'));       
B2.setFont(s.Preferences.JavaFontP);
set(B2,'ActionPerformedCallback',{@LocalExport Frame 'd'})
B3 = MWButton(sprintf('Cancel'));  
B3.setFont(s.Preferences.JavaFontP);
set(B3,'ActionPerformedCallback',{@LocalHide Frame})
B4 = MWButton(sprintf('Help'));       
B4.setFont(s.Preferences.JavaFontP);
set(B4,'ActionPerformedCallback','ctrlguihelp(''viewer_export'');')

% Connect components
Panel.add(BP1,MWBorderLayout.NORTH);
Panel.add(BP2,MWBorderLayout.SOUTH);
BP1.add(B1);
BP1.add(B2);
BP2.add(B3);
BP2.add(B4);

% Store handle for persistency
s.Handles = [s.Handles ; {Panel;BP1;BP2;B1;B2;B3;B4}];

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
