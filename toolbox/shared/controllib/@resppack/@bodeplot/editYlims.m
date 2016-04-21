function YlimBox = editYlims(this,TabContents)
%EDITYLIMS  Builds group box for Y limit editing.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:20 $

% Build standard Y-limit box
YlimBox = this.AxesGrid.editLimits('Y','Y-Limits',TabContents);

% Add Mag/Phase labels
s = get(YlimBox.GroupBox,'UserData'); % Java handles
s.LimRows(1).Label.setText(sprintf('(Magnitude)'))
s.LimRows(2).Label.setText(sprintf('(Phase)'))