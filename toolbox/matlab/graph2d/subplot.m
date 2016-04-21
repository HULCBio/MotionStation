function theAxis = subplot(nrows, ncols, thisPlot, varargin)
%SUBPLOT Create axes in tiled positions.
%   H = SUBPLOT(m,n,p), or SUBPLOT(mnp), breaks the Figure window
%   into an m-by-n matrix of small axes, selects the p-th axes for 
%   for the current plot, and returns the axis handle.  The axes 
%   are counted along the top row of the Figure window, then the
%   second row, etc.  For example,
% 
%       SUBPLOT(2,1,1), PLOT(income)
%       SUBPLOT(2,1,2), PLOT(outgo)
% 
%   plots income on the top half of the window and outgo on the
%   bottom half.
% 
%   SUBPLOT(m,n,p), if the axis already exists, makes it current.
%   SUBPLOT(m,n,p,'replace'), if the axis already exists, deletes it and
%   creates a new axis.
%   SUBPLOT(m,n,p,'align') places the axes so that the plot boxes
%   are aligned instead of preventing the labels and ticks from
%   overlapping. 
%   SUBPLOT(m,n,P), where P is a vector, specifies an axes position
%   that covers all the subplot positions listed in P.
%   SUBPLOT(H), where H is an axis handle, is another way of making
%   an axis current for subsequent plotting commands.
%
%   SUBPLOT('position',[left bottom width height]) creates an
%   axis at the specified position in normalized coordinates (in 
%   in the range from 0.0 to 1.0).
%
%   SUBPLOT(m,n,p, PROP1, VALUE1, PROP2, VALUE2, ...) sets the
%   specified property-value pairs on the subplot axis. To add the
%   subplot to a specific figure pass the figure handle as the
%   value for the 'Parent' property.
%
%   If a SUBPLOT specification causes a new axis to overlap an
%   existing axis, the existing axis is deleted - unless the position
%   of the new and existing axis are identical.  For example,
%   the statement SUBPLOT(1,2,1) deletes all existing axes overlapping
%   the left side of the Figure window and creates a new axis on that
%   side - unless there is an axes there with a position that exactly
%   matches the position of the new axes (and 'replace' was not specified),
%   in which case all other overlapping axes will be deleted and the 
%   matching axes will become the current axes.
%   
%   SUBPLOT(111) is an exception to the rules above, and is not
%   identical in behavior to SUBPLOT(1,1,1).  For reasons of backwards
%   compatibility, it is a special case of subplot which does not
%   immediately create an axes, but instead sets up the figure so that
%   the next graphics command executes CLF RESET in the figure
%   (deleting all children of the figure), and creates a new axes in
%   the default position.  This syntax does not return a handle, so it
%   is an error to specify a return argument.  The delayed CLF RESET
%   is accomplished by setting the figure's NextPlot to 'replace'.

%   SUBPLOT(m,n,p,H) when H is an axes will move H to the specified
%   position. 
%   SUBPLOT(m,n,p,H,PROP1,VALUE1,...) will move H and apply the
%   specified property-value pairs 

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.22.4.8 $  $Date: 2004/04/15 00:00:44 $

% we will kill all overlapping axes siblings if we encounter the mnp
% or m,n,p specifier (excluding '111').
% But if we get the 'position' or H specifier, we won't check for and
% delete overlapping siblings:
narg = nargin;
kill_siblings = 0;
create_axis = true;
move_axis = false;
delay_destroy = false;
useOuterPosition = true;
useAutoLayout = true;
tol = sqrt(eps);
parent = get(0,'CurrentFigure');
parentfigure = parent;
pvpairs = {};

% This is the percent offset from the subplot grid of the plotbox.
inset = [.2 .18 .04 .1]; % [left bottom right top]

if narg == 0 % make compatible with 3.5, i.e. subplot == subplot(111)
    nrows = 111;
    narg = 1;
end

%check for encoded format
handle = '';
position = '';

if narg == 1
    % The argument could be one of 3 things:
    % 1) a 3-digit number 100 < num < 1000, of the format mnp
    % 2) a 3-character string containing a number as above
    % 3) an axis handle
    code = nrows;

    % turn string into a number:
    if(isstr(code)) 
        code = str2double(code);
    end

    % number with a fractional part can only be an identifier:
    if(rem(code,1) > 0)
        handle = code;
        if ~strcmp(get(handle,'type'),'axes')
            error('Requires valid axes handle for input.')
        end
        create_axis = false;
    % all other numbers will be converted to mnp format:
    else
        thisPlot = rem(code, 10);
        ncols = rem( fix(code-thisPlot)/10,10);
        nrows = fix(code/100);
        if nrows*ncols < thisPlot
            error('Index exceeds number of subplots.');
        end
	    kill_siblings = 1;
	    if(code == 111)
	    create_axis   = false;
	    delay_destroy = true;
	    else
	    create_axis   = true;
	    delay_destroy = false;
	    end
    end
    
elseif narg == 2
    % The arguments MUST be the string 'position' and a 4-element vector:
    if(strcmp(lower(nrows), 'position'))
        pos_size = size(ncols);
        if(pos_size(1) * pos_size(2) == 4)
            position = ncols;
        else
            error(['position must be of the form [left bottom width height]'])
        end
    else
        error('Unknown command option')
    end
    kill_siblings = 1; % Kill overlaps here also.
    useOuterPosition = false;
    useAutoLayout = false;
    
elseif narg == 3
    % passed in subplot(m,n,p) -- we should kill overlaps
    % here too:
    kill_siblings = 1;
    
elseif narg >= 4
  arg = varargin{1};
  if ~ischar(arg)
    % passed in subplot(m,n,p,H,...)
    handle = arg;
    parent = get(handle,'Parent');
    parentfigure = ancestor(handle,'figure');
    set(parentfigure,'CurrentAxes',handle);
    move_axis = true;
    create_axis = false;
    pvpairs = varargin(2:end);
  elseif strncmp(lower(arg),'replace',1)
    % passed in subplot(m,n,p,'replace')
    kill_siblings = 2; % kill nomatter what
  elseif strcmp(lower(arg),'align')
    % passed in subplot(m,n,p,'align')
    useOuterPosition = false;
    kill_siblings = 1; % kill if it overlaps stuff
  else
    % passed in prop-value pairs
    kill_siblings = 1;
    pvpairs = varargin;
    par = find(strncmpi('Parent',pvpairs(1:2:end),6));
    if any(par)
      parent = varargin{2*par(1)};
      parentfigure = ancestor(parent,'figure');
    end
  end
end

% if we recovered an identifier earlier, use it:
if ~isempty(handle) && ~move_axis
  parent = get(handle,'Parent');
  parentfigure = ancestor(handle,'figure');
  set(parentfigure,'CurrentAxes',handle);
else  % if we haven't recovered position yet, generate it from mnp info:
  if isempty(parent), 
    parent = gcf; 
    parentfigure = parent; 
  end
  if(isempty(position))
    if (min(thisPlot) < 1)
      error('Illegal plot number.')
    elseif (max(thisPlot) > ncols*nrows)
      error('Index exceeds number of subplots.')
    else

      row = (nrows-1) -fix((thisPlot-1)/ncols);
      col = rem (thisPlot-1, ncols);

      % get default axis position in normalized units
      if ~strcmp(get(parentfigure,'defaultaxesunits'),'normalized')
        tmp = axes;
        set(axes,'units','normalized')
        def_pos = get(tmp,'position');
        delete(tmp)
      else
        def_pos = get(parentfigure,'DefaultAxesPosition');
      end

      % compute outerposition and insets relative to figure bounds
      rw = max(row)-min(row)+1;
      cw = max(col)-min(col)+1;
      width = def_pos(3)/(ncols - inset(1) - inset(3));
      height = def_pos(4)/(nrows - inset(2) - inset(4));
      inset = inset.*[width height width height];
      outerpos = [def_pos(1) + min(col)*width - inset(1), ...
                  def_pos(2) + min(row)*height - inset(2), ...
                  width*cw height*rw];

      % adjust outerpos and insets for axes around the outside edges
      if min(col) == 0
        inset(1) = def_pos(1); 
        outerpos(3) = outerpos(1)+outerpos(3); 
        outerpos(1) = 0; 
      end
      if min(row) == 0, 
        inset(2) = def_pos(2);
        outerpos(4) = outerpos(2)+outerpos(4); 
        outerpos(2) = 0;
      end
      if max(col) == ncols-1, 
        inset(3) = 1-def_pos(1)-def_pos(3);
        outerpos(3) = 1-outerpos(1);
      end
      if max(row) == nrows-1, 
        inset(4) = 1-def_pos(2)-def_pos(4);
        outerpos(4) = 1-outerpos(2);
      end

      % compute inner position
      position = [outerpos(1:2) + inset(1:2),...
                  outerpos(3:4) - inset(1:2) - inset(3:4)];

      % compute loose insets relative to outerposition
      loose = inset./[outerpos(3:4) outerpos(3:4)];
    end
  end
end

% kill overlapping siblings if mnp specifier was used:
nextstate = get(parentfigure,'nextplot');

if strncmp(nextstate,'replace',7)
  nextstate = 'add'; 
elseif strncmp(nextstate,'new',3)
  kill_siblings = 0;
end

if(kill_siblings)
    if delay_destroy
        if nargout
            error('Function called with too many output arguments')
        else
            set(parentfigure,'NextPlot','replace'); 
            return
        end
    end
    sibs = datachildren(parent);
    got_one = 0;
    if useOuterPosition
      activepos = outerpos;
      posProperty = 'OuterPosition';
    else
      activepos = position;
      posProperty = 'Position';
    end
    for i = 1:length(sibs)
        % Be aware that handles in this list might be destroyed before
        % we get to them, because of other objects' DeleteFcn callbacks...
        if(ishandle(sibs(i)) & strcmp(get(sibs(i),'Type'),'axes'))
            units = get(sibs(i),'Units');
            set(sibs(i),'Units','normalized')
            sibpos = get(sibs(i),posProperty);
            sibposition = get(sibs(i),'Position');
            set(sibs(i),'Units',units);
            intersect = 1;
            if((activepos(1) >= sibpos(1) + sibpos(3)-tol) | ...
                (sibpos(1) >= activepos(1) + activepos(3)-tol) | ...
                (activepos(2) >= sibpos(2) + sibpos(4)-tol) | ...
                (sibpos(2) >= activepos(2) + activepos(4)-tol))
                intersect = 0;
            end
            if useOuterPosition
              % detect what to delete by overlapping position values
              % to makes sure that we aren't deleting adjacent axes
              intersectPos  = 1;
              if((position(1) >= sibposition(1) + sibposition(3)-tol) | ...
                 (sibposition(1) >= position(1) + position(3)-tol) | ...
                 (position(2) >= sibposition(2) + sibposition(4)-tol) | ...
                 (sibposition(2) >= position(2) + position(4)-tol))
                intersectPos = 0;
              end
            else
              intersectPos = intersect;
            end
            if intersect
                % if already found the position match axis (got_one)
                % or if this intersecting axis doesn't have matching pos
                % or if we know we want to make a new axes anyway (kill_siblings==2)
                % delete it
                if got_one | ...
                        any(abs(sibpos - activepos) > tol) | ...
                        kill_siblings==2
                  if intersectPos
                    delete(sibs(i));
                  end
                    % otherwise, the intersecting sibs' pos matches subplot area
                else
                    got_one = 1;
                    set(parentfigure,'CurrentAxes',sibs(i));
                    if strcmp(nextstate,'new')
                        create_axis = true;
                    else
                        create_axis = false;
                    end
                end
            end
        end
    end
set(parentfigure,'NextPlot',nextstate);
end

% create the axis:
if create_axis
  if strcmp(nextstate,'new')
    figure
  end
  if (useOuterPosition)
    ax = axes('units','normal','OuterPosition',outerpos,...
              'LooseInset',loose,pvpairs{:});
  else
    ax = axes('units','normal','Position',position,pvpairs{:});
  end
  set(ax,'units',get(parentfigure,'defaultaxesunits'))
  if useAutoLayout
    addAxesToGrid(ax,nrows,ncols,row,col,loose);
  end
elseif move_axis
  ax = handle;
  units = get(handle,'units');
  if (useOuterPosition)
    set(handle,'units','normal','OuterPosition',outerpos,...
               'LooseInset',loose,pvpairs{:});
  else
    set(handle,'units','normal','Position',position,pvpairs{:});
  end
  set(handle,'units',units);
  if useAutoLayout
    addAxesToGrid(ax,nrows,ncols,row,col,loose);
  end
else
  ax = get(parentfigure,'CurrentAxes'); 
  if ~isempty(pvpairs)
    set(ax,pvpairs{:});
  end
end

% return identifier, if requested:
if(nargout > 0)
    theAxis = ax;
end

% Create subplot listeners to align plot boxes automatically
function createListeners(p,axlisth)
ph=handle(p);
setappdata(p,'SubplotListeners',[])
fig = p;
if ~isequal(get(fig,'Type'),'figure')
  fig = ancestor(fig,'figure');
end
list = [...
    handle.listener(axlisth,findprop(axlisth(1),'OuterPosition'), ...
                    'PropertyPostSet',@axesMoved);
    handle.listener(axlisth,findprop(axlisth(1),'ActivePositionProperty'), ...
                    'PropertyPreSet',@axesMoved);
    handle.listener(axlisth,findprop(axlisth(1),'Parent'), ...
                    'PropertyPreSet',@axesMoved);
    handle.listener(axlisth,'AxisInvalidEvent',{@subplotlayoutInvalid,p});
    handle.listener(handle(fig),'FigureUpdateEvent',{@subplotlayout,p})];
for k=1:length(axlisth)
  ax = axlisth(k);
  if ~isappdata(double(ax),'SubplotDeleteListener')
    setappdata(double(ax),'SubplotDeleteListener',...
                          handle.listener(ax,'ObjectBeingDestroyed', ...
                                          @axesDestroyed));
  end
end
setappdata(p,'SubplotListeners',list)

% Add ax to a matrix of handles in the specified location.
% The grid is stored on the parent appdata.
% Also store the insets in ax appdata.
% Only stores the axes if it is in a 1-by-1 cell and
% the grid size matches any existing grid.
function addAxesToGrid(ax,nrows,ncols,row,col,loose)
p = get(ax,'parent');
grid = getappdata(p,'SubplotGrid');
if isempty(grid)
  grid = zeros(nrows,ncols);
end
if any(size(grid) ~= [nrows ncols]), return; end
if length(row) ~= 1 || length(col) ~= 1, return; end
grid(row+1,col+1) = ax;
list = grid(:);
list(list == 0) = []; % remove root
list(~ishandle(list)) = []; % remove invalid handles
createListeners(p,handle(list));
setappdata(p,'SubplotGrid',grid)
setappdata(ax,'SubplotInsets',loose);

% Remove ax from grid of subplots in p
function removeAxesFromGrid(p,ax)
grid = getappdata(p,'SubplotGrid');
if ~isempty(grid)
  n = grid == ax;
  if any(n(:))
    grid(n) = 0;
    list = grid(:);
    list(list == 0) = []; % remove root
    list(~ishandle(list)) = [];
    if isempty(list)
      rmappdata(p,'SubplotListeners');
      rmappdata(p,'SubplotGrid');
    else
      setappdata(p,'SubplotGrid',grid);
    end
  end
end

% Callback when axis moves to remove it from subplot layout grid
function axesMoved(hSrc,evdata)
ax = double(evdata.affectedObject);
removeAxesFromGrid(get(ax,'Parent'),ax);

% Callback when axis destroyed 
function axesDestroyed(hSrc,evdata)
ax = double(hSrc);
p = get(ax,'Parent');
if strcmp(get(p,'BeingDeleted'),'off')
  removeAxesFromGrid(p,ax);
elseif isappdata(p,'SubplotListeners')
  rmappdata(p,'SubplotListeners');
  rmappdata(p,'SubplotGrid');
end

