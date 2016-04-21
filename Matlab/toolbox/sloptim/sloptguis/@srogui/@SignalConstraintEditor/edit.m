function edit(this,PropEdit)
%EDIT  Configures Property Editor for response plots.

%   Author(s): A. DiVergilio, P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:44:43 $
Axes = this.Axes;
Tabs = PropEdit.Tabs;

% Labels tab
LabelBox = Axes.editLabels('Labels',Tabs(1).Contents);
Tabs(1) = PropEdit.buildtab(Tabs(1),LabelBox);

% Limits tab
XlimBox = Axes.editLimits('X','X-Limits',Tabs(2).Contents);
YlimBox = Axes.editLimits('Y','Y-Limits',Tabs(2).Contents);
Tabs(2) = PropEdit.buildtab(Tabs(2),[XlimBox;YlimBox]);

set(PropEdit.Java.Frame,'Title',...
   sprintf('Property Editor: %s',this.Axes.Title));
PropEdit.Tabs = Tabs;

