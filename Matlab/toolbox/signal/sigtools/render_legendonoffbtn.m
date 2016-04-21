function hlegendtoolbar = render_legendonoffbtn(hToolbar, callback, varargin)
%RENDER_LEGENDONOFFBTN Render the Legend On/Off toggle button
%   RENDER_LEGENDONOFFBTN(H, CB) Render the Legend On/Off togglebutton to
%   the uitoolbar H.  CB will be used as the clicked callback.
%
%   RENDER_LEGENDONOFFBTN(H, CB, ON_CB, OFF_CB) ON_CB will be used as the
%   OnCallback and OFF_CB will be used as the OffCallback.

%   Author(s): P. Costa & J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/11/21 15:36:04 $

error(nargchk(2,4,nargin));

on_cb = @local_cb;
off_cb = @local_cb;
if nargin > 2,
    on_cb = varargin{1};
end
if nargin > 3,
    off_cb = varargin{2};
end

% Load the MAT-file with the icon
icons = load('fatoolicons');

% Render the ToggleButtons
hlegendtoolbar = uitoggletool('Cdata',icons.icons.legend,...
    'Parent',          hToolbar,...
    'ClickedCallback', callback,...
    'OnCallBack',      on_cb,...
    'OffCallBack',     off_cb,...
    'Tag',             'legendonoff',...
    'Tooltipstring',   xlate('Turn Legend On'),...
    'Separator',       'On');

% --------------------------------------------------------
function local_cb(hcbo, eventStruct)

state = get(hcbo, 'State');

if strcmpi(state, 'on')
    state = 'Off';
else
    state = 'On';
end

set(hcbo,'TooltipString', ['Turn Legend ' state]);

% [EOF]
