function varargout = bfit(figHandle, cmd)
% BFIT
%   GUIHANDLE = BFIT(FIGHANDLE, 'bf') opens the Basic Fitting GUI and stores the
%   handle of the GUI in the appdata of the figure.
%   GUIHANDLE = BFIT(FIGHANDLE, 'ds') opens the Data Stats GUI and stores the
%   handle of the GUI in the appdata of the figure.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.12.4.1 $  $Date: 2002/09/26 01:52:52 $

% Check for the aberrant case that this was a bfit object copied from another
% figure (if so, strip off all bfit data and treat it as data)

axesList = findall(figHandle, 'type', 'axes');

for i = 1:length(axesList)
	axesChildren = get(axesList(i),'children');
	for j = 1:length(axesChildren)
		if isappdata(axesChildren(j), 'bfit')
			if isempty(findprop(handle(axesChildren(j)), 'Basic_Fit_Copy_Flag'))
				bfitclearappdata(axesChildren(j));
			end 
		end
	end
end

ptr = get(figHandle,'pointer');
set(figHandle,'pointer','watch');
	% Was it loaded from a figfile: if so, then no pointer to GUI but has Basic_Fit_Fig_Tag
	% BEFORE opening GUI.
	if isempty(findprop(handle(figHandle),'Basic_Fit_GUI_Object')) ...
			& ~isempty(findprop(handle(figHandle),'Basic_Fit_Fig_Tag')) & ...
			isappdata(figHandle,'Basic_Fit_Data_Counter')  % not a residual figure
		updatetags(figHandle);
	end
switch cmd
case 'bf'
	bf = com.mathworks.page.basicfit.BasicFit.showBasicFit(figHandle);
	if isempty(findprop(handle(figHandle),'Basic_Fit_GUI_Object'))
		p = schema.prop(handle(figHandle), 'Basic_Fit_GUI_Object', ...
			'MATLAB array');
		p.AccessFlags.Serialize = 'off';
		p.AccessFlags.Copy = 'off';
	end
	set(handle(figHandle), 'Basic_Fit_GUI_Object', bf);
case 'ds'
	ds = com.mathworks.page.basicfit.DataStatistics.showDataStats(figHandle);
	if isempty(findprop(handle(figHandle),'Data_Stats_GUI_Object'))
		p = schema.prop(handle(figHandle), 'Data_Stats_GUI_Object', ...
			'MATLAB array');
		p.AccessFlags.Serialize = 'off';
		p.AccessFlags.Copy = 'off';
	end
	set(handle(figHandle), 'Data_Stats_GUI_Object', ds);
end
set(figHandle,'pointer',ptr);

%------------------------------------------------------------------------------------------------
function updatetags(figHandle)
% Recreate a Tag in case the figure it was created from is open (otherwise
% they will have the same Tags).

oldTag = get(handle(figHandle),'Basic_Fit_Fig_Tag');
% Create new tag
figureTag = datenum(clock);
set(handle(figHandle), 'Basic_Fit_Fig_Tag', figureTag);

% for current data, check is resid is separate since we need to create it if it is
datahandle = getappdata(figHandle,'Basic_Fit_Current_Data');
residinfo = getappdata(datahandle,'Basic_Fit_Resid_Info');
if isequal(residinfo.figuretag,oldTag) % subplot		
	residinfo.figuretag = figureTag;
	setappdata(datahandle,'Basic_Fit_Resid_Info',residinfo);
else % separate figure
	% No residfigure, so set to empty for bfitcheckplotresiduals call
	residinfo.figuretag = [];
	residinfo.axes = [];
	setappdata(datahandle,'Basic_Fit_Resid_Info',residinfo);
	checkon = 1;
	guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
	% need to draw a new resid figure
	bfitcheckplotresiduals(checkon,datahandle,guistate.plottype,~guistate.subplot,guistate.showresid);
	residinfo = getappdata(datahandle,'Basic_Fit_Resid_Info');
end
currentresidtag = residinfo.figuretag; 

% update other tags: residinfo.figuretag on each dataset
% for each data, check residinfo.figuretag and update
datasethandles = getappdata(figHandle,'Basic_Fit_Data_Handles'); 
datasethandles(datasethandles==datahandle) = [];      % delete current
for i=1:length(datasethandles)
	datahandle = datasethandles(i);
	residinfo = getappdata(datahandle,'Basic_Fit_Resid_Info');
	if isequal(residinfo.figuretag,oldTag)
		residinfo.figuretag = figureTag;
	else
		residinfo.figuretag = currentresidtag;
	end
	setappdata(datahandle,'Basic_Fit_Resid_Info',residinfo);
end

