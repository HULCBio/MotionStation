function edit(this,PropEdit)
%EDIT  Configures Property Editor for Root Locus editors.

%   Author(s): A. DiVergilio, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 04:57:16 $


set(PropEdit.Java.Frame,'Title',sprintf('Property Editor: Root Locus'));
Axes = this.Axes;
Tabs = PropEdit.Tabs;

% Labels tab
LabelBox = Axes.editLabels('Labels',Tabs(1).Contents);
Tabs(1) = PropEdit.buildtab(Tabs(1),LabelBox);

% Limits tab
XlimBox = Axes.editLimits('X','Real Axis',Tabs(2).Contents);
YlimBox = Axes.editLimits('Y','Imaginary Axis',Tabs(2).Contents);
LimStack = Axes.editLimStack('Limit Stack',Tabs(2).Contents);
Tabs(2) = PropEdit.buildtab(Tabs(2),[XlimBox;YlimBox;LimStack]);

% Add Options tab
TabPanel = PropEdit.Java.TabPanel;
if TabPanel.getPanelCount==2
   idx = TabPanel.getSelectedIndex;
   TabPanel.addPanel(sprintf(Tabs(3).Name),Tabs(3).Tab);
   TabPanel.selectPanel(idx)
end

% Options tab
GridOptionsBox = this.editGridOptions('Grid',Tabs(3).Contents);
AspectRatioBox = this.editAspectRatio('Aspect Ratio',Tabs(3).Contents);
Tabs(3) = PropEdit.buildtab(Tabs(3),[GridOptionsBox;AspectRatioBox]);

PropEdit.Tabs = Tabs;


%------------------- Local Functions ------------------------------

