function [strings,err] = bfitCheckFitBox(checkon,...
    datahandle,fit,showeqnon,digits,plotresidon,plottype,subploton,showresidon)
%

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.18.4.1 $  $Date: 2002/12/24 12:06:35 $

strings = ' ';
err = 0;

axesH = get(datahandle,'parent'); % need this in case subplots in figure
figH = get(axesH,'parent');
infarray = repmat(inf,12,1);
figure(figH)
bfitlistenoff(figH)

if checkon
    % calculate fit and get resulting strings of info
    [strings, err, pp, resid] = bfitcalcfit(datahandle,fit);
    if err
        dlgh = getappdata(datahandle,'Basic_Fit_Dialogbox_Handle');
        if ishandle(dlgh) % if error or warning appeared, make sure it is on top
            figure(dlgh);
        end
        bfitlistenon(figH)
        return
    end
    
    % plot the curve/fit
    curveH = bfitplotfit(datahandle,axesH,figH,pp,fit);
    
    % update the legend so it's stuff + fits + evalresults
    legendH = bfitcreatelegend(axesH);
    
    % add equations to plot
    bfitcheckshowequations(showeqnon, datahandle, digits)
    
    % plot resids with other info on plot
    bfitcheckplotresiduals(plotresidon,datahandle,plottype,subploton,showresidon)
    
else % check off

    fitshandles = getappdata(datahandle,'Basic_Fit_Handles');
    fitsshowinglogical = getappdata(datahandle,'Basic_Fit_Showing');
    % delete fitline from plot
    if ishandle(fitshandles(fit+1)) && ~strcmpi(get(fitshandles(fit+1),'beingdeleted'),'on')
        delete(fitshandles(fit+1))
    end
    
    % Inf out the fitshowing appdata
    fitshandles(fit+1) = Inf;
    setappdata(datahandle,'Basic_Fit_Handles',fitshandles);
    fitsshowinglogical(fit+1) = logical(0);
    setappdata(datahandle,'Basic_Fit_Showing',fitsshowinglogical);
    
    % update legend
    legendH = bfitcreatelegend(axesH);
    
    % update eqntxt
    bfitcheckshowequations(showeqnon, datahandle, digits)
    
    % plot resids with other info on plot
    bfitcheckplotresiduals(plotresidon,datahandle,plottype,subploton,showresidon)
   
end
dlgh = getappdata(datahandle,'Basic_Fit_Dialogbox_Handle');
if ishandle(dlgh) % if error or warning appeared, make sure it is on top
    figure(dlgh);
end
bfitlistenon(figH)
