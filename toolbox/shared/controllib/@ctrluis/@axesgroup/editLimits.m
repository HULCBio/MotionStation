function LimBox = editLimits(this,TabContents,XY)
%EDITLIMITS  Builds group box for editing axis limits.

%   Author(s): A. DiVergilio, P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:17:09 $

% RE: XY is the axis (X or Y), and RCLabel is the row/column denomination
LimName = sprintf('%s-Limits',XY);
LimBox = find(handle(TabContents),'Name',LimName);
if isempty(LimBox)
   % Create groupbox if not found
   LimBox = LocalCreateUI(this,XY,LimName);
end

% Target
LimBox.Target = this;

% Target listeners
pconfig = [findprop(this,'XlimSharing');...
      findprop(this,'YlimSharing');...
      findprop(this,'AxesGrouping')];
LimBox.TargetListeners = ...
   [handle.listener(this,'LimitChanged',{@localReadProp XY LimBox});...
      handle.listener(this,pconfig,'PropertyPostSet',{@localConfigure XY LimBox})];

% Initialize content
localConfigure([],[],XY,LimBox)   % RC selector vis
localReadProp([],[],XY,LimBox)


%------------------ Local Functions ------------------------

function LimBox = LocalCreateUI(AxesGrid,XY,LimName)
%GUI for editing axesgroup limits

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;
import com.mathworks.mwt.*;

%---Definitions
LCENTER = MWLabel.CENTER;
LRIGHT  = MWLabel.RIGHT;
LLEFT   = MWLabel.LEFT;
BCENTER = MWBorderLayout.CENTER;
BWEST   = MWBorderLayout.WEST;
BEAST   = MWBorderLayout.EAST;
GL_N1 = java.awt.GridLayout(3,1,0,4);

% Axis dependent
if strcmpi(XY,'x')
   RCLabel = 'Column:';
else
   RCLabel = 'Row:';
end

%---Top-level panel (MWGroupbox)
Main = MWGroupbox(LimName);
Main.setFont(Prefs.JavaFontB);
Main.setLayout(MWBorderLayout(8,0));

%---Column 1 (west in Main)
s.C1 = MWPanel(GL_N1); Main.add(s.C1,BWEST);
s.RCLabel = MWLabel(sprintf('%s',RCLabel),LRIGHT); s.C1.add(s.RCLabel);
s.RCLabel.setFont(Prefs.JavaFontP);
s.AutoScaleLabel = MWLabel(sprintf('Auto-Scale:'),LLEFT); s.C1.add(s.AutoScaleLabel);
s.AutoScaleLabel.setFont(Prefs.JavaFontP);
s.LimitsLabel = MWLabel(sprintf('Limits:'),LRIGHT); s.C1.add(s.LimitsLabel);
s.LimitsLabel.setFont(Prefs.JavaFontP);

%---Center panel (center in Main, holds s.C2,s.C3)
s.Center = MWPanel(MWBorderLayout(8,0)); Main.add(s.Center,BCENTER);

%---Column 2 (west in s.Center)
s.C2 = MWPanel(GL_N1); s.Center.add(s.C2,BWEST);
s.RCSelect = MWChoice; s.C2.add(s.RCSelect);
s.RCSelect.setFont(Prefs.JavaFontP);
s.AutoScalePanel = MWPanel(MWBorderLayout(8,0)); s.C2.add(s.AutoScalePanel);
s.AutoScale = MWCheckbox; s.AutoScalePanel.add(s.AutoScale,BWEST);
s.AutoScale.setFont(Prefs.JavaFontP);

%---Column 3 (subgrid labels, center in s.Center)
s.C3 = MWPanel(GL_N1); 
s.C3L1 = MWLabel;   s.C3.add(s.C3L1);
s.C3L1.setFont(Prefs.JavaFontP);
s.C3L2 = MWLabel;   s.C3.add(s.C3L2);
s.C3L2.setFont(Prefs.JavaFontP);

%---Initialize struct array holding each row of limit editors
Panel = MWPanel(MWBorderLayout(5,0));  s.C2.add(Panel);
Lim1  = MWTextField(7); 
Panel.add(Lim1,MWBorderLayout.WEST);
Lim1.setFont(Prefs.JavaFontP);
LimTo = MWLabel(sprintf('to'),MWLabel.CENTER); 
Panel.add(LimTo,MWBorderLayout.CENTER);
LimTo.setFont(Prefs.JavaFontP);
Lim2  = MWTextField(7); 
Panel.add(Lim2,MWBorderLayout.EAST);
Lim2.setFont(Prefs.JavaFontP);
Label = MWLabel(sprintf(''));   s.C3.add(Label);
Label.setFont(Prefs.JavaFontP);
s.LimRows = struct('Panel',Panel,'Lim1',Lim1,'LimTo',LimTo,'Lim2',Lim2,'Label',Label);

%---Store java handles
set(Main,'UserData',s);

%---Create @editbox instance
LimBox = cstprefs.editbox;
LimBox.GroupBox = Main;
LimBox.Name = LimName;

% Callbacks
set(s.RCSelect,'ItemStateChangedCallback',{@localReadProp XY LimBox});
set(s.AutoScale,'ItemStateChangedCallback',{@localWriteLimMode XY LimBox 1});
LimCallback = {@localWriteLims XY LimBox 1};
set(Lim1,'ActionPerformedCallback',LimCallback,'FocusLostCallback',LimCallback);
set(Lim2,'ActionPerformedCallback',LimCallback,'FocusLostCallback',LimCallback);


%%%%%%%%%%%%%%%%%%
% localConfigure %
%%%%%%%%%%%%%%%%%%
function localConfigure(eventSrc,eventData,XY,LimBox)
% Configure GUI for current target
import com.mathworks.mwt.*;
Prefs = cstprefs.tbxprefs;
s = get(LimBox.GroupBox,'UserData');

% Init
AxGrid = LimBox.Target;
if strcmpi(XY,'x')
   ShareAll = strcmp(AxGrid.XlimSharing,'all');
   SubgridSize = AxGrid.Size(4);
   Nselect = (AxGrid.Size(2)>1 & ~ShareAll & ...
      ~strcmp(AxGrid.XlimSharing,'peer') & ...
      ~any(strcmp(AxGrid.AxesGrouping,{'column','all'})));
   Nlimrows = 1 + (~ShareAll) * (SubgridSize-1);
else
   ShareAll = strcmp(AxGrid.YlimSharing,'all');
   SubgridSize = AxGrid.Size(3);
   Nselect = (AxGrid.Size(1)>1 & ~ShareAll & ...
      ~strcmp(AxGrid.YlimSharing,'peer') & ...
      ~any(strcmp(AxGrid.AxesGrouping,{'row','all'})));
   Nlimrows = 1 + (~ShareAll) * (SubgridSize-1);
end

% Visibility of row/column selector
if Nselect & isempty(s.RCSelect.getParent)
   % Add row/column selector
   GL = java.awt.GridLayout(s.C2.getComponentCount+1,1,0,4);
   s.C1.setLayout(GL); s.C2.setLayout(GL); s.C3.setLayout(GL);
   s.C1.add(s.RCLabel,1);
   s.C2.add(s.RCSelect,1);
   s.C3.add(s.C3L2,1);
elseif ~Nselect & ~isempty(s.RCSelect.getParent)
   % Hide row/column selector
   s.C1.remove(s.RCLabel);
   s.C2.remove(s.RCSelect);
   s.C3.remove(s.C3L2);
   GL = java.awt.GridLayout(s.C2.getComponentCount,1,0,4);
   s.C1.setLayout(GL); s.C2.setLayout(GL); s.C3.setLayout(GL);
end

% Initialize row/column selector
if Nselect
   n = s.RCSelect.getSelectedIndex;  % last selection
   % Populate combo box
   nitems = 1+AxGrid.Size(1+strcmpi(XY,'x'));
   s.RCSelect.removeAll;
   for ct=1:nitems
      s.RCSelect.addItem(sprintf(''));
   end
   % Initial selection
   if n<0 | n>=nitems
      % Can happen when initializing or changing target
      n=1;
   end
   s.RCSelect.select(n);
end

% Visibility of subgrid labels
ShowSubLabels = (SubgridSize>1 & ~ShareAll);
if ShowSubLabels & isempty(s.C3.getParent)
   s.Center.add(s.C3,MWBorderLayout.CENTER);
elseif ~ShowSubLabels & ~isempty(s.C3.getParent)
   s.Center.remove(s.C3);
end
   
% Adjust number of rows of limit editors
% 1) Create missing rows
for ct=length(s.LimRows)+1:Nlimrows
   Panel = MWPanel(MWBorderLayout(5,0));
   Lim1  = MWTextField(7); 
   Panel.add(Lim1,MWBorderLayout.WEST);
   Lim1.setFont(Prefs.JavaFontP);
   LimTo = MWLabel(sprintf('to'),MWLabel.CENTER); 
   Panel.add(LimTo,MWBorderLayout.CENTER);
   LimTo.setFont(Prefs.JavaFontP);
   Lim2  = MWTextField(7); 
   Panel.add(Lim2,MWBorderLayout.EAST);
   Lim2.setFont(Prefs.JavaFontP);
   Label = MWLabel(sprintf(''));
   Label.setFont(Prefs.JavaFontP);
   s.LimRows(ct,1) = struct('Panel',Panel,'Lim1',Lim1,'LimTo',LimTo,'Lim2',Lim2,'Label',Label);
   % Callbacks
   LimCallback = {@localWriteLims XY LimBox ct};
   set(s.LimRows(ct).Lim1,...
      'ActionPerformedCallback',LimCallback,'FocusLostCallback',LimCallback);
   set(s.LimRows(ct).Lim2,...
      'ActionPerformedCallback',LimCallback,'FocusLostCallback',LimCallback);
end
% 2) Adjust row visibility
Nlimrows0 = s.C2.getComponentCount-1-Nselect;  % current row count
for ct=Nlimrows+1:Nlimrows0
   % Remove extra rows
   s.C2.remove(s.LimRows(ct).Panel);    
   s.C3.remove(s.LimRows(ct).Label);    
end
GL = java.awt.GridLayout(1+Nselect+Nlimrows,1,0,4);
s.C1.setLayout(GL); s.C2.setLayout(GL); s.C3.setLayout(GL);
for ct=Nlimrows0+1:Nlimrows
   % Add missing rows
   s.C2.add(s.LimRows(ct).Panel);    
   s.C3.add(s.LimRows(ct).Label);    
end

% Store modified s
set(LimBox.GroupBox,'UserData',s)

% Context-dependent actions
if ~isempty(eventSrc)
   % In listener callback, repack frame to reflect changes\
   LimBox.GroupBox.getFrame.pack;
end


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,XY,LimBox)
% Update GUI when limits change
s = get(LimBox.GroupBox,'UserData');
AxGrid = LimBox.Target;

% Auto-Scale status
LimModes = AxGrid.(sprintf('%sLimMode',XY));
if isempty(s.RCSelect.getParent)
   % 1x1 or shared limits or grouped axes
   s.AutoScale.setState(strcmp(LimModes{1},'auto'));
else
   rc = s.RCSelect.getSelectedIndex;
   if rc>0
      s.AutoScale.setState(strcmp(LimModes{rc},'auto'))
   else
      s.AutoScale.setState(all(strcmp(LimModes,'auto')))
   end
end

% Limits
if strcmpi(XY,'x')
   RCSize = AxGrid.Size([2 4]);
   LimSharing = AxGrid.XLimSharing;
   limfcn = 'getxlim';
else
   RCSize = AxGrid.Size([1 3]);
   LimSharing = AxGrid.YLimSharing;
   limfcn = 'getylim';
end
Limits = cell(RCSize(2),1);
if isempty(s.RCSelect.getParent)
   % 1x1 or shared limits or grouped axes
   if strcmp(LimSharing,'all')
      % Single row of limit editors
      Limits = {feval(limfcn,AxGrid)};
   elseif ~strcmp(LimSharing,'none')
      % RCSize(2) rows (read limits from first row of major grid)
      for ct=1:RCSize(2)
         Limits{ct} = feval(limfcn,AxGrid,[1 ct]);
      end
   end
else
   % Limits for selected row or column
   n = s.RCSelect.getSelectedIndex;
   if n>0 
      for ct=1:RCSize(2)
         Limits{ct} = feval(limfcn,AxGrid,[n ct]);
      end
   else
      % "All" selection
      AllLims = reshape(feval(limfcn,AxGrid),RCSize([2 1]));
      for ct=1:RCSize(2)
         if isequal(AllLims{ct,1},AllLims{ct,:})
            Limits{ct} = AllLims{ct,1};
         end
      end
   end
end

% Print limit values
for ct=1:length(Limits)
   if isempty(Limits{ct})
      s.LimRows(ct).Lim1.setText('');
      s.LimRows(ct).Lim2.setText('');
      set(s.LimRows(ct).Lim1,'UserData',[]);
   else
      s.LimRows(ct).Lim1.setText(num2str(Limits{ct}(1)));
      s.LimRows(ct).Lim2.setText(num2str(Limits{ct}(2)));
      set(s.LimRows(ct).Lim1,'UserData',Limits{ct});
   end
end


%%%%%%%%%%%%%%%%%%
% localWriteLims %
%%%%%%%%%%%%%%%%%%
function localWriteLims(eventSrc,eventData,XY,LimBox,RowIndex)
% Update limits of target when content of limit editors changes
s = get(LimBox.GroupBox,'UserData');
AxGrid = LimBox.Target;

% Get new limit values
Lim1 = localEvalLim(get(s.LimRows(RowIndex).Lim1,'Text'));
Lim2 = localEvalLim(get(s.LimRows(RowIndex).Lim2,'Text'));
CurrentLims = get(s.LimRows(RowIndex).Lim1,'UserData');
if ~isempty(Lim1) & ~isempty(Lim2) & Lim1<Lim2 & ~isequal(CurrentLims,[Lim1 Lim2])
   % Time to update the limits
   if strcmpi(XY,'x')
      RCSize = AxGrid.Size([2 4]);
      limfcn = 'setxlim';
   else
      RCSize = AxGrid.Size([1 3]);
      limfcn = 'setylim';
   end
   
   try
      if ~isempty(s.RCSelect.getParent) & s.RCSelect.getSelectedIndex>0
         % Single row or column affected
         feval(limfcn,AxGrid,[Lim1 Lim2],[s.RCSelect.getSelectedIndex RowIndex])
      elseif RCSize(2)==1
         % Global setting
         feval(limfcn,AxGrid,[Lim1 Lim2]) 
      else
         % New limits apply to each row such that mod(row,RCSize(2))=RowIndex
         for ct=1:RCSize(1)
            feval(limfcn,AxGrid,[Lim1 Lim2],[ct RowIndex])  % all subgrid peers
         end
      end
      set(s.LimRows(RowIndex).Lim1,'UserData',[Lim1 Lim2])
   catch
      warndlg(lasterr,'Property Editor Warning','modal')
   end
end


%%%%%%%%%%%%%%%%%%%%%
% localWriteLimMode %
%%%%%%%%%%%%%%%%%%%%%
function localWriteLimMode(eventSrc,eventData,XY,LimBox,RowIndex)
% Update limit modes of target when Auto-Scale state changes
s = get(LimBox.GroupBox,'UserData');
AxGrid = LimBox.Target;
LimModeProp = sprintf('%sLimMode',XY);
SubgridSize = AxGrid.Size(3+strcmpi(XY,'x'));

State = get(eventSrc,'State');
if strcmpi(State,'on')
   NewMode = {'auto'};
else
   NewMode = {'manual'};
end

% Update limit modes
LimMode = AxGrid.(LimModeProp);
if isempty(s.RCSelect.getParent) | s.RCSelect.getSelectedIndex==0
   % Global setting
   LimMode(:) = NewMode;
else
   % Change affects one row of major grid
   n = s.RCSelect.getSelectedIndex;
   LimMode((n-1)*SubgridSize+1:n*SubgridSize) = NewMode;
end
AxGrid.(LimModeProp) = LimMode;
   
   
%%%%%%%%%%%%%%%%
% localEvalLim %
%%%%%%%%%%%%%%%%
function val = localEvalLim(str)
% Evaluate string val, returning valid real scalar only, empty otherwise
if ~isempty(str)
   val = evalin('base',str,'[]');
   if ~isreal(val) | ~isfinite(val) | ~isequal(size(val),[1 1])
      val = [];
   end
else
   val = [];
end