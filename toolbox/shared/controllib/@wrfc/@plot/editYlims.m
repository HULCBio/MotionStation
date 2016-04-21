function YlimBox = editYlims(this,TabContents)
%EDITYLIMS  Builds group box for Y limit editing.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:27:21 $

% Default implementation (standard limit editor)
YlimBox = this.AxesGrid.editLimits('Y','Y-Limits',TabContents);