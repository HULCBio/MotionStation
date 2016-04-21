function h = fdatool_mfilttool(hSB)
%FDATOOL_MFILTTOOL   

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/13 00:32:30 $

hFig = get(hSB, 'FigureHandle');
hFDA = getfdasessionhandle(hFig);
h   = fdtbxgui.mfiltdesignpanel;
sz   = fdatool_gui_sizes(hFDA);

set(h, 'CurrentFilter', getfilter(hFDA));

render(h, hFig, sz.defaultpanel);
resizefcn(h, [sz.fig_w sz.fig_h]*sz.pixf);

l = [ ...
        handle.listener(h, 'FilterDesigned', @filterdesigned_listener); ...
        handle.listener(hFDA, 'FilterUpdated', {@filterupdated_listener, h}); ...
    ];
set(l, 'CallbackTarget', hFDA);
setappdata(hFDA, 'mfiltpanellisteners', l);

% -------------------------------------------------------------------------
function filterdesigned_listener(hFDA, eventData)

h = get(eventData, 'Source');

data = get(eventData, 'Data');

opts.mcode      = data.mcode;
opts.source     = 'Multirate Design';
opts.name       = get(data.filter, 'FilterStructure');

% If the current implemntation is to use the current filter then we do not
% want to reset the mcode.  Just continue writing it.
if ~strcmpi(h.Implementation, 'current')
    opts.resetmcode = true;
end

if strcmpi(h.frequencyUnits, 'normalized (0 to 1)')
    opts.fs = [];
else
    opts.fs = convertfrequnits(evaluatevars(h.Fs), h.FrequencyUnits, 'hz');
end

setfilter(hFDA, data.filter, opts);


% -----------------------------------------------------------------------
function filterupdated_listener(hFDA, eventData, h)

fmb = get(hFDA, 'filtermadeby');
if ~strncmpi(fmb, 'multirate design', 16),
    set(h, 'isDesigned', false);
end
set(h, 'CurrentFilter', getfilter(hFDA));

% [EOF]
