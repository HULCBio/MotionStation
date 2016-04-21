function setdatamarkers(hcbo,eventStruct)
%SETDATAMARKERS Set interactive data markers. 
%   SETDATAMARKERS is used as the 'ButtonDownFcn' of a line
%   in order to enable Data Markers.

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/11/21 15:36:18 $ 

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

% Change Normalized Frequency  (\times\pi rad/sample)
% to "Normalized Frequency" because of sprintf
if strncmp(xlbl,'Normalized Frequency',10),
    xlbl = 'Normalized Frequency';
end

str{1,1} = sprintf('%s: %0.7g',xlbl,h.X);
str{end+1,1} = sprintf('%s: %0.7g',ylbl,h.Y);

% [EOF]
