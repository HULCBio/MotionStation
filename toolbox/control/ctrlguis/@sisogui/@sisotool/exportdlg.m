function Frame = exportdlg(sisodb)
%EXPORTDLG  Opens and manages the export dialog.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.25.4.2 $  $Date: 2004/04/10 23:14:26 $

import com.mathworks.mwt.*;
import java.awt.*;

% GUI data structure
s = struct(...
    'LoopData',sisodb.LoopData,...
    'MatFile','',...
    'ModelList',[],...
    'Preferences',cstprefs.tbxprefs,...
    'Table',[],...
    'Handles',[],...
    'Listeners',[]);

% Frame
Frame = MWFrame(sprintf('SISO Tool Export'));
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
centerfig(Frame,sisodb.Figure);

% Install listeners
lsnr(1) = handle.listener(s.LoopData,...
    'ObjectBeingDestroyed',{@LocalClose Frame});
s.Listeners = lsnr;

% Set callbacks and store handles 
set(Frame,...
    'WindowClosingCallback',{@LocalHide Frame},...
    'WindowActivatedCallback',{@LocalRefresh Frame},...
    'UserData',s);
LocalRefresh([],[],Frame);  % populate to limit flashing

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
function LocalRefresh(hSrc,event,Frame)
% Refresh export list
s = get(Frame,'UserData');
if ~isa(s.LoopData,'sisodata.loopdata')
    % Protect against race condition when SISO Tool is closed
    return
end

% Get new model list
NewModelList = LocalExportList(s.LoopData);

% Update data
if isequal(s.ModelList,NewModelList)
    % No change: skip table update
    return
elseif ~isempty(s.ModelList)
    % Inherit export names for non modified components
    NewModelList = LocalInherit(NewModelList,s.ModelList);
end
s.ModelList = NewModelList;

% Adjust table size
t = s.Table;
td = t.getData;
nrows = t.getTableSize.height;
nmodels = size(NewModelList,1);
if nmodels>nrows
    td.addRows(nrows,nmodels-nrows);
end

% Prepare display list
DisplayList = cell(nmodels,3);
ModelIDs = reshape({NewModelList.ModelID},[nmodels 1]);
DisplayList(:,2) = reshape({NewModelList.ModelName},[nmodels 1]);
DisplayList(:,3) = reshape({NewModelList.ExportName},[nmodels 1]);
iCurrent = find(ismember(ModelIDs,{'$G';'$H';'$F';'$C'}));
DisplayList(iCurrent,1) = {'Plant G';'Sensor H';'Filter F';'Compensator C'};
DisplayList(iCurrent,2) = {'(current)'};
iHeader = find(ismember(ModelIDs,{'$L';'$T_r2y';'$S_output';'$S_input'}));
DisplayList(iHeader,1) = {'Open Loop';'Closed Loop';...
        '   (output sensitivity)';'   (input sensitivity)'};

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
set(Frame,'UserData',s)


%%%%%%%%%%%%%%%%%%%
%%% LocalExport %%%
%%%%%%%%%%%%%%%%%%%
function LocalExport(hSrc,event,Frame,Target);
% Exports selected models
s = get(Frame,'UserData');
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
ModelInfo(:,1) = {ModelList(Selection).ExportName}';
ModelInfo(:,2) = exportdata(s.LoopData,{ModelList(Selection).ModelID});

% Export
try
    switch Target
    case 'd'
        % Export to disk
        if ~isempty(s.MatFile)
            fname = s.MatFile; 
        else
            fname = sprintf('%s.mat',s.LoopData.SystemName);
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
function ModelList = LocalExportList(LoopData)
% Constructs export list

% Categories:
%  1: Plant  2: Sensor  3: Filter  4: Compensator
%  5: Open loop   6: Closed loop

SavedDesigns = LoopData.SavedDesigns;
nsave = length(SavedDesigns);

% Plants, sensors, prefilters
PlantList = struct(...
    'Category',1,...
    'ModelID','$G',...
    'ModelName',LoopData.Plant.Name,...
    'ExportName',strrep(LoopData.Plant.Name,'untitled',''));
SensorList = struct(...
    'Category',2,...
    'ModelID','$H',...
    'ModelName',LoopData.Sensor.Name,...
    'ExportName',strrep(LoopData.Sensor.Name,'untitled',''));

% F compensators
CurrentF = struct(...
    'Category',3,...
    'ModelID','$F',...
    'ModelName',LoopData.Filter.Name,...
    'ExportName',strrep(LoopData.Filter.Name,'untitled',''));
SavedNames = cell(nsave,1);
for ct=1:nsave
	SavedNames{ct} = SavedDesigns(ct).Filter.Name;
end
SavedF = struct(...
    'Category',3,...
    'ModelID',SavedNames,...
    'ModelName',SavedNames,...
    'ExportName',SavedNames);

% C compensators
CurrentC = struct(...
    'Category',4,...
    'ModelID','$C',...
    'ModelName',LoopData.Compensator.Name,...
    'ExportName',strrep(LoopData.Compensator.Name,'untitled',''));
SavedNames = cell(nsave,1);
for ct=1:nsave
	SavedNames{ct} = SavedDesigns(ct).Compensator.Name;
end
SavedC = struct(...
    'Category',4,...
    'ModelID',SavedNames,...
    'ModelName',SavedNames,...
    'ExportName',SavedNames);

% Open loop
oList = struct(...
    'Category',5,...
    'ModelID','$L',...
    'ModelName','CGH',...
    'ExportName','L');

% Closed loop
switch LoopData.Configuration
case 1 % filter and compensator in forward path
    clNames = {'FCG/(1+CGH)';'FC/(1+CGH)';'1/(1+CGH)';'G/(1+CGH)';'State Space'};
case 2 % filter in forward, compensator in feedback path
    clNames = {'FG/(1+CGH)';'F/(1+CGH)';'1/(1+CGH)';'G/(1+CGH)';'State Space'};
case 3 % feedforward filter
    clNames = {'G(F+C)/(1+CGH)';'(F+C)/(1+CGH)';'1/(1+CGH)';'G/(1+CGH)';'State Space'};
case 4 % feedback filter
    oList.ModelName = 'GH/(1-GHF)';
    clNames = {'CG/(1+(C-F)GH)';'C/(1+(C-F)GH)';'1/(1+(C-F)GH)';'G/(1+(C-F)GH)';'State Space'};    
end
cList = struct(...
    'Category',6,...
    'ModelID',{'$T_r2y';'$T_r2u';'$S_output';'$S_input';'$Tcl'},...
    'ModelName',clNames,...
    'ExportName',{'T_r2y';'T_r2u';'S_out';'S_in';'T'});

% Full list
ModelList = cat(1,PlantList,SensorList,...
    CurrentF,SavedF,CurrentC,SavedC,oList,cList);


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
Table = MWTable(20,3);
Table.setPreferredTableSize(10,4);
Table.getTableStyle.setFont(s.Preferences.JavaFontP);
Table.getColumnOptions.setResizable(1);
Table.getHScrollbarOptions.setMode(-1);
Table.setColumnHeaderData(0,sprintf('Component'));
Table.setColumnHeaderData(1,sprintf('Model'));
Table.setColumnHeaderData(2,sprintf('Export As'));
Table.setColumnWidth(0,105);
Table.setColumnWidth(1,85);
Table.setColumnWidth(2,100);
Cstyle = table.Style(table.Style.BACKGROUND);
Cstyle.setBackground(java.awt.Color(.94,.94,.94));
Table.setColumnStyle(0,Cstyle);
Cstyle = table.Style(table.Style.BACKGROUND);
Cstyle.setBackground(java.awt.Color(.94,.94,.94));
Table.setColumnStyle(1,Cstyle);
Cstyle = table.Style(table.Style.EDITABLE);
Cstyle.setEditable(1);
Table.setColumnStyle(2,Cstyle);
Table.setAutoExpandColumn(2);
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
set(B4,'ActionPerformedCallback','ctrlguihelp(''sisoexportdialog'');')

% Connect components
Panel.add(BP1,MWBorderLayout.NORTH);
Panel.add(BP2,MWBorderLayout.SOUTH);
BP1.add(B1);
BP1.add(B2);
BP2.add(B3);
BP2.add(B4);

% Store handle for persistency
s.Handles = [s.Handles ; {Panel;BP1;BP2;B1;B2;B3;B4}];


