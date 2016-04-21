function startscribepinning(fig,onoff)
%STARTSCRIBEPINNING Turn annotation pinning mode on or off.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $  $

% find the togglebutton
pintogg = uigettoolbar(fig,'Annotation.Pin');

% if no scribeaxes for this figure create one.
scribeaxes = handle(findall(fig,'Tag','scribeOverlay'));
if isempty(scribeaxes)
    scribeaxes = scribe.scribeaxes(fig);
end

% if scribeaxes has no shapes or none of those shapes
% are rectangle, ellipse, textbox or arrow, then there is nothing to pin, so turn
% the pinning toggle off, set the cursor to an arrow and return
if isempty(scribeaxes.Shapes) || ...
        ( ~any(strcmpi('rectangle',get(scribeaxes.Shapes,'shapetype'))) && ...
        ~any(strcmpi('ellipse',get(scribeaxes.Shapes,'shapetype'))) && ...
        ~any(strcmpi('arrow',get(scribeaxes.Shapes,'shapetype'))) && ...
        ~any(strcmpi('line',get(scribeaxes.Shapes,'shapetype'))) && ...
        ~any(strcmpi('textarrow',get(scribeaxes.Shapes,'shapetype'))) && ...
        ~any(strcmpi('doublearrow',get(scribeaxes.Shapes,'shapetype'))) && ...
        ~any(strcmpi('textbox',get(scribeaxes.Shapes,'shapetype'))) )
    if ~isempty(pintogg)
        set(pintogg,'state','off');
    end
    scribecursors(fig,0); 
    return;
end

% if this is being called by the toggle with just a fig arg and the toggle
% is now off, or called from elsewhere with onoff of 'off', turn pinning
% off. Otherwise turn it on.
if (nargin<2 && strcmpi(get(pintogg,'state'),'off')) || ...
        (nargin>1 && ischar(onoff) && strcmpi(onoff,'off'))
    pinning_onoff(fig,scribeaxes,pintogg,'off');
else
    pinning_onoff(fig,scribeaxes,pintogg,'on');
end

%----------------------------------------------------------------%
function pinning_onoff(fig,scribeaxes,pintogg,onoff)

if strcmpi(onoff,'on')
    % set scribeaxes pin mode
    scribeaxes.PinMode = 'on';
    % be sure plotedit is on
    plotedit('on');
    % during pinning disable plotedit windowbuttonmotionfcn for correct
    % cursors
    wbd=get(fig,'WindowButtonMotionFcn');
    setappdata(fig,'ScribeWBState',wbd);
    set(fig,'WindowButtonMotionFcn','');
    scribecursors(fig,10);
else
    scribeaxes.PinMode = 'off';
    % restore plotedit windowbuttonmotionfcn
    wbd = getappdata(fig,'ScribeWBState');
    if ~isempty(wbd)
        set(fig,'WindowButtonMotionFcn',wbd);
    end
    % trun togglebutton off
    if ~isempty(pintogg)
        set(pintogg,'state','off');
    end
    scribecursors(fig,0); 
end

%----------------------------------------------------------------%