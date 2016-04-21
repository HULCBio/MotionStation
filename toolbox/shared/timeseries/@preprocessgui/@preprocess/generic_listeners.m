function generic_listeners(guihandle)
%GENERIC_LISTENERS
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:32:47 $

guihandle.Listeners = [];
% Add update listeners to @exclusion class
listenerProps = {'Boundsactive','Xlow','Xlowstrict','Xhigh','Xhighstrict','Ylow',...
    'Ylowstrict','Yhigh','Yhighstrict','Outlierwindow','Outlierconf','Mexpression',...
    'Flatlinelength','Outliersactive','Flatlineactive','Expressionactive'};
for k=1:length(listenerProps)
    guihandle.Exclusion.addlisteners(handle.listener(guihandle.Exclusion, ...
        guihandle.Exclusion.findprop(listenerProps{k}),'PropertyPostSet', ...
        {@localUpdate guihandle}));
end

% Add update listeners to @filter class
listenerProps = {'Filteractive','filter','Timeconst','Acoeffs','Bcoeffs', ...
    'Detrendactive','Detrendtype','Range','Band'};
for k=1:length(listenerProps)
    guihandle.Filtering.addlisteners(handle.listener(guihandle.Filtering, ...
        guihandle.Filtering.findprop(listenerProps{k}),'PropertyPostSet', ...
        {@localUpdate guihandle}));
end

% Add update listeners to @interp class
listenerProps = {'Rowremove','Interpolate','Rowor','method'};
for k=1:length(listenerProps)
    guihandle.Interp.addlisteners(handle.listener(guihandle.Interp, ...
        guihandle.Interp.findprop(listenerProps{k}),'PropertyPostSet', ...
        {@localUpdate guihandle}));
end

guihandle.addlisteners(handle.listener(guihandle,guihandle.findprop('Visible'), ...
    'PropertyPostSet', {@localVisible guihandle}));
guihandle.addlisteners(handle.listener(guihandle,guihandle.findprop('Column'), ...
    'PropertyPostSet', {@localColumnChange guihandle}));

function localUpdate(es,ed,h)

% Update the gui handle to reflect the property changes
h.refresh


function localVisible(eventSrc, eventData, h)

h.setgraphvisibility(h.visible)

function localColumnChange(es,ed,h)

% Callback to update the HG display if the current 
% selected column proeprty is changed
excl = h.ManExcludedpts{h.Position};
update(h,excl(:),false);

% Update rawdata y limits
if ~isempty(h.Window)
    data = h.Datasets(h.Position).Data;
    y = data(:,h.Column);
    ylim = [min(y) max(y)];
    if ylim(1)==ylim(2)
       ylim = ylim + [-1 1];
    else
       ylim = ylim + .05 * [-1 1] * diff(ylim);
    end
    ax = utgetaxes(h.Window,'rawdata');
    set(ax,'YLim',ylim);
end