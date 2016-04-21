function [x_str, y_str, xcheck, ycheck] = bfitdatastatselectnew(figHandle, newdataHandle)
% BFITDATASTATSELECTNEW Update data stat GUI and figure from current data to new data.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 04:05:47 $

% for new data, was it showing before?
xdatastats = getappdata(newdataHandle,'Data_Stats_X');
if isempty(xdatastats) % new data
    %setup appdata and compute stats: nothing plotted since new data
    [x_str, y_str] = bfitdatastatsetup(figHandle, newdataHandle); % data stats computed
    xcheck = false(1,5);
    ycheck = false(1,5);
else % was showing before: get stats to return, and replot
    x = struct2cell(xdatastats);
    y = struct2cell(getappdata(newdataHandle,'Data_Stats_Y'));
    xstats = cat(1,x{:}); ystats = cat(1,y{:});
    format = '%-12.4g';
    x_str = cellstr(num2str(xstats,format));
    y_str = cellstr(num2str(ystats,format));
    checkon = logical(1);
    stattypes = {'min','max','mean','median','std','range'};
    xcheck = getappdata(newdataHandle,'Data_Stats_X_Showing');
    ycheck = getappdata(newdataHandle,'Data_Stats_Y_Showing');
    for i=find(xcheck)
        bfitplotdatastats(newdataHandle,stattypes{i},'x',checkon)
    end
    for i=find(ycheck)
        bfitplotdatastats(newdataHandle,stattypes{i},'y',checkon)
    end
	if ~any(ycheck) & ~any(xcheck)
		axesH = get(newdataHandle,'parent'); % need this in case subplots in figure
		bfitcreatelegend(axesH);
	end
end
