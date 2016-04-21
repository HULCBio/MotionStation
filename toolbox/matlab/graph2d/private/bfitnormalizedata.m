function [evalresultsx,evalresultsy, coeffresidstrings] = bfitnormalizedata(checkon,datahandle)
% BFITNORMALIZEDATA normalize the data

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/15 04:06:13 $

if checkon
    xdata = get(datahandle,'xdata');
    normalized = [mean(xdata); std(xdata)];
    setappdata(datahandle,'Basic_Fit_Normalizers',normalized);
else
    normalized = [];
    setappdata(datahandle,'Basic_Fit_Normalizers',normalized);
end

guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
if ~isequal(guistate.normalize,checkon)
    % reset scaling warning flag so it will occur
     setappdata(datahandle,'Basic_Fit_Scaling_Warn',[]);
end
guistate.normalize = checkon;
setappdata(datahandle,'Basic_Fit_Gui_State', guistate);

axesH = get(datahandle,'parent');
figHandle = get(axesH, 'parent');
[fithandles, residhandles, residinfo] = bfitremovelines(figHandle,datahandle,0);
% Update appdata for line handles so legend can redraw
setappdata(datahandle, 'Basic_Fit_Handles',fithandles);
setappdata(datahandle, 'Basic_Fit_Resid_Handles',residhandles);
setappdata(datahandle, 'Basic_Fit_Resid_Info',residinfo);

% Get newdata info
[axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,currentfit,coeffresidstrings] = ...
    bfitselectnew(figHandle, datahandle);

