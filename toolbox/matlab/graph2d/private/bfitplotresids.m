function  [residinfo, residh] = bfitplotresids(figH,axesH,datahandle,fitsshowing,subploton,plottype)
%  BFITPLOTRESIDS Plot residuals on figure.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.30.4.5 $  $Date: 2004/04/10 23:26:27 $

% constants
barplot = 0;
scatterplot = 1;
lineplot = 2;
infarray = repmat(inf,1,12);
legendpos = 1;

residinfo = getappdata(datahandle,'Basic_Fit_Resid_Info');
residfigure = findobj(0,'Basic_Fit_Fig_Tag',residinfo.figuretag);

% default values in case new fig or axes
axesunits = 'normalized';

% delete old residual axes if it is there 
if ~isempty(residinfo.axes) && ishandle(residinfo.axes)
    % get old values before delete
    axesunits = get(residinfo.axes,'units');
    legendH = legend('-find',residinfo.axes); 
    % keep original legend position if possible
	if ~isempty(legendH)
		ud = get(legendH,'userdata');
		if isequal(length(ud.legendpos),1)
			legendpos = ud.legendpos;
		else
			% legend position must be in units of points
			set(legendH,'units','points');
			legendpos = get(legendH,'position');
			set(legendH,'units','normalized');
		end
	end
    % Should reset ResidTxt handle since we are deleting it. The Resid_Handles are reset below.
    setappdata(datahandle,'Basic_Fit_ResidTxt_Handle', []); % norm of residuals txt
    delete(residinfo.axes);
end

% Create figure/axes and add listeners
if ~subploton % residuals in separate figure
    % Unless we already have a separate figure for resids, get one:
	if isempty(residfigure) || isequal(residfigure, figH)
		residfigure = figure;
		% create tag property on new figure
		p =  schema.prop(handle(residfigure), 'Basic_Fit_Fig_Tag', ...
			'MATLAB array');
		p.AccessFlags.Copy = 'off';
		residinfo.figuretag = datenum(clock);
		set(handle(residfigure), 'Basic_Fit_Fig_Tag', residinfo.figuretag);
		
		set(residfigure,'units','pixels');
		residpos = get(residfigure,'position');
		if isequal(residpos, get(figH,'position'))
			set(residfigure,'position', residpos + [50 -50 0 0]);
		end
	end 
	
	if isempty(findprop(handle(residfigure),'Basic_Fit_Resid_Figure'))
		p = schema.prop(handle(residfigure), 'Basic_Fit_Resid_Figure', ...
			'MATLAB array');
		p.AccessFlags.Serialize = 'off';
		p.AccessFlags.Copy = 'off';
	end
	set(handle(residfigure),'Basic_Fit_Resid_Figure',1);
    % resize the axesH axes to the original position
    axesHposition = getappdata(datahandle,'Basic_Fit_Fits_Axes_Position');
    set(axesH,'position',axesHposition);
    figure(residfigure) % so the next line puts the axes in the correct place
    residinfo.axes = axes; % add a new axes, we already deleted any that existed
else % subplot
	if ~isempty(residfigure) && ~isequal(residfigure, figH) % were on separate plots
        delete(residfigure);
    end
    residfigure = figH;
    
	residinfo.figuretag = get(handle(figH),'Basic_Fit_Fig_Tag');
    set(axesH,'position',[0.1300    0.5811    0.7750    0.3439]);
    figure(figH)
    residinfo.axes = axes('position', [0.1300    0.1100    0.7750    0.3439], ...
		'parent', figH);
    
	% Change order of figure children so legend is "on top" of
	% fit/data axes and also residual axes
	kids = get(figH, 'children');
	set(figH,'children', [kids(2:end);kids(1)]);
end

%label the axes a resid axes
if isempty(findprop(handle(residinfo.axes),'Basic_Fit_Resid_Axes'))
	p = schema.prop(handle(residinfo.axes), 'Basic_Fit_Resid_Axes', ...
		'MATLAB array');
	p.AccessFlags.Serialize = 'off';
	p.AccessFlags.Copy = 'off';
end
set(handle(residinfo.axes),'Basic_Fit_Resid_Axes',1);

% Set resid axes box to be on/off according to data axes
if isequal(get(axesH,'box'),'on')
	set(residinfo.axes,'box','on');
else
	set(residinfo.axes,'box','off');
end
bfitlisten(residfigure) % add listeners to the figure or new axes
bfitlistenoff(figH) % turn off listeners
if ~isequal(figH,residfigure) && ishandle(residfigure)
    bfitlistenoff(residfigure)
end

% save the figure tag of the data/figs figure in appdata of new resid figure
setappdata(residfigure,'Basic_Fit_Data_Figure_Tag',get(handle(figH),'Basic_Fit_Fig_Tag'));
set(residinfo.axes,'tag','residuals');
resids = getappdata(datahandle,'Basic_Fit_Resids');
xdata = get(datahandle,'xdata');

figure(residfigure)
set(residfigure,'nextplot','add');
set(residinfo.axes,'nextplot','add');
set(residinfo.axes,'units','normalized');

% (re-)initialize to all Inf's
residh = infarray;

% Put residuals in a matrix to plot
% fitsshowing is the indices of the fits to plot
n = length(fitsshowing);
if n > 0
    M = zeros(length(xdata),n);
    for i = 1:n
        M(:,i) = resids{fitsshowing(i)};
    end
    switch plottype
    case barplot
		notdistinct = find(~diff(xdata));
		if ~isempty(notdistinct)
			warnmsg = sprintf(['Bar plots of the residuals are not permitted with repeated X values.\n' ...
					'Use a scatter or line plot or remove repeated X values.']); 
			warndlg(warnmsg,'Basic Fitting');
		end
        % Bar doesn't take an axes, save and set gca
        currentgca = gca(residfigure);
        set(residfigure,'currentaxes',residinfo.axes);
        residh(fitsshowing) = bar(xdata,M);
        % Reset gca
        set(residfigure,'currentaxes',currentgca);
        colortype = 'facecolor';
    case scatterplot
        residh(fitsshowing) = plot(xdata,M,'.','parent',residinfo.axes);
        colortype = 'color';
    case lineplot % lineplot
        residh(fitsshowing) = plot(xdata,M,'parent',residinfo.axes);
        colortype = 'color';
    otherwise
        error('MATLAB:bfitplotresids:UnknownPlotType', 'Unknown plot type for residual plot.');
    end
    for i = 1:n
        name = createresidname(fitsshowing(i)-1,datahandle);
        % the following is the same as in bfitplotfit so color coincides
        color_order = get(axesH,'colororder');
        % minus one to fitsshowing(i) so fit type is correct
        colorindex = mod(fitsshowing(i)-1,size(color_order,1)) + 1;
		color = color_order(colorindex,:);
        set(residh(fitsshowing(i)),colortype,color,'tag',name);
        if (plottype == barplot)
	        % set edges to be the same color as bars
	        set(residh(fitsshowing(i)),'edgecolor',color);
		end
        fitappdata.type = 'residual';
        fitappdata.index = fitsshowing(i);
        setappdata(residh(fitsshowing(i)),'bfit',fitappdata)
		p = schema.prop(handle(residh(fitsshowing(i))), 'Basic_Fit_Copy_Flag', 'MATLAB array');
		p.AccessFlags.Copy = 'off';
    end
end
% tighten the axis so it will look more like the fit axis
axis(residinfo.axes,'tight');
% Make ylims centered around 0, and
% if ylims are small, adjust ylim
ylims = get(residinfo.axes,'ylim');
maxy = max(abs(ylims));
if 10*maxy < 1
    set(residinfo.axes,'ylim',[-maxy,maxy].*10);
else
    set(residinfo.axes,'ylim',[-maxy,maxy]);
end

set(get(residinfo.axes,'title'),'string','residuals')
% Legend only if on separate figure
if ~subploton && ~isempty(fitsshowing)
    names = {'spline','shape-preserving','linear','quadratic','cubic','4th degree','5th degree','6th degree',...
            '7th degree','8th degree','9th degree','10th degree'};
	bfitlistenoff(residfigure);
	legend(residinfo.axes,names(:,fitsshowing),legendpos);
	bfitlistenon(residfigure);
end

% reset units
set(residinfo.axes,'units',axesunits);

if ~subploton
    bfitlisten(residfigure);
end

% Make axes with data the current axes
if subploton
    set(figH,'currentaxes',axesH);
end
%----------------------------------
function name = createresidname(fit,datahandle)
% CREATERESIDNAME  Create tag name for residual line.

switch fit
case 0
    name = sprintf('residual: spline');
case 1
    name = sprintf('residual: shape-preserving');
case 2
    name = sprintf('residual: linear');
case 3
    name = sprintf('residual: quadratic');
case 4
    name = sprintf('residual: cubic');
otherwise
    name = sprintf('residual: %sth degree',num2str(fit-1));
end