function bfitcheckplotresiduals(checkon,datahandle,plottype,subploton,showresidon)
% BFITCHECKPLOTRESIDUALS plots residuals.
%     BFITCHECKPLOTRESIDUALS(CHECKON,DATAHANDLE,PLOTTTYPE,SUBPLOTON,SHOWRESIDON)
%     plots residuals if CHECKON for data DATAHANDLE using plot 
%     type PLOTTYPE on a subplot if SUBPLOTON, otherwise on a 
%     separate figure. The norm of norm of the residuals is 
%     also shown as text on the plot if SHOWRESIDON.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.15 $  $Date: 2002/04/15 04:06:03 $


axesH = get(datahandle,'parent'); % need this in case subplots in figure
figH = get(axesH,'parent');
fitsshowing = find(getappdata(datahandle,'Basic_Fit_Showing'));
infarray = repmat(inf,1,12);

bfitlistenoff(figH)

residinfo = getappdata(datahandle,'Basic_Fit_Resid_Info');
residfigure = findobj(0,'Basic_Fit_Fig_Tag',residinfo.figuretag);
if ~isequal(figH,residfigure) & ishandle(residfigure)
    bfitlistenoff(residfigure)
end

if checkon
    [residinfo, residhandles] = bfitplotresids(figH,axesH,datahandle,fitsshowing,subploton,plottype); 
	residfigure = findobj(0,'Basic_Fit_Fig_Tag',residinfo.figuretag);
else
    % remove figure or axes 
    if figH ~= residfigure
        if ishandle(residfigure)
            delete(residfigure)
        end
    else
        if ishandle(residinfo.axes)
            figure(figH)
            delete(residinfo.axes) % this should delete the txt and all resid plots....
            % resize the figure plot to old size
            axesHposition = getappdata(datahandle,'Basic_Fit_Fits_Axes_Position');
            set(axesH,'position',axesHposition);
        end
    end
    
    % update handles
	residfigure = figH;
    residinfo.figuretag = get(handle(residfigure),'Basic_Fit_Fig_Tag');  % Leave as figH unless actually plot resids to another figure

    residinfo.axes = []; 
    residhandles = infarray;
    residtxtH = [];
    
end

setappdata(datahandle,'Basic_Fit_Resid_Info',residinfo); 
setappdata(datahandle,'Basic_Fit_Resid_Handles', residhandles); % array of handles of residual plots

guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
guistate.plotresids = checkon;
guistate.plottype = plottype;
guistate.subplot = ~subploton;
setappdata(datahandle,'Basic_Fit_Gui_State', guistate);


if showresidon
    bfitcheckshownormresiduals(checkon,datahandle)
    residtxtH = getappdata(datahandle,'Basic_Fit_ResidTxt_Handle'); % norm of residuals txt
else
    residtxtH = [];
end

% update appdata (whether on/off)

setappdata(datahandle,'Basic_Fit_ResidTxt_Handle', residtxtH); % norm of residuals txt

bfitlistenon(figH)

if ~isequal(figH,residfigure)
    bfitlistenon(residfigure)
end
