function hX = fdatool_xformtool(hSB)
%FDATOOL_XFORMTOOL XFormTool for FDATool

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/13 00:32:34 $

hFig = get(hSB, 'FigureHandle');
hFDA = getfdasessionhandle(hFig);
Hd   = getfilter(hFDA, 'wfs');
hX   = fdtbxgui.xformtool(dfilt.dffir);
sz   = fdatool_gui_sizes(hFDA);

setfs(hX, Hd.Fs);

render(hX, hFig, sz.defaultpanel);
resizefcn(hX, [sz.fig_w sz.fig_h]*sz.pixf);

listener = [handle.listener(hFDA, 'FilterUpdated', {@filterupdated_eventcb, hX}), ...
        handle.listener(hX, 'FilterTransformed', @filtertransformed_eventcb)];
set(listener, 'CallbackTarget', hFDA);

setappdata(hFDA, 'XFormToolListeners', listener);

filterupdated_eventcb(hFDA, [], hX);

% -------------------------------------------------------------
function setfs(hX, fs)

if isempty(fs),
    fs.value = [];
    fs.units = 'Normalized (0 to 1)';
else
    [fs.value, m, fs.units] = engunits(fs);
    fs.units = [fs.units 'Hz'];
end

set(hX, 'CurrentFs', fs);

% -------------------------------------------------------------
function filterupdated_eventcb(hFDA, eventData, hX)

Hd   = getfilter(hFDA, 'wfs');

if isa(Hd.Filter, 'dfilt.dfilt')
    hX.Filter = Hd.Filter;
    setfs(hX, Hd.Fs);
    enab = 'on';
else
    enab = 'off';
end

set(hX, 'Enable', enab);

% -------------------------------------------------------------
function filtertransformed_eventcb(hFDA, eventData)

filt = get(eventData, 'Data');

opts.fcnhndl = @setexternflag;
opts.source  = 'Transformed';
opts.name    = get(getfilter(hFDA, 'wfs'), 'Name');
opts.mcode   = genmcode(eventData.Source);

hFDA.setfilter(filt, opts);

% [EOF]
