function edit(this,PropEdit)
%EDIT  Configures Property Editor for response plots.

%   Author(s): A. DiVergilio, P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:32 $

AxGrid = this.AxesGrid;
Tabs = PropEdit.Tabs;

% Labels tab
LabelBox = this.editLabels('Labels',Tabs(1).Contents);
Tabs(1) = PropEdit.buildtab(Tabs(1),LabelBox);

% Limits tab
XlimBox = AxGrid.editLimits('X','X-Limits',Tabs(2).Contents);
YlimBox = this.editYlims(Tabs(2).Contents);
LocalCustomizeLimBox([],[],AxGrid,XlimBox,YlimBox); % @respplot customization
Tabs(2) = PropEdit.buildtab(Tabs(2),[XlimBox;YlimBox]);

% Units
UnitBox = this.editUnits('Units',Tabs(3).Contents);
Tabs(3) = PropEdit.buildtab(Tabs(3),UnitBox);

% Style
AxStyle  = AxGrid.AxesStyle;
GridBox  = AxGrid.editGrid('Grid' ,Tabs(4).Contents);
FontBox  = this.editFont('Fonts',Tabs(4).Contents);
ColorBox = AxStyle.editColors('Colors',Tabs(4).Contents);
Tabs(4)  = PropEdit.buildtab(Tabs(4),[GridBox;FontBox;ColorBox]);

%Characteristics
BoxLabel = sprintf('%s',this.tag,'Characteristics');
CharBox = this.editChars(BoxLabel,Tabs(5).Contents);
Tabs(5)  = PropEdit.buildtab(Tabs(5),CharBox);

set(PropEdit.Java.Frame,'Title',...
   sprintf('Property Editor: %s',this.AxesGrid.Title));
PropEdit.Tabs = Tabs;

%------------------- Local Functions ------------------------------

function LocalCustomizeLimBox(eventsrc,eventdata,AxGrid,XlimBox,YlimBox)
% Customizes X-Limits and Y-Limits tabs
AxSize = [AxGrid.Size 1 1];
% Input selector
s = get(XlimBox.GroupBox,'UserData'); % Java handles
XSelect = (~isempty(s.RCSelect.getParent));
if XSelect
   s.RCLabel.setText(sprintf('Input:'))
   % Populate input selector
   RCLabels = strrep(AxGrid.ColumnLabel,'From: ','');
   LocalShowIOList(s.RCSelect,RCLabels(1:AxSize(4):end),AxSize(2))
end   

% Output selector
s = get(YlimBox.GroupBox,'UserData'); % Java handles
YSelect = (~isempty(s.RCSelect.getParent));
if YSelect
   s.RCLabel.setText(sprintf('Output:'))
   RCLabels = strrep(AxGrid.RowLabel,'To: ','');
   LocalShowIOList(s.RCSelect,RCLabels(1:AxSize(3):end),AxSize(1))
end

% Related listeners
if isempty(eventsrc) & (XSelect | YSelect)
   labprop = [findprop(AxGrid,'ColumnLabel'),findprop(AxGrid,'RowLabel')];
   L = handle.listener(AxGrid,labprop,...
      'PropertyPostSet',{@LocalCustomizeLimBox AxGrid XlimBox YlimBox});
   XlimBox.TargetListeners = [XlimBox.TargetListeners ; L];
end


%%%%%%%%%%%%%%%%%%%
% LocalShowIOList %
%%%%%%%%%%%%%%%%%%%
function LocalShowIOList(RCSelect,RCLabels,RCSize)
% Builds I/O lists for X- and Y-limit tabs
n = RCSelect.getSelectedIndex;
RCSelect.removeAll;
RCSelect.addItem(sprintf('all'));
for ct=1:length(RCLabels)
   RCSelect.addItem(sprintf('%s',RCLabels{ct}));
end
RCSelect.select(n);

