function plotresults = bfitcheckplotresults(checkon,datahandle,fit)
% BFITCHECKPLOTRESULTS Plot the evaluated results for a given data and fit.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.23.4.2 $  $Date: 2004/04/10 23:26:22 $

format = '%0.0f';
% plot the fit 
axesh = get(datahandle,'parent');
figh = get(axesh, 'parent');
% save hold state and units and set it
fignextplot = get(figh,'nextplot');
axesnextplot = get(axesh,'nextplot');
axesunits = get(axesh,'units');
set(figh,'nextplot','add');
set(figh,'nextplot','add');
set(axesh,'units','normalized');

bfitlistenoff(figh)

plotresults = getappdata(datahandle,'Basic_Fit_EvalResults');    
if ~isempty(plotresults.handle)
    figure(figh)
    delete(plotresults.handle);
end

if checkon
    axesH  = get(datahandle, 'parent');
    color_order = get(axesH,'colororder');
    colorindex = mod(fit,size(color_order,1)) + 1;

    if isequal('diamond',get(datahandle,'marker'))
        marker = 'square';
    else
        marker = 'diamond';
    end
    if ~isempty(plotresults.x) & ~isempty(plotresults.y)
        figure(figh);

        needtoresethold = true;
        if ishold(axesH)
            needtoresethold = false;
        else
            hold(axesH, 'on');
        end
        
        dispName = createname(fit,datahandle);
        plotresults.handle = plot(plotresults.x,plotresults.y,'parent', axesH, ...
            'tag', dispName, 'DisplayName', dispName, 'color',color_order(colorindex,:),...
            'marker',marker,'linestyle','none','LineWidth',2);
        
        if needtoresethold
            hold(axesH, 'off');
        end
        
        fitappdata.type = 'evalresults';
        fitappdata.index = fit + 1;
        setappdata(plotresults.handle,'bfit',fitappdata);    
		p = schema.prop(handle(plotresults.handle), 'Basic_Fit_Copy_Flag', 'MATLAB array');
		p.AccessFlags.Copy = 'off';
    else
        % No data to plot, so we just assume the user wants to
        % "preset" that checkbox for later.
        % We could put out a status message, but for now we don't.
        plotresults.handle = [];
    end
else
    plotresults.handle = [];
end
setappdata(datahandle, 'Basic_Fit_EvalResults',plotresults);
guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
guistate.plotresults = checkon;
setappdata(datahandle,'Basic_Fit_Gui_State', guistate);

% update legend
legendH = bfitcreatelegend(axesh);

% reset plot: hold and units
set(figh,'nextplot',fignextplot);
set(axesh,'nextplot',axesnextplot);
set(axesh,'units',axesunits);

bfitlistenon(figh)

%----------------------------------
function name = createname(fit,datahandle)
% CREATENAME  Create tag name for evalresults line.

switch fit
case 0
    name = sprintf('evaluated: spline');
case 1
    name = sprintf('evaluated: shape-preserving');
case 2
    name = sprintf('evaluated: linear'); 
case 3
    name = sprintf('evaluated: quadratic'); 
case 4
    name = sprintf('evaluated: cubic');
otherwise
    name = sprintf('evaluated: %sth degree',num2str(fit-1));
end