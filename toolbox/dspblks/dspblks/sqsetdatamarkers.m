function sqsetdatamarkers(hcbo,eventStruct)
%SQSETDATAMARKERS Set interactive data markers. 
%   SQSETDATAMARKERS is used as the 'ButtonDownFcn' of a line
%   in order to enable Data Markers.

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/06/03 15:53:30 $ 

% Cache axes properties because we need to change
% them in order to use sptlinescan.m
ax = get(hcbo,'Parent');

% Call the data marker engine
hdm = sptlinetip(hcbo);
hdm.TipFcn = {@string_fcn, hdm, ax};

%-------------------------------------------------------------------
function str = string_fcn(h,ax)
% Get the analysis specific strings to display.
hxlbl = get(ax,'Xlabel'); xlbl = get(hxlbl,'String'); 
hylbl = get(ax,'Ylabel'); ylbl = get(hylbl,'String'); 

% Truncate the original x-label
if strncmp(xlbl,'Final',1),
    xlbl = 'Boundary Points';
else%if strncmp(xlbl,'Number',1),
    xlbl = 'Iterations';    
end
% Truncate the original y-label
if strncmp(ylbl,'Final',1),
    ylbl = 'Codewords';
else%if strncmp(ylbl,'Mean',1),
    ylbl = 'MSE';    
end
str{1,1} = sprintf('%s: %0.7g',xlbl,h.X);
str{end+1,1} = sprintf('%s: %0.7g',ylbl,h.Y);

% [EOF]
