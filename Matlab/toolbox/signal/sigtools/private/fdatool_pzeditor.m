function h = fdatool_pzeditor(hSB)
%FDATOOL_PZEDITOR Install the pole/zero editor in FDATool.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/13 00:32:31 $

hFDA = getfdasessionhandle(hSB.FigureHandle);
sz = fdatool_gui_sizes(hFDA);

status(hFDA, 'Loading the Pole Zero Editor');

h = siggui.pzeditor(getfilter(hFDA));

status(hFDA, 'Loading the Pole Zero Editor ...');

render(h, hSB.FigureHandle, sz.panel-[-sz.ffs -sz.ffs 2*sz.ffs 2*sz.ffs]);

status(hFDA, 'Loading the Pole Zero Editor ... done');

attachlisteners(hFDA, h);

% --------------------------------------------------------------
function attachlisteners(hFDA, h)

l = [ ...
    handle.listener(hFDA, 'FilterUpdated', {@lclfilterupdated_listener, hFDA}); ...
    handle.listener(h, 'NewFilter', {@lclnewfilter_listener, hFDA}); ...
    handle.listener(h, 'ButtonUp', {@lclbuttonup_listener, hFDA}); ...
    handle.listener(h, h.findprop('Visible'), 'PropertyPreSet', ...
    {@lclvisible_listener, hFDA});
    ];

set(l, 'CallbackTarget', h);
setappdata(hFDA, 'PZEditor', l);

% --------------------------------------------------------------
function lclbuttonup_listener(h, eventData, hFDA)

l = getappdata(hFDA, 'PZEditor');
set(l, 'Enabled', 'Off');

opts.source     = 'Pole/Zero Editor';

setfilter(hFDA, get(h, 'Filter'), opts);

set(l, 'Enabled', 'On');

% --------------------------------------------------------------
function lclvisible_listener(h, eventData, hFDA)

% Make sure that before we turn the panel visible that the filters are
% synced.
if strcmpi(get(eventData, 'NewValue'), 'on')
    if getappdata(hFDA, 'pzeditor_crumb')
        syncfilter(h, hFDA);
    end
end

% --------------------------------------------------------------
function lclfilterupdated_listener(h, eventData, hFDA)

% Disable and enable the listeners so that we won't get a double update
% from the pzeditor sending out a new filter (which is the same as the old
% filter).

% Don't do anything if the panel is invisible.  Too expensive.
if strcmpi(h.Visible, 'On'),
    syncfilter(h, hFDA);
else
    setappdata(hFDA, 'pzeditor_crumb', true);
end

% --------------------------------------------------------------
function lclnewfilter_listener(h, eventData, hFDA)

l = getappdata(hFDA, 'PZEditor');
set(l, 'Enabled', 'Off');

opts.source     = 'Pole/Zero Editor';
opts.fastupdate = true;

setfilter(hFDA, get(h, 'Filter'), opts);

set(l, 'Enabled', 'On');

% --------------------------------------------------------------
function syncfilter(h, hFDA)

l = getappdata(hFDA, 'PZEditor');
set(l, 'Enabled', 'Off');

filtobj = getfilter(hFDA);

try
    set(h, 'Filter', filtobj);
    set(h, 'Enable', hFDA.Enable);
catch
    set(h, 'Enable', 'Off');
end

set(l, 'Enabled', 'On');
setappdata(hFDA, 'pzeditor_crumb', false);

% [EOF]
