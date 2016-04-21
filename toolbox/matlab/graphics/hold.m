function hold(varargin);
%HOLD   Hold current graph.
%   HOLD ON holds the current plot and all axis properties so that
%   subsequent graphing commands add to the existing graph.
%   HOLD OFF returns to the default mode whereby PLOT commands erase 
%   the previous plots and reset all axis properties before drawing 
%   new plots.
%   HOLD, by itself, toggles the hold state.
%   HOLD does not affect axis autoranging properties.
%
%   HOLD ALL holds the plot and the current color and linestyle so
%   that subsequent plotting commands will not reset the color and
%   linestyle.
%
%   HOLD(AX,...) applies the command to the Axes object AX.
%
%   Algorithm note:
%   HOLD ON sets the NextPlot property of the current figure and
%   axes to "add".
%   HOLD OFF sets the NextPlot property of the current axes to
%   "replace".
%
%   See also ISHOLD, NEWPLOT, FIGURE, AXES.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.4 $  $Date: 2004/04/10 23:28:48 $

% Parse possible Axes input
error(nargchk(0,2,nargin));
[ax,args,nargs] = axescheck(varargin{:});

if isempty(ax)
    ax = gca;
end
fig = ancestor(ax,'figure');

if ~isempty(args)
    opt_hold_state = args{1};
end

nexta = lower(get(ax,'NextPlot'));
nextf = lower(get(fig,'NextPlot'));
hold_state = strcmp(nexta,'add') & strcmp(nextf,'add');
if(nargs == 0)
    if(hold_state)
        set(ax,'NextPlot','replace');
        disp('Current plot released');
    else
        set(fig,'NextPlot','add');
        set(ax,'NextPlot', 'add');
        disp('Current plot held');
    end
    setappdata(ax,'PlotHoldStyle',false);
elseif(strcmp(opt_hold_state, 'on'))
    set(fig,'NextPlot','add');
    set(ax,'NextPlot', 'add');
    setappdata(ax,'PlotHoldStyle',false);
elseif(strcmp(opt_hold_state, 'off'))
    set(ax,'NextPlot', 'replace');
    setappdata(ax,'PlotHoldStyle',false);
elseif(strcmp(opt_hold_state, 'all'))
    set(fig,'NextPlot','add');
    set(ax,'NextPlot', 'add');
    setappdata(ax,'PlotHoldStyle',true);
else
    error('Unknown command option.');
end
