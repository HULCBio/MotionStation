function bfitdatastatappdatasetup(datahandle)
% BFITDATASTATAPPDATASETUP setup for a data set anything needed for the Data Statisics GUI.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/15 04:07:01 $

infarray = repmat(inf,1,5);

% place to store stats
setappdata(datahandle,'Data_Stats_X',[]);
setappdata(datahandle,'Data_Stats_Y',[]);

% place to store handles of lines plotted, and
% index vector of who is currently plotted
setappdata(datahandle,'Data_Stats_X_Handles',infarray);  % array of handles of plots
setappdata(datahandle,'Data_Stats_Y_Handles',infarray);  % array of handles of plots
setappdata(datahandle,'Data_Stats_X_Showing', false(1,5)); % array of logicals: 1 if showing
setappdata(datahandle,'Data_Stats_Y_Showing', false(1,5)); % array of logicals: 1 if showing

axesH = get(datahandle,'parent');
figureH = get(axesH, 'parent');

% turn the figure into double-buffering
% should we save this state and restore? and if we changed it, throw a warning??
set(figureH,'doublebuffer','on');

% Add the data to the legend and put appdata on the data
statappdata.type = 'data';
statappdata.index = [];
setappdata(datahandle,'bfit',statappdata);

% The following instance property probably has already been set. Just in case it hasn't
% though, set it now
if isempty(findprop(handle(datahandle), 'Basic_Fit_Copy_Flag'))
	p = schema.prop(handle(datahandle), 'Basic_Fit_Copy_Flag', 'MATLAB array');
	p.AccessFlags.Copy = 'off';
end

bfitcreatelegend(axesH)

