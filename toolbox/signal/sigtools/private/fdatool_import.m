function hIT = fdatool_import(hSB)
%FDATOOL_IMPORT Add the import panel to FDATool
%   FDATOOL_IMPORT(hSB) Interface function between FDATool and the import panel.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.5 $  $Date: 2004/04/13 00:32:29 $

hFig = get(hSB,'FigureHandle');
hFDA = getfdasessionhandle(hFig);
hIT  = siggui.import;

sz = fdatool_gui_sizes(hFDA);
render(hIT, hFig, sz.panel);

% resizefcn(hIT, [sz.fig_w sz.fig_h]*sz.pixf);

l = handle.listener(hIT, 'FilterGenerated', {@filtergenerated_eventcb, hFDA});
setappdata(hFig, 'ImportFilterGeneratedListener', l);

setunits(hIT, 'Normalized');

% ------------------------------------------------------------------
function filtergenerated_eventcb(hIT, eventData, hFDA)

data = get(eventData, 'Data');
filtobj = data.filter;

options.fs         = data.fs;
options.source     = 'Imported'; 
options.fcnhndl    = @setimportedflag; % This line will be eliminated when all panels are objects 
options.update     = 1;
options.mcode      = genmcode(hIT);
options.resetmcode = true;
options.name       = get(filtobj, 'FilterStructure');

try
    startrecording(hFDA, 'Import Filter');
    hFDA.setfilter(filtobj,options);
    stoprecording(hFDA);
catch
    destroyrecording(hFDA);
    senderror(hFDA);
end

% [EOF]
