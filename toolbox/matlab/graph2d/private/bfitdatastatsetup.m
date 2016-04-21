function [x_str, y_str] = bfitdatastatsetup(fighandle,datahandle)
% BFITDATASTATSETUP setup appdata for data set in Data Statistics GUI.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 04:07:03 $

infarray = repmat(inf,1,5);
axesH = get(datahandle,'parent');

% for this axes, store it in the appdata of the fighandle: sharing with Basic Fit
axeshandles = getappdata(fighandle,'Basic_Fit_Axes_Handles'); 
if isempty(axeshandles) | ~any(axesH == axeshandles)
    axeshandles(end + 1) = axesH;
    setappdata(fighandle,'Basic_Fit_Axes_Handles', axeshandles);
end

% for this data set, store it in the appdata of the figure
datasethandles = getappdata(fighandle,'Data_Stats_Data_Handles'); 
if isempty(datasethandles) | ~any(datahandle == datasethandles)
    datasethandles(end + 1) = datahandle;
    setappdata(fighandle,'Data_Stats_Data_Handles', datasethandles);
end
setappdata(fighandle,'Data_Stats_Current_Data',datahandle);

% place to store stats
setappdata(datahandle,'Data_Stats_X',[]);
setappdata(datahandle,'Data_Stats_Y',[]);

% place to store handles of lines plotted, and
% index vector of who is currently plotted
setappdata(datahandle,'Data_Stats_X_Handles',infarray);  % array of handles of plots
setappdata(datahandle,'Data_Stats_Y_Handles',infarray);  % array of handles of plots
setappdata(datahandle,'Data_Stats_X_Showing', false(1,5)); % array of logicals: 1 if showing
setappdata(datahandle,'Data_Stats_Y_Showing', false(1,5)); % array of logicals: 1 if showing

% Add the data to the legend and put note that this is data
statappdata.type = 'data';
statappdata.index = [];
setappdata(datahandle,'bfit',statappdata);

% The following instance property probably has already been set. Just in case it hasn't
% though, set it now
if isempty(findprop(handle(datahandle), 'Basic_Fit_Copy_Flag'))
	p = schema.prop(handle(datahandle), 'Basic_Fit_Copy_Flag', 'MATLAB array');
	p.AccessFlags.Copy = 'off';
end

bfitcreatelegend(axesH);
% compute data stats to return
[x_str, y_str] = bfitcomputedatastats(datahandle);

