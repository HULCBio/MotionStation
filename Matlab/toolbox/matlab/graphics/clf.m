function ret_fig = clf(varargin)
%CLF Clear current figure.
%   CLF deletes all children of the current figure with visible handles.
%
%   CLF RESET deletes all children (including ones with hidden
%   handles) and also resets all figure properties, except Position
%   and Units, to their default values.
%
%   CLF(FIG) or CLF(FIG,'RESET') clears the single figure with handle FIG.
%
%   See also CLA, RESET, HOLD.

%   CLF(..., HSAVE) deletes all children except those specified in
%   HSAVE.
%
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.22.4.5 $  $Date: 2004/04/10 23:28:37 $

if nargin>0 & length(varargin{1})==1 & ishandle(varargin{1}) & strcmp(lower(get(varargin{1},'Type')),'figure')
    % If first argument is a single figure handle, apply CLF to it
    fig = varargin{1};
    extra = varargin(2:end);
elseif nargin>0 & length(varargin{1})==1 & ~ishandle(varargin{1})
    error('Invalid figure handle');
else
    % Default target is current figure
    fig = gcf;
    extra = varargin;
end

% annotations are cleared by hand since the handle is hidden
scribeax = getappdata(fig,'Scribe_ScribeOverlay');
if ishandle(scribeax), 
  delete(get(handle(scribeax),'Shapes'));
end

% if IntegerHandle is 'off', then a numeric handle becomes invalid when RESET
% is called in CLO.
fig_was_numeric = true;
if isnumeric(fig)
    fig_handle = handle(fig);
else
    fig_was_numeric = false;
end
    
clo(fig, extra{:});

% cast back to double
if fig_was_numeric
    fig = double(fig_handle);
end

% cause a complete redraw of the figure, so that movie frame remnants
% are cleared as well
refresh(fig)

% now that IntegerHandle can be changed by reset, make sure
% we're returning the new handle:
if (nargout ~= 0)
    ret_fig = fig;
end
