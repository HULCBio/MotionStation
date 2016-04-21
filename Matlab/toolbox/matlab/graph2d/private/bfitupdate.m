function [axesCount,fitschecked,bfinfo, evalresultsstr,evalresultsx,evalresultsy, ...
        currentfit, coeffresidstrings] = bfitupdate(figHandle, newdataHandle, numberpanes)
% BFITUPDATE update to a new data set for the open Basic Fit GUI.
%    [AXESCOUNT,FITSCHECKED,BFINFO,EVALRESULTSSTR,EVALRESULTSX,EVALRESULTSY,...
%    CURRENTFIT,COEFFRESIDSTRINGS] = BFITUPDATE(FIGH, NEWDATAHANDLE) changes the 
%    current data to NEWDATAHANDLE plotted in figure FIGH and returns these values:   
%    AXESCOUNT is how many data axes exist.
%    FITSCHECKED is which fits are checked in the gui.
%    BFINFO is info about the state of the GUI (see BFITSETUP for details).
%    EVALRESULTSSTR is the string evaluated to get EVALRESULTSX, EVALRESULTSY.
%    CURRENTFIT is the current fit to show in panel 2 of the gui.
%    COEFFRESIDSTRINGS is the string of coefficients and residual information in panel 2.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/15 04:06:15 $

% save the number of panes for the current data
datahandle = getappdata(figHandle,'Basic_Fit_Current_Data');
guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
guistate.panes = numberpanes;
setappdata(datahandle,'Basic_Fit_Gui_State', guistate);

[fithandles, residhandles, residinfo] = bfitremovelines(figHandle,datahandle);
% Update appdata for line handles so legend can redraw
setappdata(datahandle, 'Basic_Fit_Handles',fithandles);
setappdata(datahandle, 'Basic_Fit_Resid_Handles',residhandles);
setappdata(datahandle, 'Basic_Fit_Resid_Info',residinfo);

% Get newdata info
[axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,currentfit,coeffresidstrings] = ...
    bfitselectnew(figHandle, newdataHandle);
% Update current data appdata
setappdata(figHandle,'Basic_Fit_Current_Data', newdataHandle);

% temporary fix
if isempty(currentfit)
    currentfit = -1;
end