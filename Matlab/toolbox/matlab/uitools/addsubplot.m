function ax = addsubplot (varargin)
% ADDSUBPLOT creates a new subplot and adds it to the figure at the given location.
%    ADDSUBPLOT (fig, WHERE) creates a cartplane at the specified location.
%    ADDSUBPLOT (fig, WHERE, CMD, ...) creates an axes using the specified command
%      with optional arguments.
% For instance, ADDSUBPLOT (fig, 'Top') puts the new axes across the top of
% the figure.  Other locations are 'Bottom', 'Left', and 'Right'.
% The last arguments are optional; they define what kind of axes to
% create.  The default is 'cartplane'.  Another kind is 'polarplane'.  
% The remaining arguments are passed to the axes being created.

% Copyright 2002-2003 The MathWorks, Inc.

%%---------------------------------------------------
%% Get a figure to put the plot on:
if (nargin > 0) 
     fig = varargin{1};
     if ~ishandle (fig)
         error ('The first argument must be a handle to a figure');
     end
else
     fig = figure;
end

%%---------------------------------------------------
%% Get the location of the new axes:

if (nargin > 1)
     where = varargin{2};
else
     where = 'Bottom';
end

%%---------------------------------------------------
%% Get the command with which to make the axes:

if (nargin > 2)
     axesCmd = varargin{3};
else
     axesCmd = 'axes';
end

%%---------------------------------------------------
%% Figure out the "squish factor," or by how much to compress the 
%% existing plots:

figH = handle(fig);
children = figH.find ...
   ('-depth', 1, ...
    'type','axes', ...
    'handlevisibility', 'on', ...
    'visible', 'on', ...
    '-not','tag','legend','-and','-not','tag','colorbar');
% Note:  this is the same search used in plottoolfunc.

origNum = length(children);
if origNum == 0 
    squishFactor = 1;
else
    squishFactor = origNum / (origNum + 1);
end
% TODO:  squishFactor could depend on more complicated heuristics;
% e.g. how many subplots tall is it, vs. how many total subplots

%%---------------------------------------------------
%% Figure out the outer position of the new axes:

newPlotX = 0;
newPlotY = 0;
newPlotWidth = 1;
newPlotHeight = 1;
if (strcmpi (where, 'Bottom') == 1)
        newPlotHeight = 1 / (origNum + 1);
elseif (strcmpi (where, 'Top') == 1)
        newPlotHeight = 1 / (origNum + 1);
	newPlotY = 1 - newPlotHeight;
elseif (strcmpi (where, 'Left') == 1)
        newPlotWidth = 1 / (origNum + 1);
elseif (strcmpi (where, 'Right') == 1)
        newPlotWidth = 1 / (origNum + 1);
	newPlotX = 1 - newPlotWidth;
end


%%---------------------------------------------------
%% Create the new axes:

gca = [];
if (nargin > 3)
     thing = feval (axesCmd, varargin{4:end}, 'Parent', fig);
else
     thing = feval (axesCmd, 'Parent', fig);
end

parent = handle (get (thing, 'parent'));
parentType = get (parent, 'type');
if (strcmp (parentType, 'axes') == 1)
     ax = parent;
elseif (strcmp (parentType, 'figure') == 1)
     ax = thing;
else
     ax = [];
end


%%---------------------------------------------------
%% Squish all the existing axes:

for i = 1:origNum
    theAxes = handle(children(i));
    if (isprop (theAxes, 'OuterPosition'))
	    posnPropName = 'OuterPosition';
    else
	    posnPropName = 'Position';
    end
    origPosn = get (theAxes, posnPropName);
    if (strcmpi (where, 'Bottom') == 1)
        newHeight = (origPosn(4) * squishFactor);
	    newY      = (origPosn(2) * squishFactor) + newPlotHeight;
	    set (theAxes, posnPropName, [origPosn(1) newY origPosn(3) newHeight]);
    elseif (strcmpi (where, 'Top') == 1)
        newHeight = (origPosn(4) * squishFactor);
        newY      = (origPosn(2) * squishFactor);
        set (theAxes, posnPropName, [origPosn(1) newY origPosn(3) newHeight]);
    elseif (strcmpi (where, 'Left') == 1)
        newWidth = (origPosn(3) * squishFactor);
        newX     = (origPosn(1) * squishFactor) + newPlotWidth;
        set (theAxes, posnPropName, [newX origPosn(2) newWidth origPosn(4)]);
    elseif (strcmpi (where, 'Right') == 1)
        newWidth = (origPosn(3) * squishFactor);
        newX     = (origPosn(1) * squishFactor);
        set (theAxes, posnPropName, [newX origPosn(2) newWidth origPosn(4)]);
    end
end


%%---------------------------------------------------
%% Finish the new axes:

if (isprop (ax, 'OuterPosition'))
     set (ax, 'OuterPosition', ...
	  [newPlotX newPlotY newPlotWidth newPlotHeight]);
else
     set (ax, 'Position', ...
	  [newPlotX newPlotY newPlotWidth newPlotHeight]);
end
plottoolfunc ('setSelection', fig, {ax});
hold (ax, 'all');
title (ax, '');
hax = handle(ax);
listener = handle.listener(hax,'ObjectBeingDestroyed',...
                           @doDeleteAction);
setappdata(ax,'SubplotDeleteListener',listener);

function doDeleteAction(h, eventData)
pos = get(h,'OuterPosition');
fig = ancestor(h,'figure');
children = findobj (fig, 'type', 'axes');

% only rescale other axes if the one being deleted stretches all
% the way vertically or horizontally
if (any(pos(3:4) > 1-10*eps)) && (length(children) > 1)
  nchildren = length(children);

  xscale = 1;
  if (pos(3) < 1)
    xscale = nchildren/(nchildren-1);
  end

  yscale = 1;
  if (pos(4) < 1)
    yscale = nchildren/(nchildren-1);
  end

  for i = 1:nchildren
    theAxes = handle(children(i));
    posnPropName = 'OuterPosition';
    origPosn = get (theAxes, posnPropName);
    if (xscale > 1) && (origPosn(1) < pos(1))
      newWidth  = origPosn(3) * xscale;
      newX      = origPosn(1) * xscale;
      set (theAxes, posnPropName, [newX origPosn(2) newWidth origPosn(4)]);
    elseif (xscale > 1) && (origPosn(1) > pos(1))
      newWidth  = origPosn(3) * xscale;
      newX      = 1 - (1 - origPosn(1)) * xscale;
      set (theAxes, posnPropName, [newX origPosn(2) newWidth origPosn(4)]);
    end
    if (yscale > 1) && (origPosn(2) < pos(2))
      newHeight = origPosn(4) * yscale;
      newY      = origPosn(2) * yscale;
      set (theAxes, posnPropName, [origPosn(1) newY origPosn(3) newHeight]);
    elseif (yscale > 1) && (origPosn(2) > pos(2))
      newHeight = origPosn(4) * yscale;
      newY      = 1 - (1 - origPosn(2)) * yscale;
      set (theAxes, posnPropName, [origPosn(1) newY origPosn(3) newHeight]);
    end
  end

end
