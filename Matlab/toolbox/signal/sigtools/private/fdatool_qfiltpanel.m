function hQP = fdatool_qfiltpanel(hSB)
%FDATOOL_QFILTPANEL initializes the QFILTPANEL for FDATOOL.
%   hQP = FDATOOL_QFILTPANEL(hSB) returns a FDTBXGUI.QFILTPANEL object hQP,
%   given SIGGUI.SIDEBAR object hSB.

%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/13 00:32:32 $

% Turn warning off so quantizing doesn't throw warnings
wrn = warning('off');
if isa(hSB, 'sigtools.fdatool'),
    hFDA = hSB;
    hFig = get(hFDA, 'FigureHandle');
else
    hFig = get(hSB, 'FigureHandle');
    hFDA = getfdasessionhandle(hFig);
end

% The first time this is called, we haven't established a default qfilt yet,
% so we use the default here.
if sigisappdata(hFDA, 'qpanel', 'handle'),
    hQP = siggetappdata(hFDA, 'qpanel', 'handle');
else
    Hd = lclcopy(getfilter(hFDA));
    hQP = fdtbxgui.qtool(Hd);
    set(hQP, 'DSPMode', getflags(hFDA, 'calledby', 'dspblks'));
    sigsetappdata(hFDA, 'qpanel', 'handle', hQP);

    sz = fdatool_gui_sizes(hFDA);

    render(hQP, hFig, sz.defaultpanel);
    resizefcn(hQP, [sz.fig_w, sz.fig_h]*sz.pixf);

    attachlisteners(hFDA, hQP);
end

% Restore warning state.
warning(wrn)

% ------------------------------------------------------------
function attachlisteners(hFDA, hQP)
% Events that update the filter.
%
%   If FDATool updates the filter, then we need to set the qfilt panel
%   filter if the quantization switch is on.
%
%   The qfilt panel switch turning on should convert the FDA filter to qfilt Hq,
%   set the qfilt panel qfilt Hq, and set the FDA filter to qfilt Hq.
%
%   The qfilt panel switch turning off should set the FDA filter to dfilt Hd by
%   converting the qfilt panel qfilt to dfilt.
%
%   The qfilt being updated by the qfilt panel would only happen if the qfilt
%   panel switch value is true, so set the FDA filter to qfilt.  By only
%   listening to the qfilt changing, we don't have to listen to the apply buttons.

listeners = [ ...
    handle.listener(hFDA, hFDA.findprop('Filter'), ...
    'PropertyPostSet', @filter_eventcb); ...
    handle.listener(hQP, 'NewSettings', @newsettings_listener); ...
    ];

set(listeners, 'CallbackTarget', [hQP, hFDA]);

sigsetappdata(hFDA, 'qpanel', 'listeners', listeners);


% ------------------------------------------------------------
function filter_eventcb(callbacktarget, eventData)
% Filter in FDATOOL has been changed.  Now reflect that change in the qfilt
% panel. 

hQP = callbacktarget(1);
hFDA = callbacktarget(2);

%     if isempty(strfind(hFDA.filtermadeby, 'quantized')),
%         Hd = copy(getfilter(hFDA));
Hd = getfilter(hFDA);
if ~isempty(strfind(hFDA.filtermadeby, 'converted')),
    l = siggetappdata(hFDA, 'qpanel', 'listeners');
    set(l, 'Enabled', 'Off');
    set(hQP, 'Arithmetic', 'double');
    set(l, 'Enabled', 'On');
end
if Hd ~= hQP.Filter,
    Hd = lclcopy(Hd);
    hQP.Filter = Hd;
end

% ------------------------------------------------------------
function newsettings_listener(callbacktarget, eventData)

hQP  = callbacktarget(1);
hFDA = callbacktarget(2);

if isquantized(hQP.Filter)
    opts.source = sprintf('%s (quantized)', strrep(hFDA.filterMadeBy, ' (quantized)', ''));
else
    opts.source = strrep(hFDA.filterMadeBy, ' (quantized)', '');
end
opts.source = strrep(opts.source, ' (converted)', ''); % Make sure that converted is gone.
opts.mcode  = genmcode(hQP);

l = siggetappdata(hFDA, 'qpanel','listeners');

set(l, 'Enabled','Off');

setfilter(hFDA, lclcopy(hQP.Filter), opts);

set(l, 'Enabled','On');

% ------------------------------------------------------------
function fmb = rmquantized(hFDA)

fmb = get(hFDA, 'FilterMadeBy');
indx = strfind(lower(fmb), ' (quantized)');
if ~isempty(indx),
    fmb(indx:indx+11) = [];
end

% ------------------------------------------------------------
function Hd = lclcopy(Hd)

mi = [];
if isprop(Hd, 'MaskInfo'),
    mi = get(Hd, 'MaskInfo');
end
Hd = copy(Hd);
if ~isempty(mi)
    p = adddynprop(Hd, 'MaskInfo', 'mxArray');
    set(p, 'Visible', 'Off');
    set(Hd, 'MaskInfo', mi);
end

% [EOF]
