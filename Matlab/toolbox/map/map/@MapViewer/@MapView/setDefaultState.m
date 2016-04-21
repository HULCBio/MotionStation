function setDefaultState(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:57:07 $
this.State = MapViewer.DefaultState(this);

toolbar = findall(this.Figure,'type','uitoolbar');
toggleTool = findobj(get(toolbar,'Children'),'Tag','select annotations');
set(toggleTool,'State','on');
this.Axis.updateOriginalAxis;