function plottools (varargin)
% PLOTTOOLS  Show or hide the plot-editing tools for a figure.
%    PLOTTOOLS ON shows all the tools for the current figure.
%    PLOTTOOLS OFF hides all the tools.
%    PLOTTOOLS TOGGLE toggles the visibility of the tools.
%    PLOTTOOLS with no arguments is the same as ON.
% 
% The first argument may be the handle to a figure, like so:
%    PLOTTOOLS (h, 'on')
%
% The last argument may be the name of a specific component, like so:
%    PLOTTOOLS ('on', 'figurepalette') or
%    PLOTTOOLS (h, 'on', 'figurepalette')
% The available components are named 'figurepalette', 'plotbrowser',
% and 'propertyeditor'.
%
% See also FIGUREPALETTE, PLOTBROWSER, and PROPERTYEDITOR.

%   Copyright 1984-2004 The MathWorks, Inc.



% plottools ('on')
% plottools ('on', 'figurepalette')
% plottools (h, 'on', 'figurepalette')
% plottools (h, 'on')
% plottools (h, 'on', 'figurepalette')

error (nargchk (0,3,nargin))

% Defaults:
fig = [];
action = 'on';
comp = 'all';

% Use the arguments:
if nargin == 1 
    if ishandle (varargin{1})
        fig = varargin{1};
    elseif ischar (varargin{1})
        action = varargin{1};
    end
elseif nargin == 2         % either (h, 'on') or ('on', 'panel')
    if ishandle (varargin{1})
        fig = varargin{1};
        action = varargin{2};
    elseif ischar (varargin{1})
        action = varargin{1};
        comp = varargin{2};
    end
elseif nargin == 3
    fig = varargin{1};
    action = varargin{2};
    comp = varargin{3};
end

if isempty(fig)
  fig = gcf;
  drawnow;
end

if isempty (get (fig, 'JavaFrame'))
    error (sprintf ('The plot tools require Java figures to be enabled!'));
end

% Do it:
if (strcmp (comp, 'all') ~= 0)
    oldptr = get (fig, 'Pointer');
    set (fig, 'Pointer', 'watch');
    showplottool (fig, action, 'figurepalette');
    showplottool (fig, action, 'plotbrowser');
    showplottool (fig, action, 'propertyeditor');
    set (fig, 'Pointer', oldptr);
else
    showplottool (fig, action, comp);
end

