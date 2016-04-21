function [fithandles, residhandles, residinfo] = bfitremovelines(figHandle,datahandle, deleteresid)
% BFITREMOVELINES remove fit, evalresults, and resid lines for the current data.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2003/02/25 07:53:43 $

% Initialize
if nargin < 3
	deleteresid = 1;
end

residhandles = repmat(inf,1,12);
residinfo.axes = []; % handle

% for data now showing, remove plots and update appdata
fithandles = getappdata(datahandle,'Basic_Fit_Handles'); % array of handles of fits

% If fithandles empty, GUI never called on this data
if ~isempty(fithandles) 
    residhandles = getappdata(datahandle,'Basic_Fit_Resid_Handles'); % array of handles of residual plots
    residinfo = getappdata(datahandle,'Basic_Fit_Resid_Info');
    residfigure = findobj(0,'Basic_Fit_Fig_Tag',residinfo.figuretag);

    bfitlistenoff(figHandle)

    if ~isempty(residfigure) && ~isequal(figHandle,residfigure) &&  ishandle(residfigure)
        bfitlistenoff(residfigure)
    end
    
    % "Showing" is what would be showing if this were the current data, i.e.
    %    corresponds to the checkboxes in the GUI
    showing = getappdata(datahandle,'Basic_Fit_Showing'); % array of logicals: 1 if showing
    guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
    
    bfcurrentdata = getappdata(figHandle,'Basic_Fit_Current_Data');
    dataIsCurrent = isequal(bfcurrentdata, datahandle);
    
    % Delete plots, update handles to Inf
    % Don't update "Showing" appdata since that tells us what to replot if needed
    %  (i.e. what checkboxes were checked)
    for i = find(showing)
        % If axis deleted, the fit is already deleted before data
        if dataIsCurrent && ishandle(fithandles(i))  
            delete(fithandles(i));
        end
        fithandles(i) = Inf;
    end
    if guistate.plotresids
        for i = find(showing)
        % If axis deleted, the resids already deleted before data
            if dataIsCurrent && ishandle(residhandles(i))
                delete(residhandles(i));
            end
            residhandles(i) = Inf;
        end
        if guistate.showresid
            residtxth = getappdata(datahandle,'Basic_Fit_ResidTxt_Handle');
            if dataIsCurrent && ~isempty(residtxth) && ishandle(residtxth)
                delete(residtxth);
            end
            setappdata(datahandle,'Basic_Fit_ResidTxt_Handle',[]);
        end
        
		if deleteresid
			if residfigure ~= figHandle
                if dataIsCurrent && ~isempty(residfigure) && ishandle(residfigure)  
    			    delete(residfigure);
				end
				residfigure = figHandle;
				residinfo.figuretag = get(handle(figHandle),'Basic_Fit_Fig_Tag');
				residinfo.axes = [];
			else
                if dataIsCurrent && ~isempty(residinfo.axes) && ishandle(residinfo.axes)
                    delete(residinfo.axes);
                end
				residinfo.axes = [];
				% restore fit axes
                if dataIsCurrent
    				axesH = getappdata(datahandle,'Basic_Fit_Fits_Axes_Handle'); 
    				axesposition = getappdata(datahandle,'Basic_Fit_Fits_Axes_Position');
    				set(axesH,'position',axesposition);
                end
			end
		end
	end
    
    if guistate.equations
        eqntxth = getappdata(datahandle,'Basic_Fit_EqnTxt_Handle');
        if dataIsCurrent && ~isempty(eqntxth) && ishandle(eqntxth)
            delete(eqntxth);
        end
        setappdata(datahandle,'Basic_Fit_EqnTxt_Handle',[]);
    end
    if guistate.plotresults
        evalresults = getappdata(datahandle,'Basic_Fit_EvalResults');
        if dataIsCurrent && ~isempty(evalresults.handle) && ishandle(evalresults.handle)
            delete(evalresults.handle);
        end
        evalresults.handle = [];
        setappdata(datahandle,'Basic_Fit_EvalResults',evalresults);
    end
    
    bfitlistenon(figHandle)
    if ~isequal(figHandle,residfigure)
        bfitlistenon(residfigure)
    end
    
end