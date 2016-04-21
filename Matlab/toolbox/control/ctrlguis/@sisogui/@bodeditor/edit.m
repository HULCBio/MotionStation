function edit(this,PropEdit)
%EDIT  Configures Property Editor for Bode editors.

%   Author(s): A. DiVergilio, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 04:56:02 $

if isa(this,'sisogui.bodeditorOL')
   set(PropEdit.Java.Frame,'Title',sprintf('Property Editor: Open-Loop Bode'));
elseif isa(this,'sisogui.bodeditorF')
   set(PropEdit.Java.Frame,'Title',sprintf('Property Editor: Filter Bode'));
end   

AxesPair = this.Axes;
Tabs = PropEdit.Tabs;

% Labels tab
LabelBox = AxesPair.editLabels('Labels',Tabs(1).Contents);
Tabs(1) = PropEdit.buildtab(Tabs(1),LabelBox);

% Limits tab
XlimBox = AxesPair.editLimits('X','Frequency',Tabs(2).Contents);
MagBox = AxesPair.editLimits('Y1','Magnitude',Tabs(2).Contents);
PhaseBox = AxesPair.editLimits('Y2','Phase',Tabs(2).Contents);
Tabs(2) = PropEdit.buildtab(Tabs(2),[XlimBox;MagBox;PhaseBox]);

% No Options tab
 TabPanel = PropEdit.Java.TabPanel;
 if TabPanel.getPanelCount==3
    TabPanel.removePanel(2)
 end

PropEdit.Tabs = Tabs;


%------------------- Local Functions ------------------------------

