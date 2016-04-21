function [axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
        currentfit,coeffresidstrings] = bfitselectnew(figHandle, newdataHandle)
% BFITSELECTNEW Update basic fit GUI and figure from current data to new data.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.13.4.1 $  $Date: 2003/02/25 07:53:44 $

% for new data, was it showing before?
guistate = getappdata(newdataHandle,'Basic_Fit_Gui_State');
if isempty(guistate) % new data
    %setup appdata and compute stats: nothing plotted since new data
    [axesCount,fitschecked,bfinfo,evalresults,currentfit] = bfitsetup(figHandle, newdataHandle); % data stats computed
    evalresultsstr = '';  
    evalresultsx = '';
    evalresultsy = '';
    coeffresidstrings = ' ';
    
else % was showing before: get fit info to return, and replot
    [axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,currentfit,coeffresidstrings] = ...
        bfitgetcurrentinfo(newdataHandle);
    
    axesH = get(newdataHandle,'parent'); % need this in case subplots in figure
    figH = get(axesH,'parent');
    figure(figH)
    bfitlistenoff(figH)
        
    for fitindex = find(fitschecked)
        fit = fitindex - 1;
        [strings, err, pp] = bfitcalcfit(newdataHandle,fit);
        if err % Shouldn't happen - data changes are now dealt with explicitly.
               % See bfitlisten.m
            error('MATLAB:bfitselectnew:calcfiterr', 'Error calculting fit.')
        end
        if isequal(fit,currentfit) % so updates when normalized/unnormalized.
            coeffresidstrings = strings;
        end
        bfitplotfit(newdataHandle,axesH,figH,pp,fit);
    end         
    if ~isempty(currentfit) % update strings in 2nd panel if there
                            % is a current fit
        [coeffresidstrings, err] = bfitcalcfit(newdataHandle,currentfit);
        if err % Shouldn't happen - data changes are now dealt with explicitly
               % See bfitlisten.m
            error('MATLAB:bfitselectnew:calcfiterr', 'Error calculting fit.')
        end
    elseif isempty(currentfit)
        coeffresidstrings = ' ';  % if current fit is empty, the 2nd panel is empty
    end
    
    % update the legend so it's stuff + fits + evalresults
    bfitcreatelegend(axesH);
    
    % add equations to plot
    if guistate.equations
        bfitcheckshowequations(guistate.equations, newdataHandle, guistate.digits)
    end
    
    if guistate.plotresids
        % plot resids with other info on plot
        bfitcheckplotresiduals(guistate.plotresids,newdataHandle, ...
            guistate.plottype,~(guistate.subplot),guistate.showresid);
    end
    
	% Recalculate and replot Evaluated results if needed 
    plotresults = getappdata(newdataHandle,'Basic_Fit_EvalResults'); 
	% only "clearresults" if plotresults.x plotresults.y both empty
	clearresults = (isempty(plotresults.x) && isempty(plotresults.y)) || isempty(currentfit);
	[evalresultsx,evalresultsy] = ...
		bfitevalfitbutton(newdataHandle,currentfit, plotresults.string, guistate.plotresults, clearresults);
    % Make sure currentfit is what it was to begin with	(bfitcalcfit may have changed it)
    setappdata(newdataHandle,'Basic_Fit_NumResults_',currentfit);
	bfitlistenon(figH)
end
