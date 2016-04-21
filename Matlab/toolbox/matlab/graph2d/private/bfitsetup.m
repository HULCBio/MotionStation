function [axesCount,fitsShowing,bfinfo,evalresults,currentfit] = bfitsetup(fighandle,datahandle)
% BFITSETUP setup anything needed for the Basic Fitting GUI.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.19.4.2 $  $Date: 2004/04/10 23:26:28 $

emptycell = cell(12,1);
infarray = repmat(inf,1,12);
fitsShowing = false(1,12);
currentfit = [];

guistate.normalize = 0; % Normalize Data checked
guistate.equations = 0; % Show Equations checked
guistate.digits = 2; % Number of Significant Digits
guistate.plotresids = 0; % Plot Residuals checked
guistate.plottype = 0; % Bar Plot (0) or Scatter Plot (1) or Line Plot (2) for residuals
guistate.subplot = 0; % Subplot (0) or Figure (1) for residuals
guistate.showresid = 0; % Show Norm of Residuals checked
guistate.plotresults = 0; % Plot Results checked
guistate.panes = 1; % Number of Panes showing (1,2, or 3)
guistatecell = struct2cell(guistate);
bfinfo = [guistatecell{:}];

evalresults.string = '';
evalresults.x = []; % x values
evalresults.y = []; % f(x) values
evalresults.handle = [];

axesList = findobj(fighandle, 'type', 'axes');
if isempty(axesList)
    axesCount = 0;
else
    taglines = get(axesList,'tag');
    notlegendind = ~(strcmp('legend',taglines));
    axesCount = length(axesList(notlegendind));
end

if isempty(datahandle)
    return;
end

% for this data set, store it in the appdata of the fighandle
datasethandles = getappdata(fighandle,'Basic_Fit_Data_Handles'); 
if isempty(datasethandles) | ~any(datahandle == datasethandles)
    datasethandles(end + 1) = datahandle;
    setappdata(fighandle,'Basic_Fit_Data_Handles', datasethandles);
end
setappdata(fighandle,'Basic_Fit_Current_Data',datahandle);

% Store coefficients, resids, fit handles, and if fit is showing
% each of these are indexed by (fit+1),
% i.e. the spline is index 1, shape-preserving is index 2, the 10th polynomial is index 12
setappdata(datahandle,'Basic_Fit_Coeff', emptycell); % cell array of pp structures
setappdata(datahandle,'Basic_Fit_Resids', emptycell); % cell array of residual arrays
% Handles are Inf when fit is not in the figure whether this is current data or not
setappdata(datahandle,'Basic_Fit_Handles', infarray); % array of handles of fits
% "Showing" is what would be showing if this were the current data, i.e.
%    corresponds to the checkboxes in the GUI
setappdata(datahandle,'Basic_Fit_Showing', fitsShowing); % array of logicals: 1 if showing
% This is which fit is listed in the 2nd Pane (Numerical results): last computed.
setappdata(datahandle,'Basic_Fit_NumResults_',currentfit);

setappdata(datahandle,'Basic_Fit_Gui_State', guistate);

data.x = [];
data.y = [];
setappdata(datahandle,'Basic_Fit_Data',data); % if sorted or normalized, store here

% these are scalars, [] means not showing on the plot
setappdata(datahandle,'Basic_Fit_EqnTxt_Handle', []);  

% these are scalars, [] means not showing on the plot
setappdata(datahandle,'Basic_Fit_ResidTxt_Handle', []); % norm of residuals txt

setappdata(datahandle,'Basic_Fit_Resid_Handles', infarray); % array of handles of residual plots

% evaluate results info
setappdata(datahandle,'Basic_Fit_EvalResults',evalresults);

% assign some values
axesH = get(datahandle,'Parent');
figureH = get(axesH, 'Parent');

% Create a Tag property for Figure to hold a unique number (when the
%   tag was created). This tag identifies the figure without using the integer 
%   figure handle since that can't be restored safely from a figfile.
if isempty(findprop(handle(figureH),'Basic_Fit_Fig_Tag'))
	p = schema.prop(handle(figureH), 'Basic_Fit_Fig_Tag', ...
		'MATLAB array');
	p.AccessFlags.Copy = 'off';
end
figureTag = datenum(clock);
set(handle(figureH), 'Basic_Fit_Fig_Tag', figureTag);

% residual plot info:
% this one might be the same as the plot of fits figure handle
residinfo.figuretag = figureTag; % assumed same as fit figure to start
residinfo.axes = []; % handle
setappdata(datahandle,'Basic_Fit_Resid_Info',residinfo);

% If normalize data, save old x data
normalized = [];
setappdata(datahandle,'Basic_Fit_Normalizers',normalized);

% Per data set
% do we need all these???
setappdata(datahandle,'Basic_Fit_Fits_Axes_Handle', axesH); 
setappdata(datahandle,'Basic_Fit_Fits_Axes_Position',get(axesH,'position'));
setappdata(datahandle,'Basic_Fit_Legend_Position',[]);

setappdata(fighandle,'Basic_Fit_Fits_Axes_Count',axesCount);

% make sure the xdata is sorted so the residuals will look right

% turn listeners off
if ~isempty(findprop(handle(datahandle), 'bfit_CurveXDListeners'))
    listeners = get(handle(datahandle), 'bfit_CurveXDListeners');
    set(listeners.XDataChanged,'Enabled','off');
end
if ~isempty(findprop(handle(datahandle), 'bfit_CurveYDListeners'))
    listeners = get(handle(datahandle), 'bfit_CurveYDListeners');
    set(listeners.YDataChanged,'Enabled','off');
end
if ~isempty(findprop(handle(datahandle), 'bfit_CurveZDListeners'))
    listeners = get(handle(datahandle), 'bfit_CurveZDListeners');
    set(listeners.ZDataChanged,'Enabled','off');
end

xdata = get(datahandle,'xdata');
ydata = get(datahandle,'ydata');
[xdata,xind] = sort(xdata);
ydata = ydata(xind);
set(datahandle,'xdata',xdata);
set(datahandle,'ydata',ydata);

%turn listeners back on
if ~isempty(findprop(handle(datahandle), 'bfit_CurveXDListeners'))
    listeners = get(handle(datahandle), 'bfit_CurveXDListeners');
    set(listeners.XDataChanged,'Enabled','on');
end
if ~isempty(findprop(handle(datahandle), 'bfit_CurveYDListeners'))
    listeners = get(handle(datahandle), 'bfit_CurveYDListeners');
    set(listeners.YDataChanged,'Enabled','on');
end
if ~isempty(findprop(handle(datahandle), 'bfit_CurveZDListeners'))
    listeners = get(handle(datahandle), 'bfit_CurveZDListeners');
    set(listeners.ZDataChanged,'Enabled','on');
end

% Add the data to the legend and put appdata on the data
fitappdata.type = 'data';
fitappdata.index = [];
setappdata(datahandle,'bfit',fitappdata);

% The following instance property probably has already been set. Just in case it hasn't
% though, set it now
if isempty(findprop(handle(datahandle), 'Basic_Fit_Copy_Flag'))
	p = schema.prop(handle(datahandle), 'Basic_Fit_Copy_Flag', 'MATLAB array');
	p.AccessFlags.Copy = 'off';
end

bfitcreatelegend(axesH);

