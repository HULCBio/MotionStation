function [xstatsH, ystatsH] = bfitdatastatremovelines(figHandle, currdata)
% BFITDATASTATREMOVELINES remove data stat lines for the current data.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/15 04:05:45 $

xstatsH = [];
ystatsH = [];

% for data now showing, remove plots and update appdata
xstatsshow = getappdata(currdata,'Data_Stats_X_Showing');

% xstatsshow empty means the datastat GUI was never used on this data
if ~isempty(xstatsshow)

    bfitlistenoff(figHandle)

    ystatsshow = getappdata(currdata,'Data_Stats_Y_Showing');
    xstatsH = getappdata(currdata,'Data_Stats_X_Handles');
    ystatsH = getappdata(currdata,'Data_Stats_Y_Handles');
    
    % Delete plots, update handles to Inf
    % Don't update "Showing" appdata since that tells us what to replot if needed
    %  (i.e. what checkboxes were checked)
    for i = find(xstatsshow)
        if ishandle(xstatsH(i))
            delete(xstatsH(i));
        end
        xstatsH(i) = Inf;
    end
    for i = find(ystatsshow)
        if ishandle(ystatsH(i))
            delete(ystatsH(i));
        end
        ystatsH(i) = Inf;
    end
    
    bfitlistenon(figHandle)
end


