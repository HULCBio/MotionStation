function bfitlisten(objhandle)
% BFITLISTEN Create listeners to detect when axes or lines are
% added or removed from a figure. 

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.32.4.9 $  $Date: 2004/04/15 00:00:40 $

hgp = findpackage('hg');

if isequal(get(objhandle,'type'),'axes') & isequal(get(objhandle,'tag'),'legend')
    axesC = findclass(hgp, 'line');
    aProp = findprop(axesC, 'userdata');
    
    if isempty(findprop(handle(objhandle), 'bfit_AxesListeners'))
        listeners.userDataChanged = handle.listener(objhandle, aProp, ...
            'PropertyPostSet', {@userDataChanged, get(objhandle,'parent')});
	p = schema.prop(handle(objhandle), 'bfit_AxesListeners', ...
		    'MATLAB array');
	p.AccessFlags.Serialize = 'off';
	p.AccessFlags.Copy = 'off';
	set(handle(objhandle), 'bfit_AxesListeners', listeners);
    end
    return;
end

fig = objhandle;
if isempty(findprop(handle(fig), 'bfit_FigureListeners'))
    % create listener: listen for children added to figure (e.g. axes)
    listener.childadd = handle.listener(fig, 'ObjectChildAdded', ...
        {@figChildAdded, fig});
    % create listener: listen for children deleted from figure (e.g. axes)
    listener.childremove = handle.listener(fig, 'ObjectChildRemoved', ...
        {@figChildRemoved, fig});
    % create listener: listen for when figure is closed
    listener.figdelete = handle.listener(fig,'ObjectBeingDestroyed',@figDeleted);
    
    % Store listener in figure so listener deleted when figure is
    p = schema.prop(handle(fig), 'bfit_FigureListeners', ...
		    'MATLAB array');
    p.AccessFlags.Serialize = 'off';
	p.AccessFlags.Copy = 'off';
    set(handle(fig), 'bfit_FigureListeners', listener);
end

lineC = findclass(hgp, 'line');
hProp = findprop(lineC, 'tag');
hPropXdata = findprop(lineC, 'XData');
hPropYdata = findprop(lineC, 'YData');
hPropZdata = findprop(lineC, 'ZData');

graph2dpkg = findpackage('graph2d');
lineSeriesC = findclass(graph2dpkg, 'lineseries');
hPropDisplayName = findprop(lineSeriesC, 'DisplayName');

% For each line in the figure, add listener for when Tag prop changes and for 
% when x, y, or z data change.
lineL = findobj(fig, 'type', 'line');
for i = lineL'
    if isempty(findprop(handle(i), 'bfit_CurveListeners'))
        listener.tagchanged = handle.listener(i, hProp, 'PropertyPostSet', ...
                                              {@lineTagChanged, fig});
    	p = schema.prop(handle(i), 'bfit_CurveListeners', ...
    			'MATLAB array');
    	p.AccessFlags.Serialize = 'off';
    	p.AccessFlags.Copy = 'off';
    	set(handle(i), 'bfit_CurveListeners', listener);
    end
    if isempty(findprop(handle(i), 'bfit_CurveDisplayNameListeners'))
        listener.displaynamechanged = handle.listener(i, hPropDisplayName, 'PropertyPostSet', ...
                                              {@lineDisplayNameChanged, fig});
    	p = schema.prop(handle(i), 'bfit_CurveDisplayNameListeners', ...
    			'MATLAB array');
    	p.AccessFlags.Serialize = 'off';
    	p.AccessFlags.Copy = 'off';
    	set(handle(i), 'bfit_CurveDisplayNameListeners', listener);
    end
    if isempty(findprop(handle(i), 'bfit_CurveXDListeners'))
        listener.XDataChanged = handle.listener(i, hPropXdata, ...
                                'PropertyPostSet', {@lineXYZDataChanged, fig});
    	p = schema.prop(handle(i), 'bfit_CurveXDListeners', ...
    			'MATLAB array');
    	p.AccessFlags.Serialize = 'off';
    	p.AccessFlags.Copy = 'off';
    	set(handle(i), 'bfit_CurveXDListeners', listener);
    end
    if isempty(findprop(handle(i), 'bfit_CurveYDListeners'))
        listener.YDataChanged = handle.listener(i, hPropYdata, ...
                                'PropertyPostSet', {@lineXYZDataChanged, fig});
    	p = schema.prop(handle(i), 'bfit_CurveYDListeners', ...
    			'MATLAB array');
    	p.AccessFlags.Serialize = 'off';
    	p.AccessFlags.Copy = 'off';
    	set(handle(i), 'bfit_CurveYDListeners', listener);
    end
    if isempty(findprop(handle(i), 'bfit_CurveZDListeners'))
        listener.ZDataChanged = handle.listener(i, hPropZdata, ...
                                'PropertyPostSet', {@lineXYZDataChanged, fig});
    	p = schema.prop(handle(i), 'bfit_CurveZDListeners', ...
    			'MATLAB array');
    	p.AccessFlags.Serialize = 'off';
    	p.AccessFlags.Copy = 'off';
    	set(handle(i), 'bfit_CurveZDListeners', listener);
    end
end

% For each axes in the figure, add listener for children added/removed.
% If it's a legend, then listen for userdata changing.
axesL = findobj(fig, 'type', 'axes');
axesC = findclass(hgp, 'line');
aProp = findprop(axesC, 'userdata');

for i = axesL'
    if isempty(findprop(handle(i), 'bfit_AxesListeners'))
        if isequal(get(i,'tag'),'legend')
            listeners.userDataChanged = handle.listener(i, aProp, 'PropertyPostSet', {@userDataChanged, fig});
        else
            listeners.lineAdded = handle.listener(i, 'ObjectChildAdded', ...
                {@axesChildAdded, fig});
            listeners.lineRemoved = handle.listener(i, 'ObjectChildRemoved', ...
                {@axesChildRemoved, fig});
        end
	p = schema.prop(handle(i), 'bfit_AxesListeners', ...
			'MATLAB array');
	p.AccessFlags.Serialize = 'off';
	p.AccessFlags.Copy = 'off';
	set(handle(i), 'bfit_AxesListeners', listeners);
    end
end

%-------------------------------------------------------------------------------------------
function figDeleted(hSrc, event)
% FIGDELETED Listen for figure deletion.
if ~isempty(findprop(handle(event.source),'Basic_Fit_Resid_Figure'))
    fitfigtag = getappdata(event.source,'Basic_Fit_Data_Figure_Tag');
	fitfig = findobj(0,'Basic_Fit_Fig_Tag',fitfigtag);
	bf = get(handle(fitfig), 'Basic_Fit_GUI_Object');
    datahandle = getappdata(fitfig,'Basic_Fit_Current_Data');
    if ~isempty(bf)
        % update gui
        guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
        guistate.plotresids = 0;
        % update handles
        residfigure = fitfig; % Leave this as fighandle unless we actually plot resids to another figure
        residinfo.figuretag = get(handle(fitfig),'Basic_Fit_Fig_Tag');      
		residinfo.axes = []; 
        residhandles = repmat(inf,1,12);
        residtxtH = [];
        
        setappdata(datahandle,'Basic_Fit_ResidTxt_Handle', residtxtH); % norm of residuals txt
        setappdata(datahandle,'Basic_Fit_Resid_Info',residinfo); 
        setappdata(datahandle,'Basic_Fit_Resid_Handles', residhandles); % array of handles of residual plots
        setappdata(datahandle,'Basic_Fit_Gui_State', guistate);
        
        basicfitupdategui(fitfig,datahandle)
    end
    
else % data/fit figure     
    % delete gui
	if ~isempty(findprop(handle(event.source),'Data_Stats_GUI_Object'))
		ds = get(handle(event.source),'Data_Stats_GUI_Object');
		if ~isempty(ds)
			ds.closeDataStats;
		end
	end
	if ~isempty(findprop(handle(event.source),'Basic_Fit_GUI_Object'))
		bf = get(handle(event.source), 'Basic_Fit_GUI_Object');
		if ~isempty(bf)
			bf.closeBasicFit;
		end
	end
	% If resid figure open, delete it.
        datahandle = getappdata(event.source,'Basic_Fit_Current_Data');
        if ~isempty(datahandle)
            residinfo = getappdata(datahandle,'Basic_Fit_Resid_Info');
			residfigure = findobj(0,'Basic_Fit_Fig_Tag',residinfo.figuretag);
            if ishandle(residfigure)
                delete(residfigure);
            end
        end
	
end

%-------------------------------------------------------------------------------------------
function legendReady(hSrc, event, fig, legendH)
    % legend has been added, update it to get labels in the correct order

    % find the axes of the current data
    fighandle = double(fig);
    datahandle = getappdata(fighandle, 'Basic_Fit_Current_Data');
    % if not basic_fit_currentdata, maybe only datastats is up.w
    if isempty(datahandle)
        datahandle = getappdata(fighandle,'Data_Stats_Current_Data');
    end
    if ~isempty(datahandle)
        axesH = get(datahandle,'Parent');
        bfitcreatelegend(axesH);
    end

%-------------------------------------------------------------------------------------------
function figChildAdded(hSrc, event, fig)
% FIGCHILDADDED Listen for children added to the figure.
% If child is an axes, then install listener on axes for axes children.
if event.child.isa('scribe.scribeaxes')
    return;
end
if event.child.isa('hg.axes') & ~isequal(event.child.get('tag'),'legend') & ...
        isequal(event.child.get('HandleVisibility'),'on') 
    
    if isempty(findprop(event.child, 'bfit_AxesListeners'))
        
        listeners.lineAdded = handle.listener(event.child, 'ObjectChildAdded', ...
            {@axesChildAdded, fig});
        listeners.lineRemoved = handle.listener(event.child, ...
            'ObjectChildRemoved', ...
            {@axesChildRemoved, fig});
        % Store the listeners on child of axes so deleted when child is
	p = schema.prop(handle(event.child), 'bfit_AxesListeners', ...
			'MATLAB array');
	p.AccessFlags.Serialize = 'off';
	p.AccessFlags.Copy = 'off';
	set(event.child, 'bfit_AxesListeners', listeners);
    end    
    
    % update the GUI
    axesH = double(event.child);
    fighandle = double(fig);
    datahandle = getappdata(fighandle, 'Basic_Fit_Current_Data');
    
    axesList = findobj(fighandle, 'type', 'axes');
    if isempty(axesList)
        axesCount = 0;
    else
        taglines = get(axesList,'tag');
        notlegendind = ~(strcmp('legend',taglines));
        axesCount = length(axesList(notlegendind));
    end
    setappdata(fighandle,'Basic_Fit_Fits_Axes_Count',axesCount);
    
    basicfitupdategui(fighandle,datahandle)
    
elseif event.child.isa('hg.axes') & isequal(event.child.get('tag'),'legend')
    hgp = findpackage('hg');
    axesC = findclass(hgp, 'line');
    aProp = findprop(axesC, 'userdata');
    listeners.userDataChanged = handle.listener(event.child, aProp, 'PropertyPostSet', {@userDataChanged, fig});
    listeners.legendReady = handle.listener(event.child, 'LegendConstructorDone', {@legendReady, fig, event.child});
    if isempty(findprop(event.child, 'bfit_AxesListeners'))
	p = schema.prop(event.child, 'bfit_AxesListeners', ...
			'MATLAB array');
	p.AccessFlags.Serialize = 'off';
	p.AccessFlags.Copy = 'off';
    end
    set(event.child, 'bfit_AxesListeners', listeners);
end

%-------------------------------------------------------------------------------------------
function figChildRemoved(hSrc, event, fig)
% FIGCHILDREMOVED Listen for children removed from the figure.
% If child is an axes, but not a legend, then update the GUI
% hSrc is the figure
% event.child is the axes being removed
% fig is the figure handle
% If the figure is being deleted, nothing needs to be done except "figDeleted" function
if event.child.isa('scribe.scribeaxes')
    return;
end
if isequal(hSrc.get('BeingDeleted'),'on')
    return;
end    
if event.child.isa('hg.axes') & ~isequal(event.child.get('tag'),'legend')
    
    axesH = double(event.child);
    fighandle = double(fig);
    
	if ~isempty(findprop(handle(event.child),'Basic_Fit_Resid_Figure'))

        % fighandle could be different if residuals in another figure
		fitfigtag = getappdata(fighandle,'Basic_Fit_Data_Figure_Tag');
		fighandle = findobj(0,'Basic_Fit_Fig_Tag',fitfigtag);
		% update appdata and the gui
        datahandle = getappdata(fighandle, 'Basic_Fit_Current_Data');
        fitaxesH = get(datahandle,'parent');
        if isempty(datahandle)
            return
        end
        residinfo = getappdata(datahandle,'Basic_Fit_Resid_Info');
		residfigure = findobj(0,'Basic_Fit_Fig_Tag',residinfo.figuretag);
        guistate = getappdata(datahandle, 'Basic_Fit_Gui_State');
        guistate.plotresids = 0; % residuals no longer plotted
        
        % remove stuff from plot
        if fighandle ~= residfigure
            delete(residfigure)
        else
            % resize the figure plot to old size
            axesHposition = getappdata(datahandle,'Basic_Fit_Fits_Axes_Position');
            set(fitaxesH,'position',axesHposition);
        end
        
        % update handles
        residfigure = fighandle; % Leave this as fighandle unless we actually plot resids to another figure
        residinfo.figuretag = get(handle(fighandle),'Basic_Fit_Fig_Tag');      
		residinfo.axes = []; 
        residhandles = repmat(inf,1,12);
        residtxtH = [];
        
        setappdata(datahandle,'Basic_Fit_ResidTxt_Handle', residtxtH); % norm of residuals txt
        setappdata(datahandle,'Basic_Fit_Resid_Info',residinfo); 
        setappdata(datahandle,'Basic_Fit_Resid_Handles', residhandles); % array of handles of residual plots
        setappdata(datahandle, 'Basic_Fit_Gui_State',guistate);
        
        % update the GUI
        basicfitupdategui(fighandle,datahandle);
        
    else % fit axes
        % The GUI will clear as the data is removed.
        axeshandles = getappdata(fighandle,'Basic_Fit_Axes_All');
        datahandle = getappdata(fighandle, 'Basic_Fit_Current_Data');
        
        % Step thru all the data and remove it.
        
        % Delete the axes from the axes list
        if ~isempty(axeshandles)
            deleteindex = (axeshandles == axesH);
            axeshandles(deleteindex) = [];
        end
        axesCount = length(axeshandles);
        setappdata(fighandle,'Basic_Fit_Axes_All',axeshandles)
        setappdata(fighandle,'Basic_Fit_Fits_Axes_Count',axesCount);
        % datahandles are updated when deleted
        
        % update the GUI
        if ~isempty(datahandle)
            basicfitupdategui(fighandle,datahandle);        
        end
    end
elseif event.child.isa('hg.axes') & isequal(event.child.get('tag'),'legend')
    % Axes is being deleted, so the listeners are as well. Nothing to cleanup.
end

%-------------------------------------------------------------------------------------------
function axesChildAdded(hSrc, event, fig)
% AXESCHILDADDED Listen for axes children being added. 
% If added and a line, update Data Selector List in GUI
% Only do this for new data. Do not need listeners on individual fit lines.

% Check for the aberrant case that this was a bfit object copied from another
% figure (if so, strip off all bfit data and treat it as data)
lineAddedUpdate(event.child, fig);

%---------------------------------------------------------------------------
function lineAddedUpdate(line, fig) 
% Do not listen to data cursors.
if strcmp(class(handle(line)),'graphics.datatip');
    return;
end

%if plot is going to a resid axes or legend, ignore it.
parentaxes = ancestor(line, 'axes');
if ~isempty(findprop(handle(parentaxes), 'Basic_Fit_Resid_Axes'))
    return;
end
if isequal(get(parentaxes,'tag'),'legend')
    return;
end

if isappdata(line, 'bfit')
	if isempty(findprop(handle(line), 'Basic_Fit_Copy_Flag'))
		bfitclearappdata(line);
	end
end 

% Although we only do basic fitting and data stats on lines with no zdata, 
% we need to add a listener to lines with zdata to detect when zdata is deleted.
% We also need to make sure it has legend behavior (not a decoration or affordance).

if ( strcmp(get(line, 'type'), 'line')) && ...
        hasbehavior(double(line),'legend')
 
    hgp = findpackage('hg');
    lineC = findclass(hgp, 'line');
    
    if (isempty(get(line,'zdata')) )
        hProp = findprop(lineC, 'tag');
        
        if isa(handle(line), 'graph2d.lineseries') && ~isempty(get(line, 'DisplayName'))
			newtag =  get(line, 'DisplayName');
		else
			newtag = get(line,'tag');
		end
        if ~isempty(newtag) % tag is always a single line string
            setappdata(double(line),'bfit_dataname',newtag);
        end
        [h,n] = bfitgetdata(fig);
        if isempty(h) % This should never happen
            error('MATLAB:bfitlisten:NoData', 'No data in figure.');
        end
    
        % Begin Data Stat updating ----------------------------------------------------------------
        % initialize
        x_str = [];
        y_str = [];
        xcheck = [];
        ycheck = [];
        dscurrentdata = getappdata(fig,'Data_Stats_Current_Data');
        if isempty(dscurrentdata)
            % New current data:
            % get data stats and GUI checkbox info for new current data based on appdata. 
            dscurrentindex = 1;
            dsnewdataHandle = h{1};
            [x_str, y_str, xcheck, ycheck] = bfitdatastatselectnew(fig, dsnewdataHandle);
            % Update current data appdata
            setappdata(fig,'Data_Stats_Current_Data', dsnewdataHandle);
        else
            % h is not empty & currentdata not empty
            dscurrentindex = find([ h{:} ] == dscurrentdata );
        end
        if ~isempty(dscurrentindex)
            % At this point, currentindex is not empty
            if ~isempty(findprop(handle(fig),  'Data_Stats_GUI_Object'))
                ds = get(handle(fig), 'Data_Stats_GUI_Object');
                if ~isempty(ds)
                    ds.addData(h, n, dscurrentindex, x_str, y_str, xcheck, ycheck);
                end
            end 
        end
        % End Data Stat updating ----------------------------------------------------------------
    
        % Begin Basic Fit updating ----------------------------------------------------------------
        bfcurrentdata = getappdata(fig,'Basic_Fit_Current_Data');
        if isempty(bfcurrentdata)
            % New current data:
            % get data stats and GUI checkbox info for new current data based on appdata. 
            bfcurrentindex = 1;
            bfnewdataHandle = h{1};
            [axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                    currentfit,coeffresidstrings] = bfitselectnew(fig, bfnewdataHandle);  % Update current data appdata
            setappdata(fig,'Basic_Fit_Current_Data', bfnewdataHandle);
        else
            % h is not empty & currentdata not empty
            bfcurrentindex = find([ h{:} ] == bfcurrentdata );
            axesCount = []; fitschecked = []; bfinfo =[]; evalresultsstr = [];
            evalresultsx = []; evalresultsy =[]; currentfit = []; coeffresidstrings = [];
        end
    
        if ~isempty(bfcurrentindex)
            % At this point, currentindex is not empty
    		if ~isempty(findprop(handle(fig), 'Basic_Fit_GUI_Object'))
    			bf = get(handle(fig), 'Basic_Fit_GUI_Object');
                if ~isempty(bf)
                    if isempty(axesCount)
                        axesCount = -1; % bf.changeData does not like []
                    end
                    if isempty(currentfit)
                        currentfit = -1; % bf.changeData does not like []
                    end
                    bf.changeData(h,n,bfcurrentindex,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                        currentfit,coeffresidstrings);
                end 
            end
        end
        % End Basic Fit updating ----------------------------------------------------------------
        
        % add listener for tag property of newly added line
        listener.tagchanged = handle.listener(line, hProp, 'PropertyPostSet', {@lineTagChanged, fig});
        tempprop = findprop(handle(line), 'bfit_CurveListeners');
        if isempty(findprop(handle(line), 'bfit_CurveListeners'))
        	p = schema.prop(handle(line), 'bfit_CurveListeners', ...
        			'MATLAB array');
        	p.AccessFlags.Serialize = 'off';
        	p.AccessFlags.Copy = 'off';
        end
        set(handle(line), 'bfit_CurveListeners', listener);

        graph2dpkg = findpackage('graph2d');
        lineSeriesC = findclass(graph2dpkg, 'lineseries');
        hPropDisplayName = findprop(lineSeriesC, 'DisplayName');
        
        listener.displaynamechanged = handle.listener(line, hPropDisplayName, 'PropertyPostSet', {@lineDisplayNameChanged, fig});
        tempprop = findprop(handle(line), 'bfit_CurveDisplayNameListeners');
        if isempty(findprop(handle(line), 'bfit_CurveDisplayNameListeners'))
        	p = schema.prop(handle(line), 'bfit_CurveDisplayNameListeners', ...
        			'MATLAB array');
        	p.AccessFlags.Serialize = 'off';
        	p.AccessFlags.Copy = 'off';
        end
        set(handle(line), 'bfit_CurveDisplaynameListeners', listener);
                
        axesH = get(line, 'parent');
        % update legend
        bfitcreatelegend(axesH);
    end
    
    % if limmode is manual, enlarge lims to see new data.
    resetlims(axesH, line);
    
    % add listeners for x, y and z data changing
    hProp = findprop(lineC, 'XData');
    listener.XDataChanged = handle.listener(line, hProp, 'PropertyPostSet', {@lineXYZDataChanged, fig});
    if isempty(findprop(handle(line), 'bfit_CurveXDListeners'))
        p = schema.prop(handle(line), 'bfit_CurveXDListeners', ...
        		'MATLAB array');
        p.AccessFlags.Serialize = 'off';
        p.AccessFlags.Copy = 'off';
    end
    set(handle(line), 'bfit_CurveXDListeners', listener);
    
    hProp = findprop(lineC, 'YData');
    listener.YDataChanged = handle.listener(line, hProp, 'PropertyPostSet', {@lineXYZDataChanged, fig});
    if isempty(findprop(handle(line), 'bfit_CurveYDListeners'))
        p = schema.prop(handle(line), 'bfit_CurveYDListeners', ...
        		'MATLAB array');
        p.AccessFlags.Serialize = 'off';
        p.AccessFlags.Copy = 'off';
    end
    set(handle(line), 'bfit_CurveYDListeners', listener);
    
    hProp = findprop(lineC, 'ZData');
    listener.ZDataChanged = handle.listener(line, hProp, 'PropertyPostSet', {@lineXYZDataChanged, fig});
    if isempty(findprop(handle(line), 'bfit_CurveZDListeners'))
        p = schema.prop(handle(line), 'bfit_CurveZDListeners', ...
        		'MATLAB array');
        p.AccessFlags.Serialize = 'off';
        p.AccessFlags.Copy = 'off';
    end
    set(handle(line), 'bfit_CurveZDListeners', listener);
end

%-------------------------------------------------------------------------------------------
function resetlims(axes, line)
    
if strcmp(get(axes, 'xlimmode'), 'manual')
    x = get(line, 'xdata');
    y = get(line, 'ydata');
    xlim = get(axes, 'xlim');
    xlim(1) = min(xlim(1), min(x));
    xlim(2) = max(xlim(2), max(x));
    set(axes, 'xlim', xlim);
    ylim = get(axes, 'ylim');
    ylim(1) = min(ylim(1), min(y));
    ylim(2) = max(ylim(2), max(y));
    set(axes, 'ylim', ylim);
end 

%-------------------------------------------------------------------------------------------
function axesChildRemoved(hSrc, event, fig)
% AXESCHILDREMOVED Listen for axes children being removed. 
% If removed and a line, update Data Selector List in GUI.
% hSrc is the Axes
% event.child is the line being removed
% fig is the figure handle
% If the figure is being deleted, nothing needs to be done:  "figDeleted" does all needed work
if ishandle(fig) && isequal(get(fig,'BeingDeleted'),'on')
    return;
end


removedline = double(event.child);
axesh = double(hSrc);
lineDeleteUpdate(removedline, axesh, fig, 'data removed');

%-------------------------------------------------------------------------------------------
function lineDeleteUpdate(removedline, axesh, fig, flag)
% LINEDELETEUPDATE If line is removed or deleted, update the GUI and figure and appdata.

appdata = getappdata(removedline,'bfit');

if ~isempty(appdata) % some sort of data stat or bfit line being deleted

    switch appdata.type
    case {'data','data potential'}
        [h,n] = bfitgetdata(fig);
        if isempty(h) % this should never happen
            error('MATLAB:bfitlisten:NoDataInFigure','No data in figure to remove.');
        end
        
        dsdatahandles = getappdata(fig,'Data_Stats_Data_Handles');
        bfdatahandles = getappdata(fig, 'Basic_Fit_Data_Handles');
        
        if ~isempty(dsdatahandles)
            [dscurrentindex,h,n,x_str, y_str, xcheck, ycheck] = datastatdeletedata(removedline,fig,h,n);
            if ~isempty(dscurrentindex)
                if ~isempty(findprop(handle(fig),  'Data_Stats_GUI_Object'))
					ds = get(handle(fig), 'Data_Stats_GUI_Object');
                    if ~isempty(ds)
                        ds.removeData(h, n, dscurrentindex, x_str, y_str, xcheck, ycheck);
                    end
                end 
            end
            % if has been fitted data, remove.
            dsdatahandles = getappdata(fig, 'Data_Stats_Data_Handles'); % get again in case changed
            dsdatahandles(removedline==dsdatahandles) = [];
            setappdata(fig,'Data_Stats_Data_Handles', dsdatahandles);
        end
        
        if ~isempty(bfdatahandles)
            [bfcurrentindex,h,n,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                    currentfit,coeffresidstrings] = basicfitdeletedata(removedline,fig,h,n);
            if ~isempty(bfcurrentindex)
                % Call Java GUI to update the data selector box
				if ~isempty(findprop(handle(fig),'Basic_Fit_GUI_Object'))
					bf = get(handle(fig),'Basic_Fit_GUI_Object');
                    if ~isempty(bf)
                        if isempty(axesCount)
                            axesCount = -1; % bf.changeData does not like []
                        end
                        if isempty(currentfit)
                            currentfit = -1; % bf.changeData does not like []
                        end
                        bf.changeData(h,n,bfcurrentindex,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                            currentfit,coeffresidstrings);
                    end 
                end
            end
            
            % if has been fitted data, remove.
            bfdatahandles = getappdata(fig, 'Basic_Fit_Data_Handles'); % get again in case changed
            bfdatahandles(removedline==bfdatahandles) = [];
            setappdata(fig,'Basic_Fit_Data_Handles', bfdatahandles);
        end 
        
        % if has been "potential" data, remove.
        alldatahandles = getappdata(fig,'Basic_Fit_Data_All');
        alldatahandles(removedline==alldatahandles) = [];
        setappdata(fig,'Basic_Fit_Data_All',alldatahandles);
        % update legend
        bfitcreatelegend(axesh,true,removedline);
        
    case {'stat x', 'stat y'}
        dscurrentdata = getappdata(fig, 'Data_Stats_Current_Data');
        if isempty(dscurrentdata) % currentdata already deleted
            return;
        end
        ind = appdata.index;
        xvector = getappdata(dscurrentdata,'Data_Stats_X_Showing');
        yvector = getappdata(dscurrentdata,'Data_Stats_Y_Showing');
        if isequal(appdata.type,'stat x')
            xhandles = getappdata(dscurrentdata,'Data_Stats_X_Handles');
            xvector(ind) = 0;
            xhandles(ind) = Inf;
            setappdata(dscurrentdata, 'Data_Stats_X_Showing' ,xvector);
            setappdata(dscurrentdata, 'Data_Stats_X_Handles' ,xhandles);
        else
            yhandles = getappdata(dscurrentdata,'Data_Stats_Y_Handles');
            yvector(ind) = 0;
            yhandles(ind) = Inf;
            setappdata(dscurrentdata,'Data_Stats_Y_Showing',yvector);
            setappdata(dscurrentdata, 'Data_Stats_Y_Handles',yhandles);
        end
		if ~isempty(findprop(handle(fig),'Data_Stats_GUI_Object'))
			ds = get(handle(fig), 'Data_Stats_GUI_Object');
			if ~isempty(ds)
				ds.removeStatLine(xvector, yvector);
			end
		end
		bfitcreatelegend(axesh,true,removedline);
        
    case {'fit'}
        bfcurrentdata = getappdata(fig, 'Basic_Fit_Current_Data');
        if isempty(bfcurrentdata) % currentdata already deleted
            return;
        end
        ind = appdata.index;
        fitvector = getappdata(bfcurrentdata,'Basic_Fit_Showing');
        fithandles = getappdata(bfcurrentdata,'Basic_Fit_Handles');
        fitvector(ind) = 0;
        fithandles(ind) = Inf;
        setappdata(bfcurrentdata,'Basic_Fit_Showing',fitvector);
        setappdata(bfcurrentdata,'Basic_Fit_Handles',fithandles);
        
        guistate = getappdata(bfcurrentdata,'Basic_Fit_Gui_State');
        residhandles = getappdata(bfcurrentdata,'Basic_Fit_Resid_Handles'); % array of handles of residual plots

        % turn off listeners
		bfitlistenoff(fig)         % Turn off main window listeners
		if guistate.plotresids
			residinfo = getappdata(bfcurrentdata,'Basic_Fit_Resid_Info');
			residfigure = findobj(0,'Basic_Fit_Fig_Tag',residinfo.figuretag);

			bfitlistenoff(residfigure)  % Turn off resid figure listeners
			if ishandle(residhandles(ind))
                residdeleted = residhandles(ind);
				delete(residhandles(ind));
			end
            residhandles(ind) = Inf;
            setappdata(bfcurrentdata,'Basic_Fit_Resid_Handles',residhandles); 
            
			if guistate.showresid
				bfitcheckshownormresiduals(guistate.showresid,bfcurrentdata)
			end            
            % Update legend on residuals figure
            % keep legend position if possible
            [legendH,objh,oldhandles,oldstrings] = legend('-find',residinfo.axes);
            if ~isempty(legendH) % was there a legend?
                delind = (residdeleted == oldhandles | oldhandles == -1);
                oldhandles(delind) = [];
                oldstrings(delind) = [];
                legendloc = get(legendH, 'location');
                if isequal(legendloc, 'none')
                    ud = get(legendH,'userdata');
                    if isequal(length(ud.legendpos),1)
                        legendpos = ud.legendpos;
                    else
                        % legend position must be in units of points
                        legendpos = hgconvertunits(...
                            ancestor(residinfo.axes, 'figure'), ...
                            get(legendH,'position'), ...
                            get(legendH,'units'), ...
                            'points', get(legendH,'parent'));                 
                    end
                    legend(residinfo.axes,oldhandles,oldstrings,legendpos);
                else
                    legend(residinfo.axes,oldhandles,oldstrings,'location',legendloc);
                end
            end
            if residfigure ~= fig
                % Resid figure not deleted, so restore listeners
                bfitlistenon(residfigure)  
            end
		end % if guistate.plotresids
        
        if guistate.equations
            if all(~isfinite(fithandles)) % no fits left
                eqntxth = getappdata(bfcurrentdata,'Basic_Fit_EqnTxt_Handle');
                if ishandle(eqntxth)
                    delete(eqntxth);
                end
                setappdata(bfcurrentdata,'Basic_Fit_EqnTxt_Handle', []);  
                guistate.equations = 0;
            else
                % update eqntxt
                bfitcheckshowequations(guistate.equations, bfcurrentdata, guistate.digits)
            end
        end
        
        % if this is the right eval results, delete it
        currentfit = getappdata(bfcurrentdata,'Basic_Fit_NumResults_');
        if isequal(ind,currentfit)
            evalresults = getappdata(bfcurrentdata,'Basic_Fit_EvalResults');
            if guistate.plotresults
                if ishandle(evalresults.handle)
                    delete(evalresults.handle);
                end
            end    
            % evaluate results info
            evalresults.string = '';
            evalresults.x = []; % x values
            evalresults.y = []; % f(x) values
            evalresults.handle = [];
            setappdata(bfcurrentdata,'Basic_Fit_EvalResults',evalresults);
            guistate.plotresults = 0;
        end
        setappdata(bfcurrentdata,'Basic_Fit_Gui_State',guistate);
        
        basicfitupdategui(fig,bfcurrentdata)
        bfitcreatelegend(axesh,true,removedline);
        bfitlistenon(fig)    
        
    case {'eqntxt'}
        bfcurrentdata = getappdata(fig, 'Basic_Fit_Current_Data');
        if isempty(bfcurrentdata) % currentdata already deleted
            return;
        end
        guistate = getappdata(bfcurrentdata,'Basic_Fit_Gui_State');
        guistate.equations = 0;
        setappdata(bfcurrentdata,'Basic_Fit_EqnTxt_Handle',[]);
        setappdata(bfcurrentdata,'Basic_Fit_Gui_State',guistate);
        
        basicfitupdategui(fig,bfcurrentdata)
        
    case {'residnrmtxt'}
        residfig = fig;
		fitfigtag = getappdata(fig,'Basic_Fit_Data_Figure_Tag');
		fig = findobj(0,'Basic_Fit_Fig_Tag',fitfigtag);
		
        bfcurrentdata = getappdata(fig, 'Basic_Fit_Current_Data');
        if isempty(bfcurrentdata) % currentdata already deleted
            return;
        end
        guistate = getappdata(bfcurrentdata,'Basic_Fit_Gui_State');
        guistate.showresid = 0;
        setappdata(bfcurrentdata,'Basic_Fit_ResidTxt_Handle',[]);
        setappdata(bfcurrentdata,'Basic_Fit_Gui_State',guistate);
        
        basicfitupdategui(fig,bfcurrentdata)
        
    case {'evalresults'}
        bfcurrentdata = getappdata(fig, 'Basic_Fit_Current_Data');
        if isempty(bfcurrentdata) % currentdata already deleted
            return;
        end
        ind = appdata.index;
        evalresults = getappdata(bfcurrentdata,'Basic_Fit_EvalResults');
        guistate = getappdata(bfcurrentdata,'Basic_Fit_Gui_State');
        guistate.plotresults = 0;
        evalresults.handle = [];
        setappdata(bfcurrentdata,'Basic_Fit_EvalResults',evalresults);
        setappdata(bfcurrentdata,'Basic_Fit_Gui_State',guistate);
        
        basicfitupdategui(fig,bfcurrentdata)
        bfitcreatelegend(axesh,true,removedline);
        
    case {'residual'}
        residfig = fig;
		fitfigtag = getappdata(fig,'Basic_Fit_Data_Figure_Tag');
		fig = findobj(0,'Basic_Fit_Fig_Tag',fitfigtag);
		
        % delete all resids if delete one
        bfcurrentdata = getappdata(fig, 'Basic_Fit_Current_Data');
        if isempty(bfcurrentdata) % currentdata already deleted
            return;
        end
        ind = appdata.index;
        fitvector = getappdata(bfcurrentdata,'Basic_Fit_Showing');
        residhandles = getappdata(bfcurrentdata,'Basic_Fit_Resid_Handles');
        residhandles = repmat(inf,1,12);
        setappdata(bfcurrentdata,'Basic_Fit_Resid_Handles',residhandles);
        guistate = getappdata(bfcurrentdata,'Basic_Fit_Gui_State');
        guistate.plotresids = 0;
        setappdata(bfcurrentdata,'Basic_Fit_Gui_State',guistate);
        bfitcheckplotresiduals(0,bfcurrentdata,guistate.plottype,~guistate.subplot,guistate.showresid)
        
        basicfitupdategui(fig,bfcurrentdata)
    otherwise
    end %switch
end % if  ~isempty(appdata)


%-------------------------------------------------------------------------------------------
function lineTagChanged(hSrc, event, fig)
% LINETAGCHANGED Listen for line tags being changed.
% change the appdata based on the new tag if there isn't a display name
axesH = event.affectedobject.get('parent');
if ~isa(handle(event.affectedobject), 'graph2d.lineseries') || ...
   (isa(handle(event.affectedobject), 'graph2d.lineseries') && ...
    isempty(get(event.affectedobject, 'DisplayName')))

    setappdata(double(event.affectedobject),'bfit_dataname',event.newvalue)
    updatedataselectors(fig);

    % update legend
    bfitcreatelegend(axesH);
end

%-------------------------------------------------------------------------------------------
function lineDisplayNameChanged(hSrc, event, fig)
% LINEDISPLAYNAMECHANGED Listen for line displayName being changed.
axesH = event.affectedobject.get('parent');
if isempty(legend(axesH))
    setappdata(double(event.affectedobject),'bfit_dataname',event.newvalue);
    updatedataselectors(fig);
end

%-------------------------------------------------------------------------------------------
function lineXYZDataChanged(hSrc, event, fig)
% LINEXYDATACHANGED Listen for Xdata and YData being changed.

xd = get(event.affectedobject, 'XData');
yd = get(event.affectedobject, 'YData');
zd = get(event.affectedobject, 'ZData');

if length(xd) == length(yd) && isempty(zd)
    isGoodData = true;
else
    isGoodData = false;
end

changedline = double(event.affectedobject);

if isappdata(changedline, 'bfit')
    wasGoodData = true;
else
    wasGoodData = false;
end

if wasGoodData && hasFitsOrResults(changedline)
    msg = sprintf(['''%s'' data has changed. Fits and results will be '...
          'deleted'], getappdata(changedline, 'bfit_dataname'));
    warndlg(msg, 'Data changed');
end

if isGoodData && wasGoodData
    % handle basic fit -----------------
    gs = getappdata(changedline,'Basic_Fit_Gui_State');
    if ~isempty(gs)
        if getappdata(fig, 'Basic_Fit_Current_Data') ==  changedline
            evalresults = getappdata(changedline,'Basic_Fit_EvalResults');
            if ~isempty(evalresults) && ~isempty(evalresults.y)
                bfitevalfitbutton (changedline, -1, evalresults.string, gs.plotresults, 1)
            end

            numresults = getappdata(changedline,'Basic_Fit_NumResults_');
            if ~isempty(numresults)
                bfitcalcfit(handle (changedline), -1)
            end

            fitvector = getappdata(changedline,'Basic_Fit_Showing');
            % Were any fits checked?
            if any(fitvector)
                for i = find(fitvector == 1)
                    bfitcheckfitbox(false, handle (changedline), i-1, gs.equations, gs.digits, gs.plotresids,...
                                    gs.plottype, ~gs.subplot, gs.showresid); 
                end
            end
        
            % might only have data statistics showing
            
            if ~isempty(findprop(handle(fig),'Basic_Fit_GUI_Object'))
                bf = get(handle(fig), 'Basic_Fit_GUI_Object');
                if ~isempty(bf) 
                    bf.dataModified;
                end
            end
        else  % 
            bfitreinitbfitdata(changedline);
        end
    end
    % now check for data stats
    if isappdata(fig, 'Data_Stats_Current_Data') 
        guiUpdateNeeded = false;
        if getappdata(fig, 'Data_Stats_Current_Data') ==  changedline
            bfitdatastatremovelines(handle(fig), changedline);
            guiUpdateNeeded = true;
        end
        
        %delete all data stats appdata; this should be sufficient
        ad = getappdata(changedline);
        names = fieldnames(ad);
        for i = 1:length(names)
    		 if strncmp(names{i}, 'Data_Stats_', 11)
    		    rmappdata(changedline, names{i});
        	end
        end
        
        if guiUpdateNeeded
            [x_str, y_str] = bfitdatastatselectnew(handle(fig), changedline);
            if ~isempty(findprop(handle(fig),'Data_Stats_GUI_Object'))
                ds = get(handle(fig), 'Data_Stats_GUI_Object');
                if ~isempty(ds) 
                    ds.dataModified(x_str, y_str);
                end
            end
        end
    end    
    resetlims(get(changedline, 'parent'), changedline);
elseif isGoodData && ~wasGoodData
    lineAddedUpdate(changedline, fig);
elseif ~isGoodData && wasGoodData
    axesh = get(changedline, 'parent');
    lineDeleteUpdate(changedline, axesh, fig, 'data removed');
    %deleting lines actually adds some appdata, make sure it is clear now.
    bfitclearappdata(changedline);
    tempProp = findprop(handle (changedline), 'Basic_Fit_Copy_Flag');
    if ~isempty(tempProp)
        delete(tempProp);
    end
    tempProp = findprop(handle (changedline), 'bfit_CurveListeners');
    if ~isempty(tempProp)
        delete(tempProp);
    end
end %if ~isGoodData && ~wasGoodData nothing needs to be done.

%-------------------------------------------------------------------------------------------
function retVal = hasFitsOrResults(line)
% HASFITSORRESULTS returns true data has fits check or results displayed
    retVal = false;
    
    evalresults = getappdata(line,'Basic_Fit_EvalResults');
    numresults = getappdata(line,'Basic_Fit_NumResults_');
    fitvector = getappdata(line,'Basic_Fit_Showing');
    datastatsx = getappdata(line, 'Data_Stats_X_Showing');
    datastatsy = getappdata(line, 'Data_Stats_Y_Showing');
    
    if (~isempty(evalresults) && ~isempty(evalresults.y)) || ...
        ~isempty(numresults) || ...
        any(fitvector) || any(datastatsx) || any(datastatsy)        
        retVal = true;
    end

%--------------------------------------------------------------------------
function userDataChanged(hSrc, event, fig)
% Listen for userdata of legend being changed
if ~isequal(get(event.affectedobject,'tag'),'legend')
    return
end

ud = event.newvalue;
% Have the handles changed?
if ~isfield(ud,'handles') | ~isfield(ud,'lstrings')
    return
end
datahandles = ud.handles;
datanames = ud.lstrings;
for j = 1:min(length(datahandles),length(datanames))
    d = datanames{j};
    % name must be a char row vector.
    if ~isequal(size(d,1),1)
        d = d';
        d = (d(:))';
    end
    % When deleting, the handle might be in the HG hierarchy, but not exist.
    if ishandle(datahandles(j))
        setappdata(datahandles(j),'bfit_dataname',d);
    end
end

updatedataselectors(fig);

%---------------------------------------------------------------
function updatedataselectors(fig)
%UPDATEDATASELECTORS Update the data lists in both GUIs.
% get the new list of names
[h,n] = bfitgetdata(fig);
if isempty(h)
    return;          % may be in a residual figure window
end

bfcurrentdata = getappdata(fig, 'Basic_Fit_Current_Data');

if ~isempty(bfcurrentdata)
    bfcurrentindex = find([ h{:} ] == bfcurrentdata );
    if ~isempty(bfcurrentindex)
        
		if ~isempty(findprop(handle(fig),'Basic_Fit_GUI_Object'))
            bf = get(handle(fig), 'Basic_Fit_GUI_Object');
            if ~isempty(bf)
                axesCount = []; fitschecked = []; bfinfo =[]; evalresultsstr = [];
                evalresultsx = []; evalresultsy =[]; currentfit = []; coeffresidstrings = [];
                
                if isempty(axesCount)
                    axesCount = -1; % bf.changeData does not like []
                end
                if isempty(currentfit)
                    currentfit = -1; % bf.changeData does not like []
                end
                bf.changeData(h,n,bfcurrentindex,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                    currentfit,coeffresidstrings);
                
            end
        end 
        
    end
end

dscurrentdata = getappdata(fig, 'Data_Stats_Current_Data');
if ~isempty(dscurrentdata)
    dscurrentindex = find([ h{:} ] == dscurrentdata );
    if ~isempty(dscurrentindex)
        if ~isempty(findprop(handle(fig),  'Data_Stats_GUI_Object'))
            ds = get(handle(fig), 'Data_Stats_GUI_Object');
            if ~isempty(ds)
                % initialize
                x_str = [];
                y_str = [];
                xcheck = [];
                ycheck = [];
                ds.addData(h, n, dscurrentindex, x_str, y_str, xcheck, ycheck); % Should be TagChanged or something
            end
        end 
    end
end

%-------------------------------------------------------------
function basicfitupdategui(fig,bfcurrentdata)
% BASICFITUPDATEGUI Get the current state from appdata and update the GUI.
if ~isempty(findprop(handle(fig),'Basic_Fit_GUI_Object'))
    bf = get(handle(fig), 'Basic_Fit_GUI_Object');
    if ~isempty(bf)
        [h,n] = bfitgetdata(fig);
		if ~isempty(bfcurrentdata)
            [axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,currentfit,coeffresidstrings] = ...
            bfitgetcurrentinfo(bfcurrentdata);
			bfcurrentindex = find([ h{:} ] == bfcurrentdata );
		else
            % If bfcurrentindex is zero, BasicFitGUI is cleared from bf.ChangeData. 
            % All other arguments ignored.
            bfcurrentindex = 0; 
            axesCount = [];
            currentfit = [];
            fitschecked = []; 
            bfinfo = []; % Default value: see bfitsetup.m
            evalresultsstr = []; evalresultsx = [];
            evalresultsy = []; coeffresidstrings = [];
		end
        if isempty(axesCount)
            axesCount = -1; % bf.changeData does not like []
        end
        if isempty(currentfit)
            currentfit = -1; % bf.changeData does not like []
        end
        bf.changeData(h,n,bfcurrentindex,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
            currentfit,coeffresidstrings);
        
    end
end


%-------------------------------------------------------------
function  [dscurrentindex,h,n,x_str,y_str,xcheck,ycheck] = datastatdeletedata(deletedline,fig,h,n)
% DATASTATDELETEDATA delete data in data stat gui.
dscurrentindex = [];
x_str = []; y_str = [];
xcheck = []; ycheck = [];

dscurrentdata = getappdata(fig,'Data_Stats_Current_Data');

% For data now showing, remove plots of data stat lines,
%  and clear checkboxes (appdata is deleted with the line so
%  no need to update.)
[xstatsH, ystatsH] = bfitdatastatremovelines(fig,deletedline);

% Don't need to continue if xstatsH is empty: GUI never open on this data
if ~isempty(xstatsH)
    % Update appdata for stats handles so legend can redraw
    setappdata(deletedline, 'Data_Stats_X_Handles', xstatsH);
    setappdata(deletedline, 'Data_Stats_Y_Handles', ystatsH);
    % reset what is showing 
    setappdata(deletedline,'Data_Stats_X_Showing',false(1,5));
    setappdata(deletedline,'Data_Stats_Y_Showing',false(1,5));
end   

% Remove the line handle from the cell array h
linetodelete = find([ h{:} ] == deletedline );
h(linetodelete) = [];
n(linetodelete) = [];
% initialize
x_str = [];
y_str = [];
xcheck = [];
ycheck = [];

if isempty(h) % Only line in h deleted
    dscurrentindex = 0; % signal that last line is deleted
    setappdata(fig,'Data_Stats_Current_Data',[]);
else % Line handles still left in h
    if isequal(dscurrentdata, deletedline) % current was deleted
        % New current data:
        % get data stats and GUI checkbox info for new current data based on appdata. 
        dscurrentindex = 1;
        dsnewdataHandle = h{1}; % make top of list current data
        % Get data stats and GUI checkbox info for new current data based on appdata. 
        [x_str, y_str, xcheck, ycheck] = bfitdatastatselectnew(fig, dsnewdataHandle);
        % Update current data appdata
        setappdata(fig,'Data_Stats_Current_Data', dsnewdataHandle);
    else % current data does not need to be updated
        % find the index of the current data
        dscurrentindex = find([ h{:} ] == dscurrentdata );
        if isempty(dscurrentindex)
            error('MATLAB:bfitlisten:InconsistentState', 'Current data set for GUI not in figure, inconsistent state.')    
        end
    end
end

%------------------------------------------------------------------------------------
function [bfcurrentindex,h,n,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
        currentfit,coeffresidstrings] = basicfitdeletedata(deletedline,fig,h,n);
%BASICFITDELETEDATA delete data in basic fit gui.
bfcurrentindex = [];
axesCount = []; fitschecked = []; bfinfo =[]; evalresultsstr = [];
evalresultsx = []; evalresultsy =[]; currentfit = []; coeffresidstrings = [];

bfcurrentdata = getappdata(fig,'Basic_Fit_Current_Data');

[fithandles, residhandles, residinfo] = bfitremovelines(fig,deletedline);

% Only continue if fithandles nonempty, otherwise GUI never used on this data
if ~isempty(fithandles)
    % Update appdata for line handles so legend can redraw
    setappdata(deletedline, 'Basic_Fit_Handles',fithandles);
    setappdata(deletedline, 'Basic_Fit_Resid_Handles',residhandles);
    setappdata(deletedline, 'Basic_Fit_Resid_Info',residinfo);
    % reset what is showing 
    setappdata(deletedline, 'Basic_Fit_Showing',false(1,12));
end

% Remove the line handle from the cell array h
if ~isempty(h)  % may have already deleted from h for Data Stat gui
    linetodelete = find([ h{:} ] == deletedline );
    h(linetodelete) = [];
    n(linetodelete) = [];
end
% initialize
x_str = [];
y_str = [];
xcheck = [];
ycheck = [];

if isempty(h) % Only line in h deleted
    bfcurrentindex = 0; % signal that last line is deleted
    setappdata(fig,'Basic_Fit_Current_Data',[]);
else % Line handles still left in h
    if isequal(bfcurrentdata, deletedline) % current was deleted
        % New current data:
        % get data stats and GUI checkbox info for new current data based on appdata. 
        bfcurrentindex = 1;
        bfnewdataHandle = h{1}; % make top of list current data
        % Get newdata info
        [axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,currentfit,coeffresidstrings] = ...
            bfitselectnew(fig, bfnewdataHandle);
        % Update current data appdata
        setappdata(fig,'Basic_Fit_Current_Data', bfnewdataHandle);
        % temporary fix
        if isempty(currentfit)
            currentfit = -1;
        end
    else % current data does not need to be updated
        % find the index of the current data
        bfcurrentindex = find([ h{:} ] == bfcurrentdata );
        if isempty(bfcurrentindex)
            error('MATLAB:bfitlisten:InconsistentState', 'Current data set for GUI not in figure, inconsistent state.')    
        end
    end
end


