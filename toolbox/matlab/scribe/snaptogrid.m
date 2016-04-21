function grid=snaptogrid(varargin)
%SNAPTOGRID Snap-to-grid moving and resizing.

%   SNAPTOGRID turns snap-to-grid editing on for current figure
%   SNAPTOGRID(FIG) turns snap-to-grid editing on for figure FIG
%   SNAPTOGRID('on') turns snap-to-grid editing on for current figure
%   SNAPTOGRID('off') turns snap-to-grid editing off for current figure
%   SNAPTOGRID(FIG,'on') turns snap-to-grid editing on for figure FIG
%   SNAPTOGRID(FIG,'off') turns snap-to-grid editing off for figure FIG
%   SNAPTOGRID(GRIDSTRUCT) sets grid properties for current figure
%   SNAPTOGRID(FIG,GRIDSTRUCT) sets grid properties for figure FIG
%   GRIDSTRUCT=SNAPTOGRID(...) returns current grid structure for figure
%   GRIDSTRUCT is a structure with the following fields:
%       xspace: x space in pixels between vertical grid lines
%       yspace: y space in pixels between horizontal grid lines
%       visible: set to 'on' to display grid or 'off' to hide it.
%       color: A 1x3 color vector for the grid
%       lineStyle: same as line linestyle strings
%       lineWidth: same as line linewidth
%       influence: Distance in pixels from grid at which an object snaps
%       snapType: Determines the part of the edited object which snaps to the
%       grid. SnapType can be one of the following:
%       'top'
%       'bottom'
%       'left'
%       'right'
%       'center'
%       'topleft' 
%       'topright'
%       'bottomleft'
%       'bottomright'
%   Internal syntax:
%   SNAPTOGRID(FIG,'togglesnap') toggles snap on/off and handles figure menu
%   toggle (check) menu item.
%   SNAPTOGRID(FIG,'toggleview') toggles view grid and handles figure menu
%   toggle (check) menu item.
%   GRIDSTRUCT=SNAPTOGRID(FIG,'noaction') return grid structure without
%   turning snaptogrid on

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $  $  $  $ 


error(nargchk(0,2,nargin));

if nargout>0
    returngrid=true;
else
    returngrid=false;
end

if nargin==2
    if ishandle(varargin{1}) && strcmpi('figure',get(varargin{1},'type'))
        fig = varargin{1};
    else
        error('first argument must be a figure');
    end
    if ischar(varargin{2}) 
        if ~( strcmpi(varargin{2},'on') || strcmpi(varargin{2},'off') || ...
            strcmpi(varargin{2},'togglesnap') || strcmpi(varargin{2},'toggleview') ||...
            strcmpi(varargin{2},'noaction') )
            error('string must be either ''on'',''off'',''togglesnap'',''toggleview'' or ''noaction''');
        else
            action = varargin{2};
        end
    else
        newgridstruct = varargin{2};
        action = 'setgrid';
    end
elseif nargin==1
    if ishandle(varargin{1}) 
        if strcmpi('figure',get(varargin{1},'type'))
            fig = varargin{1};
            action = 'on';
        else
            error('handle argument must be a valid figure');
        end
    elseif ischar(varargin{1})
        fig = figcheck;
        if ~(strcmpi(varargin{1},'on') || strcmpi(varargin{1},'off') || strcmpi(varargin{1},'toggle'))
            error('string must be either ''on'' or ''off''');
        else
            action = varargin{1};
        end
    else
        fig = figcheck;
        newgridstruct = varargin{1};
        action = 'setgrid';
    end
else
    fig = figcheck;
    action = 'on';
end

switch action
    case 'on'
        ison = getappdata(fig,'scribegui_snaptogrid');
        if isempty(ison) || ~strcmpi(ison,'on')
            setappdata(fig,'scribegui_snaptogrid','on');
            if isappdata(fig,'scribegui_snapgridstruct')
                oldgridstruct=getappdata(fig,'scribegui_snapgridstruct');
                oldgridstruct=fill_in_gridstruct(oldgridstruct,fig);
                update_scribegrid(oldgridstruct,fig);
            else
                newgridstruct=set_default_gridstruct(fig);
                update_scribegrid(newgridstruct,fig);
            end
        end
    case 'off'
        ison = getappdata(fig,'scribegui_snaptogrid');
        if isempty(ison) || ~strcmpi(ison,'off')
            setappdata(fig,'scribegui_snaptogrid','off');
            if isappdata(fig,'scribegui_snapgridstruct')
                oldgridstruct=getappdata(fig,'scribegui_snapgridstruct');
                oldgridstruct=fill_in_gridstruct(oldgridstruct,fig);
                update_scribegrid(oldgridstruct,fig);
            else
                newgridstruct=set_default_gridstruct(fig);
                update_scribegrid(newgridstruct,fig);
            end
        end
    case 'togglesnap'
        t = findall(fig,'tag','figMenuSnapToGrid');
        checked = get(t,'checked');
        if strcmpi(checked,'off')
            set(t,'checked','on');
            snaptogrid(fig,'on');
        else
            set(t,'checked','off');
            snaptogrid(fig,'off');
        end
    case 'toggleview'
        t = findall(fig,'tag','figMenuViewGrid');
        checked = get(t,'checked');
        g=snaptogrid(fig,'noaction');
        if strcmpi(checked,'off')
            set(t,'checked','on');
            g.visible='on';
        else
            set(t,'checked','off');
            g.visible='off';
        end
        snaptogrid(fig,g);
    case 'noaction'
        % do nothing
    case 'setgrid'
        newgridstruct=fill_in_gridstruct(newgridstruct,fig);
        update_scribegrid(newgridstruct,fig);
end

if returngrid
    if isappdata(fig,'scribegui_snapgridstruct');
        grid = getappdata(fig,'scribegui_snapgridstruct');
        grid = fill_in_gridstruct(grid,fig);
    else
        grid = set_default_gridstruct(fig);
    end
end

%------------------------------------------------------------------------%
function grid=set_default_gridstruct(fig)
% could call fill_in_gridstruct with empty struct...
% create default grid structure
grid.xspace = 20;
grid.yspace = 20;
grid.visible = 'off';
grid.color = best_grid_color(fig);
grid.lineStyle = '-';
grid.lineWidth = 1.0;
grid.influence = 10;
grid.snapType = 'topleft';
setappdata(fig,'scribegui_snapgridstruct',grid);

%------------------------------------------------------------------------%
function newgrid=fill_in_gridstruct(oldgrid,fig)
% fill in any missing fields and save
needsset = false;
newgrid=oldgrid;
if ~isfield(oldgrid,'xspace') newgrid.xspace = 20; needsset=true; end
if ~isfield(oldgrid,'yspace') newgrid.yspace = 20; needsset=true; end
if ~isfield(oldgrid,'visible') newgrid.visible = 'off'; needsset=true; end
if ~isfield(oldgrid,'color') newgrid.color = best_grid_color(fig); needsset=true; end
if ~isfield(oldgrid,'lineStyle') newgrid.lineStyle = '-'; needsset=true; end
if ~isfield(oldgrid,'lineWidth') newgrid.lineWidth = 1.0; needsset=true; end
if ~isfield(oldgrid,'influence') newgrid.influence = 10; needsset=true; end
if ~isfield(oldgrid,'snapType') newgrid.snapType = 'topleft'; needsset=true; end
if needsset setappdata(fig,'scribegui_snapgridstruct',newgrid); end

%-----------------------------------------------------------------------%
function fig=figcheck
if length(findobj(0,'type','figure'))<1
    error('no figures');
end
fig = get(0,'currentfigure');

%-----------------------------------------------------------------------%
function update_scribegrid(gridstruct,fig)

found=false;
scribeunder = findall(fig,'Tag','scribeUnderlay');
if ~isempty(scribeunder)
    % look for existing scribegrid - there can only be one.
    underkids = findall(scribeunder,'type','hggroup');
    k=1;
    while k<=length(underkids) && ~found
        if isprop(handle(underkids(k)),'shapetype')
            if strcmpi('scribegrid',get(handle(underkids(k)),'shapetype'))
                SG = handle(underkids(k)); found=true;
            end
        end
        k=k+1;
    end
end
if ~found
    SG = scribe.scribegrid(fig);
    scribeax = getappdata(fig,'Scribe_ScribeOverlay');
    methods(handle(scribeax),'stackScribeLayersWithChild',double(scribeax),true);
end
%set appdata
setappdata(fig,'scribegui_snapgridstruct',gridstruct);
copy_struct_to_scribegrid(gridstruct,SG);

%-----------------------------------------------------------------------%
function copy_struct_to_scribegrid(gridstruct,SG)

SG.xspace = gridstruct.xspace;
SG.yspace = gridstruct.yspace;
SG.visible = gridstruct.visible;
SG.color = gridstruct.color;
SG.lineStyle = gridstruct.lineStyle;
SG.lineWidth = gridstruct.lineWidth;

%-----------------------------------------------------------------------%
function gcolor=best_grid_color(fig)

figcolor=get(fig,'color');
if abs(figcolor(1) - figcolor(2)) < 0.07 && ...
        abs(figcolor(1) - figcolor(2)) < 0.07
    % more or less grey
    if figcolor(1) < 0.5
        gcolor = [figcolor(1) + .3, figcolor(2) + .3, figcolor(3) + .3];
    else
        gcolor = [figcolor(1) - .3, figcolor(2) - .3, figcolor(3) - .3];
    end
else
    % not really grey
    for k=1:3
        if figcolor(k) < .5
            gcolor(k) = figcolor(k) + .3;
        else
            gcolor(k) = figcolor(k) - .3;
        end
    end
end

% check for over/underflow
for k=1:3
    if figcolor(k)<0
        figcolor(k)=0;
    elseif figcolor(k)>1
        figcolor(k)=1;
    end
end



