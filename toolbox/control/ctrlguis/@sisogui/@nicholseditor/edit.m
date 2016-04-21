function edit(this,PropEdit)
%EDIT  Configures Property Editor for Nichols editors.

%   Author(s): A. DiVergilio, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 05:04:33 $

set(PropEdit.Java.Frame,'Title',sprintf('Property Editor: Open-Loop Nichols'));
Axes = this.Axes;
Tabs = PropEdit.Tabs;

% Labels tab
LabelBox = Axes.editLabels('Labels',Tabs(1).Contents);
Tabs(1) = PropEdit.buildtab(Tabs(1),LabelBox);

% Limits tab
XlimBox = Axes.editLimits('X','Open-Loop Phase',Tabs(2).Contents);
YlimBox = Axes.editLimits('Y','Open-Loop Gain',Tabs(2).Contents);
Tabs(2) = PropEdit.buildtab(Tabs(2),[XlimBox;YlimBox]);

% No Options tab
 TabPanel = PropEdit.Java.TabPanel;
 if TabPanel.getPanelCount==3
    TabPanel.removePanel(2)
 end

PropEdit.Tabs = Tabs;


%------------------- Local Functions ------------------------------

