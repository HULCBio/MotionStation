function [x_str, y_str, xcheck, ycheck] = bfitdatastatupdate(figHandle, newdataHandle)
% BFITDATASTATUPDATE update to a new data set for the open Data Statistics GUI.
%    [XSTR, YSTR, XCHECK, YCHECK] = BFITDATASTATUPDATE(FIGH, NEWDATAHANDLE) changes
%    the current data to NEWDATAHANDLE plotted in figure FIGH.  The data statistics
%    for the new data are computed, or looked up if the new data has been "current data"
%    previously, and returned in XSTR and YSTR.  XCHECK and YCHECK tell which check boxes
%    where checked before when NEWDATAHANDLE was the current data -- these data statistic
%    plots are replotted.  The old current data statistics plots are removed and 
%    recorded in appdata. 

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/15 04:06:09 $

currdata = getappdata(figHandle,'Data_Stats_Current_Data');
[xstatsH, ystatsH] = bfitdatastatremovelines(figHandle,currdata);
% Update appdata for stats handles so legend can redraw
setappdata(currdata, 'Data_Stats_X_Handles', xstatsH);
setappdata(currdata, 'Data_Stats_Y_Handles', ystatsH);
[x_str, y_str, xcheck, ycheck] = bfitdatastatselectnew(figHandle, newdataHandle);
% Update current data appdata
setappdata(figHandle,'Data_Stats_Current_Data', newdataHandle);


