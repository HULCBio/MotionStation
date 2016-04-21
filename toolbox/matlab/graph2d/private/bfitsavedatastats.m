function bfitsavedatastats(datahandle)
% BFITSAVEDATASTATS Save x and y data statistics to the workspace. 
%
%   BFITSAVEDATASTATS(DATAHANDLE) sends the x stats and y stats of
%   the current data DATAHANDLE to the export2wsdlg function 
%   along with appropriate names for the checkbox labels and default
%   variable names.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2002/10/24 02:10:42 $

xvalue = getappdata(datahandle,'Data_Stats_X');
yvalue = getappdata(datahandle,'Data_Stats_Y');

checkLabels = {'Save X stats to a MATLAB struct named:', ...
               'Save Y stats to a MATLAB struct named:'};
items = {xvalue, yvalue};
varNames = {'xstats', 'ystats'};

export2wsdlg(checkLabels, varNames, items, 'Save Statistics to Workspace');


