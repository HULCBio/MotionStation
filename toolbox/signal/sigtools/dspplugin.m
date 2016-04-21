function fcns = dspplugin
%DSPPLUGIN Plugin functions for the Signal Processing blockset

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/13 00:31:35 $

fcns.sidebar = @installdspfwiz;

% --------------------------------------------------------------------
function installdspfwiz(hSB)

% icons = load('dspblksgui_icons');
icons = load('panel_icons'); % As long as this is in signal use panel_icons.
opts.tooltip = 'Realize Model';

opts.icon    = color2background(icons.dspfwiz); 
opts.csh_tag = 'fdatool_realizemdl_frame';
% opts.icon = icons.dspfwiz; % See G122899

registerpanel(hSB, @fdatool_dspfwiz, 'dspfwiz', opts);

addmenu(getfdasessionhandle(get(hSB, 'FigureHandle')), [1 7], ...
    'Export To Simulink Model', {@setpanel_cb, hSB, 'dspfwiz'}, 'dspfwiz_menuitem');

% --------------------------------------------------------------------
function hF = fdatool_dspfwiz(hSB)

hFig = get(hSB, 'FigureHandle');
hFDA = getfdasessionhandle(hFig);
hF   = dspblksgui.dspfwiz(getfilter(hFDA));
sz   = fdatool_gui_sizes(hFDA);

render(hF, hFig, sz.defaultpanel-[-sz.hfus 0 0 sz.ffs]);
resizefcn(hF, [sz.fig_w sz.fig_h] * sz.pixf);

addlistener(hFDA, 'FilterUpdated', {@filter_listener, hF});
l = handle.listener(hF, hF.findprop('Filter'), 'PropertyPostSet', ...
    {@fwiz_filter_listener, hF});
set(l, 'CallbackTarget', hFDA);
sigsetappdata(hFDA, 'plugins', 'dspfwiz', 'listeners', l);

% ----------------------------------------------------------------
function setpanel_cb(hcbo, eventStruct, hSB, newpanel)

if nargin == 3, newpanel = get(hcbo, 'Tag'); end
if ischar(newpanel), newpanel = string2index(hSB, newpanel); end

set(hSB, 'CurrentPanel', newpanel);

% --------------------------------------------------------------------
function filter_listener(hFDA, eventData, hF)

% Sync the filter wizard with FDATool.
hF.Filter = getfilter(hFDA);

% --------------------------------------------------------------------
function fwiz_filter_listener(hFDA, eventData, hF)

% If the filterwizard filter changed underneath FDATool, we need to reverse
% sync it.  This can happen when loading an old dspfwiz session.
dspfilt = get(hF, 'Filter');
fdafilt = getfilter(hFDA);
opts.update = 0;

if ~isequal(dspfilt, fdafilt),
    hFDA.setfilter(dspfilt, opts);
end

% [EOF]
