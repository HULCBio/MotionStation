function Frame = archivedlg(sisodb)
%ARCHIVEDLG  Opens and manages the Store/Retrieve Compensator dialog.

%   Author: Kamesh Subbarao
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/10 23:14:20 $

import com.mathworks.mwt.*;
import java.awt.*;

% GUI data structure
LoopData = sisodb.LoopData;
s = struct(...
   'RootObject',sisodb,...
   'Preferences',cstprefs.tbxprefs,...
   'Table',[],...
   'Handles',[],...
   'Listeners',[]);

% Frame
Frame = MWFrame(sprintf('Compensator Design Archive'));
set(Frame,'HandleVisibility','off');

% Main panel
MainPanel = MWPanel(MWBorderLayout(5,0));
MainPanel.setInsets(Insets(12,5,5,3));
Frame.add(MainPanel,MWBorderLayout.CENTER);
s.Handles = {MainPanel};

% Add StorePanel, list and botton panels
[StorePanel,  s] = LocalAddPanel(Frame,s,sisodb);
[ListPanel,   s] = LocalAddList(Frame,s,sisodb);
[OptionsPanel,s] = LocalAddOptions(Frame,s,sisodb);
[ButtonPanel, s] = LocalAddButton(Frame,s,sisodb);

MainPanel.add(ButtonPanel   ,MWBorderLayout.EAST);
MainPanel.add(StorePanel    ,MWBorderLayout.NORTH);
MainPanel.add(ListPanel     ,MWBorderLayout.CENTER);
MainPanel.add(OptionsPanel  ,MWBorderLayout.SOUTH);

% Layout
Frame.pack;
centerfig(Frame,sisodb.Figure);

% Install listeners
lsnr(1) = handle.listener(LoopData,...
   'ObjectBeingDestroyed',{@LocalClose Frame});
lsnr(2) = handle.listener(LoopData,findprop(LoopData,'SavedDesigns'),...
   'PropertyPostSet',{@LocalRefresh Frame});
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


%-------------------------- Callback Functions ------------------------

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
function LocalRefresh(hSrc,event,Frame)
% Refresh tree view (list of model names)
s = get(Frame,'UserData');
sisodb = s.RootObject;
if ishandle(sisodb) & ishandle(sisodb.LoopData)
   % Protect against race condition when SISO Tool is closed
   SavedDesigns = sisodb.LoopData.SavedDesigns;
   
   % Adjust table size
   t = s.Table;
   td = t.getData;
   nrows = t.getTableSize.height;
   ndesigns = length(SavedDesigns);
   if ndesigns>nrows
      td.addRows(nrows,ndesigns-nrows);
   end
   
   % Update table content
   for ctrow=1:ndesigns
      Design = SavedDesigns(ctrow);
      td.setData(ctrow-1,0,Design.Name);
      td.setData(ctrow-1,1,sprintf('%d, %d',...
         size(Design.Compensator.Model,'order'),size(Design.Filter.Model,'order')));
      td.setData(ctrow-1,2,sprintf('%.3g',abs(get(Design.Compensator.Model,'Ts'))));
   end
   for ctrow=ndesigns+1:t.getTableSize.height
      for ctcol=1:3,
         td.setData(ctrow-1,ctcol-1,'');
      end
   end
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalRetrieve %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalRetrieve(hSrc,event,Frame);
% Exports selected models
s = get(Frame,'UserData');
sisodb = s.RootObject;

% Get selection
t = s.Table;
Selection = 1+double(t.getSelectedRows);
if isempty(t.getSelectedRows) | Selection>length(sisodb.LoopData.SavedDesigns)
   warndlg('You have not specified which design to retrieve.','Retrieve Warning','modal');
   return
end

% Record transaction
EventMgr = sisodb.EventManager;
T = ctrluis.transaction(sisodb.LoopData,'Name','Retrieve Compensator',...
   'OperationStore','on','InverseOperationStore','on');

try
   % Get States of the CheckBoxes and Retrieve appropriate Models
   InputList = find([strcmpi(get(s.CheckBoxG,'State'),'on') strcmpi(get(s.CheckBoxH,'State'),'on') ...
         strcmpi(get(s.CheckBoxF,'State'),'on') strcmpi(get(s.CheckBoxC,'State'),'on')] == 1);
   sisodb.LoopData.retrieve(Selection,InputList);
  % Commit transaction
   EventMgr.record(T);
   sisodb.LoopData.dataevent('all');
   % Update status bar and history
   Status = 'Retrieved requested compensator design.';
   EventMgr.newstatus(Status);
   EventMgr.recordtxt('history',Status);
catch
   warndlg(' You cannot mix Sample Times while retrieving models. ','Retrieve Warning','modal');
end
   

%%%%%%%%%%%%%%%%%%%
%%% LocalDelete %%%
%%%%%%%%%%%%%%%%%%%
function LocalDelete(hSrc,event,Frame);
% Exports selected models
s = get(Frame,'UserData');
sisodb = s.RootObject;
SavedDesigns = sisodb.LoopData.SavedDesigns;

% Get selection
t = s.Table;
Selection = 1+double(t.getSelectedRows);
if isempty(t.getSelectedRows) | Selection>length(SavedDesigns)
   warndlg('You have not specified which design to delete.','Delete Warning','modal');
   return
end

% Start transaction
EventMgr = sisodb.EventManager;
T = ctrluis.transaction(sisodb.LoopData,'Name','Delete Design',...
   'OperationStore','on','InverseOperationStore','on');

% Update design history
DeletedName = SavedDesigns(Selection).Name;
SavedDesigns(Selection,:) = [];
sisodb.LoopData.SavedDesigns = SavedDesigns;

% Record transaction
EventMgr.record(T);

% Update status bar and history
Status = sprintf('Discarded "%s" from compensator design list.',DeletedName);
EventMgr.newstatus(Status);
EventMgr.recordtxt('history',Status);


%%%%%%%%%%%%%%%%%%%
%%% LocalRename %%%
%%%%%%%%%%%%%%%%%%%
function LocalRename(hSrc,event,f)
% Rename compensator
s = get(f,'UserData');
sisodb = s.RootObject;
SavedDesigns = sisodb.LoopData.SavedDesigns;

% Get rename info
t = s.Table;
CBdata = get(t,'ValueChangedCallbackData'); % callback data
row = CBdata.row;
col = CBdata.column;

% Check if new name is a valid variable name
NewName = t.getCellData(row,col);
if row<length(SavedDesigns) & isvarname(NewName) & ...
      ~any(strcmp(NewName,{SavedDesigns([1:row,row+2:end]).Name}))
   % Update name
   EventMgr = sisodb.EventManager;
   T = ctrluis.transaction(sisodb.LoopData,'Name','Rename Design',...
      'OperationStore','on','InverseOperationStore','on');
   
   % Update design history
   SavedDesigns(row+1).Name = NewName;
   SavedDesigns(row+1).Compensator.Name = NewName;
   sisodb.LoopData.SavedDesigns = SavedDesigns;
   
   % Commit and register transaction
   EventMgr.record(T);
   
   % Update status bar and history
   Status = sprintf('Renamed compensator "%s" to "%s."',...
      char(CBdata.previousValue),NewName);
   EventMgr.newstatus(Status);
   EventMgr.recordtxt('history',Status);
else
   % Revert to old name
   t.setCellData(row,col,CBdata.previousValue);
end

%%%%%%%%%%%%%%%%%%%%%  BEGIN STORE PART OF DIALOG  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalStorePanel %%%
%%%%%%%%%%%%%%%%%%%%%%%
function [StorePanel,s] = LocalAddPanel(Frame,s,sisodb)
% Manages the STORE AS dialog.
% Adds Store panel
import com.mathworks.mwt.*;
import java.awt.*;

% Main panel
StorePanel = MWPanel(MWBorderLayout(0,5));
StorePanel.setInsets(Insets(5,5,5,8));

% Get Default Name
DefaultName = LocalDefault(sisodb.LoopData);

LabelStore = MWLabel(sprintf('Store Compensator Design as'));      % Label to the Store design
LabelStore.setFont(s.Preferences.JavaFontP);

% TextField view
TextField  = MWTextField(DefaultName,32);
TextField.setFont(s.Preferences.JavaFontP);

StoreButton = MWButton(sprintf('  Store  '));  
StoreButton.setFont(s.Preferences.JavaFontP);
set(StoreButton,'ActionPerformedCallback',{@LocalStore Frame})

% Storing handles
s.LabelStore = LabelStore;
s.TextField  = TextField;

% Connect components
StorePanel.add(LabelStore  ,MWBorderLayout.NORTH);
StorePanel.add(TextField   ,MWBorderLayout.WEST);
StorePanel.add(StoreButton ,MWBorderLayout.EAST);

% Store handle for persistency
s.Handles = [s.Handles ; {StorePanel; StoreButton}];

%--------------------------Local Functions------------------------

%%%%%%%%%%%%%%%%%%
%%% LocalStore %%%
%%%%%%%%%%%%%%%%%%
function LocalStore(hSrc,event,Frame)
% Store operation 

FT = get(Frame,'UserData');
sisodb = FT.RootObject; 
StoreAsName = get(FT.TextField,'Text');
Designs = sisodb.LoopData.SavedDesigns;
if ~isvarname(StoreAsName)
   warndlg('You have not specified a valid name.','Store Warning','modal');
elseif ~any(strcmp(StoreAsName,{Designs.Name})) | ...
      strcmpi(questdlg({'There is already a compensator design with the same name.';...
         'Do you want to overwrite it?'}, ...
      'Store Warning', ...
      'Yes','No','Cancel','Cancel'),'Yes')
   
   % Record transaction
   EventMgr = sisodb.EventManager;
   T = ctrluis.transaction(sisodb.LoopData,'Name','Store Compensator',...
      'OperationStore','on','InverseOperationStore','on');
   
   % Store compensator
   sisodb.LoopData.store(StoreAsName);
   set(FT.TextField,'Text',LocalDefault(sisodb.LoopData));
   
   % Commit transaction
   EventMgr.record(T);
   sisodb.LoopData.dataevent('all');
   
   % Update status bar and history
   Status = sprintf('Stored current compensator design as %s.',StoreAsName);
   EventMgr.newstatus(Status);
   EventMgr.recordtxt('history',Status);
end

%%%%%%%%%%%%%%%%%%%%
%%% LocalDefault %%%
%%%%%%%%%%%%%%%%%%%%
function DefaultName = LocalDefault(LoopData)
% Gets default compensator name

DesignName = LoopData.SystemName;
Designs = LoopData.SavedDesigns;
UsedNames = {Designs.Name};
% Remove _xxx termination
UnderScores = findstr(DesignName,'_');
if ~isempty(UnderScores) & ~isnan(str2double(DesignName(UnderScores(end)+1:end)))
   DesignName = DesignName(1:UnderScores(end)-1);
end
% Find first available termination
term = 1;
nchar = length(DesignName)+1;
stcomp = strncmpi([DesignName '_'],UsedNames,nchar);
if ~isempty(stcomp),
    for ct = find(stcomp),
        tail = str2double(UsedNames{ct}(nchar+1:end));
        if ~isnan(tail)
            term = max(term,tail)+1;
        end
    end
end
DefaultName = sprintf('%s_%d',DesignName,term);
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END STORE PART OF DIALOG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%--------------------------Rendering Functions for Retrieve Dialog ------------------------
%%%%%%%%%%%%%%%%%%%%
%%% LocalAddList %%%
%%%%%%%%%%%%%%%%%%%%
function [Panel,s] = LocalAddList(Frame,s,sisodb)
% Adds Export List panel
import com.mathworks.mwt.*;
import java.awt.*;
import javax.swing.*;

% Main panel
Panel = MWPanel(MWBorderLayout(0,5));
Panel.setInsets(Insets(5,5,5,5));

% Table view
Table = MWTable(20,3);
Table.setPreferredTableSize(10,4);
Table.getTableStyle.setFont(s.Preferences.JavaFontP);
Table.getColumnOptions.setResizable(1);
Table.getHScrollbarOptions.setMode(-1);
Table.setColumnHeaderData(0,sprintf('Design Name'));
Table.setColumnHeaderData(1,sprintf('Orders of C,F'));
Table.setColumnHeaderData(2,sprintf('Sample Time'));
Table.setColumnWidth(0,100);
Table.setColumnWidth(1,80);
Table.setColumnWidth(2,80);
Cstyle = table.Style(table.Style.EDITABLE);
Cstyle.setEditable(1);
Table.setColumnStyle(0,Cstyle);
Cstyle = table.Style(table.Style.BACKGROUND);
Cstyle.setBackground(java.awt.Color(.94,.94,.94));
Table.setColumnStyle(1,Cstyle);
Cstyle = table.Style(table.Style.BACKGROUND);
Cstyle.setBackground(java.awt.Color(.94,.94,.94));
Table.setColumnStyle(2,Cstyle);
Table.setAutoExpandColumn(0);
Table.getRowOptions.setHeaderVisible(0);
Topt = Table.getSelectionOptions;
Topt.setMode(1);      % single
Topt.setSelectBy(1);  % by row
set(Table,'ValueChangedCallback',{@LocalRename Frame})

% Label to Retrieve Design
LabelRetrieve = MWLabel(sprintf('Stored Compensator Designs '));      % Label to the Retrieve design
LabelRetrieve.setFont(s.Preferences.JavaFontP);

s.LabelRetrieve = LabelRetrieve;
s.Table = Table;

% Connect components
Panel.add(LabelRetrieve,MWBorderLayout.NORTH);
Panel.add(Table,MWBorderLayout.CENTER);

% Store handle for persistency
s.Handles = [s.Handles ; {Panel}];


%%%%%%%%%%%%%%%%%%%%%%
%%% LocalAddButton %%%
%%%%%%%%%%%%%%%%%%%%%%
function [Panel,s] = LocalAddButton(Frame,s,sisodb)
% Adds control buttons
import com.mathworks.mwt.*;
import java.awt.*;

% Main panel
Panel = MWPanel(MWBorderLayout);
Panel.setInsets(Insets(25,5,25,8));

% Button panel
GL = GridLayout(2,1,0,5);
BP1 = MWPanel(GL);
BP2 = MWPanel(GL);

% Buttons
B1 = MWButton(sprintf('  Retrieve  '));  
B1.setFont(s.Preferences.JavaFontP);
set(B1,'ActionPerformedCallback',{@LocalRetrieve Frame})
B2 = MWButton(sprintf('Delete'));  
B2.setFont(s.Preferences.JavaFontP);
set(B2,'ActionPerformedCallback',{@LocalDelete Frame})
B3 = MWButton(sprintf('Help'));       
B3.setFont(s.Preferences.JavaFontP);
set(B3,'ActionPerformedCallback','ctrlguihelp(''sisoretrievedialog'');')
B4 = MWButton(sprintf('Close'));  
B4.setFont(s.Preferences.JavaFontP);
set(B4,'ActionPerformedCallback',{@LocalHide Frame})

% Connect components
Panel.add(BP1,MWBorderLayout.NORTH);
Panel.add(BP2,MWBorderLayout.SOUTH);
BP1.add(B1);
BP1.add(B2);
BP2.add(B3);
BP2.add(B4);

% Store handle for persistency
s.Handles = [s.Handles ; {Panel;BP1;BP2;B1;B2;B3;B4}];


% Adding CheckBoxes for Retrieve Options
%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalOptionsPanel %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function [MainOpt,s] = LocalAddOptions(Frame,s,sisodb)
% Manages the the Retrieve Options.

import com.mathworks.mwt.*;
import java.awt.*;

% Main panel
MainOpt = MWPanel(MWBorderLayout(0,5));
GL = GridLayout(2,5,1,0);
OptionsPanel = MWPanel(GL);
MainOpt.setInsets(Insets(5,5,5,8));

% TextField view
LabelRetrieve1 = MWLabel(sprintf('Models to retrieve : '));      
LabelRetrieve1.setFont(s.Preferences.JavaFontP);
CheckBoxG  = MWCheckbox(xlate('G  (Plant)'));           set(CheckBoxG,'State','on'); CheckBoxG.setFont(s.Preferences.JavaFontP);
CheckBoxH  = MWCheckbox(xlate('H  (Sensor)'));          set(CheckBoxH,'State','on'); CheckBoxH.setFont(s.Preferences.JavaFontP);
CheckBoxC  = MWCheckbox(xlate('C  (Compensator)'));     set(CheckBoxC,'State','on'); CheckBoxC.setFont(s.Preferences.JavaFontP);
CheckBoxF  = MWCheckbox(xlate('F  (Filter)'));          set(CheckBoxF,'State','on'); CheckBoxF.setFont(s.Preferences.JavaFontP);
%
% Storing handles
s.LabelRetrieve1     = LabelRetrieve1;
s.CheckBoxG          = CheckBoxG;
s.CheckBoxH          = CheckBoxH;
s.CheckBoxC          = CheckBoxC;
s.CheckBoxF          = CheckBoxF;

% Connect components
MainOpt.add(LabelRetrieve1,MWBorderLayout.NORTH);
OptionsPanel.add(CheckBoxG);
OptionsPanel.add(CheckBoxH);
OptionsPanel.add(CheckBoxC);
OptionsPanel.add(CheckBoxF);
MainOpt.add(OptionsPanel,MWBorderLayout.CENTER);

s.OptionsPanel       = OptionsPanel;

% Store handle for persistency
s.Handles = [s.Handles ; {MainOpt;CheckBoxG;CheckBoxH;CheckBoxC;CheckBoxF}];
