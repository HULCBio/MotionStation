function edit(this,PropEdit)
%EDIT  Configures Property Editor for response plots.

%   Author(s): A. DiVergilio, P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:31 $

AxGrid = this.AxesGrid;
Tabs = PropEdit.Tabs;

% Labels tab
LabelBox = this.editLabels('Labels',Tabs(1).Contents);
Tabs(1) = PropEdit.buildtab(Tabs(1),LabelBox);

% Limits tab
XlimBox = AxGrid.editLimits('X','X-Limits',Tabs(2).Contents);
YlimBox = AxGrid.editLimits('Y','Y-Limits',Tabs(2).Contents);
LocalCustomizeLimBox([],[],AxGrid,YlimBox); % @waveplot customization
Tabs(2) = PropEdit.buildtab(Tabs(2),[XlimBox;YlimBox]);

% Units

% Style

% Characteristics

PropEdit.Tabs = Tabs;


%------------------- Local Functions ------------------------------

function LocalCustomizeLimBox(eventsrc,eventdata,AxGrid,YlimBox)
% Customizes X-Limits and Y-Limits tabs
AxSize = [AxGrid.Size 1 1];

% Channel selector
s = get(YlimBox.GroupBox,'UserData'); % Java handles
YSelect = (~isempty(s.RCSelect.getParent));
if YSelect
   s.RCLabel.setText(sprintf('Channel:'))
   LocalShowChannelList(s.RCSelect,AxGrid.RowLabel(1:AxSize(3):end),AxSize(1))
end

% Related listeners
if isempty(eventsrc) & YSelect
   L = handle.listener(AxGrid,findprop(AxGrid,'RowLabel'),...
      'PropertyPostSet',{@LocalCustomizeLimBox AxGrid YlimBox});
   YlimBox.TargetListeners = [YlimBox.TargetListeners ; L];
end


%%%%%%%%%%%%%%%%%%%%%%%%
% LocalShowChannelList %
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalShowChannelList(RCSelect,RCLabels,RCSize)
% Builds I/O lists for X- and Y-limit tabs
n = RCSelect.getSelectedIndex;
RCSelect.removeAll;
RCSelect.addItem(sprintf('all'));
for ct=1:length(RCLabels)
   RCSelect.addItem(sprintf('%s',RCLabels{ct}));
end
RCSelect.select(n);

