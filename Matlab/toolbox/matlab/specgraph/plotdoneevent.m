function plotdoneevent(ax,h)
% This internal helper function may change in a future release.

%PLOTDONEEVENT Send a plot event that a plot is finished
%    PLOTDONEEVENT(AX,H) sends plot event that objects H have been
%    added to axes AX.

%   Copyright 1984-2003 The MathWorks, Inc.

plotmgr = getappdata(ancestor(ax,'figure'),'PlotManager');
if ishandle(plotmgr)
  evdata = graphics.plotevent(plotmgr,'PlotFunctionDone');
  set(evdata,'ObjectsCreated',h);
  send(plotmgr,'PlotFunctionDone',evdata);
end
