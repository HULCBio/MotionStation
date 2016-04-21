function curveH = bfitplotfit(datahandle,axesh,figh,pp,fit)
% BFITPLOTFIT plots a fit.
%    [CURVEH, LEGENDH, EQNTXTH] = BFITPLOTFIT(PP) plots a fit based on PP 
%    (coefficients in a form PPVAL or POLYVAL can understand) and 
%    the residuals.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.21.4.2 $  $Date: 2004/04/10 23:26:26 $


bfitlistenoff(figh)

% plot the fit 
figure(figh)
% save hold state and units and set it
fignextplot = get(figh,'nextplot');
axesnextplot = get(axesh,'nextplot');
axesunits = get(axesh,'units');
set(figh,'nextplot','add');
set(axesh,'nextplot','add');
set(axesh,'units','normalized');

xlimits = get(axesh,'xlim');
X = linspace(xlimits(1),xlimits(2),300);
guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
normalized = getappdata(datahandle,'Basic_Fit_Normalizers');

% Calculate with "newX" but plot with "X":
if guistate.normalize
    meanx = normalized(1);
    stdx = normalized(2);
else
    meanx = 0;
    stdx = 1;
end
switch fit
case {0,1} % spline or pchip
    % Y = ppval(pp,newX);
    fun = @bfitppval;
otherwise
    % Y = polyval(pp,newX);
    fun = @bfitpolyval;
end
color_order = get(axesh,'colororder');
colorindex = mod(fit,size(color_order,1)) + 1;
name = createname(fit,datahandle);
curve = graph2d.functionline(fun,'-userargs',{pp,meanx,stdx},'parent',axesh,'tag',name,'color',color_order(colorindex,:));

curveH = double(curve); % Convert to HG number handle.
fitappdata.type = 'fit'; 
fitappdata.index = fit + 1;
setappdata(curveH,'bfit',fitappdata);
p = schema.prop(handle(curveH), 'Basic_Fit_Copy_Flag', 'MATLAB array');
p.AccessFlags.Copy = 'off';

value = getappdata(datahandle,'Basic_Fit_Handles');
% we assume this is initialized in setup as an array
value(fit + 1) = curveH;
setappdata(datahandle,'Basic_Fit_Handles', value);
value = getappdata(datahandle,'Basic_Fit_Showing');
% we assume this is initialized in setup as a logical array
value(fit + 1) = logical(1);
setappdata(datahandle,'Basic_Fit_Showing', value);

% Later we'll upgrade to:
%curveH = curve.cline(func,{pp});

% reset plot: hold and units
set(figh,'nextplot',fignextplot);
set(axesh,'nextplot',axesnextplot);
set(axesh,'units',axesunits);

bfitlistenon(figh)

%----------------------------------
function name = createname(fit,datahandle)
% CREATENAME  Create tag name for fit line.

switch fit
case 0
    name = sprintf('spline');
case 1
    name = sprintf('shape-preserving');
case 2
    name = sprintf('linear');
case 3
    name = sprintf('quadratic');
case 4
    name = sprintf('cubic');
otherwise
    name = sprintf('%sth degree',num2str(fit-1));
end

%--------------------------------------------------------
function Y = bfitppval(X,pp,meanx,stdx)
% BFITPPVAL Call PPVAL with arguments in order and possibly scaled.

newX  = (X - meanx)./(stdx);
Y = ppval(pp,newX);
%--------------------------------------------------------
function Y = bfitpolyval(X,pp,meanx,stdx)
% BFITPOLYVAL Call POLYVAL with arguments in order and possibly scaled.

newX  = (X - meanx)./(stdx);
Y = polyval(pp,newX);

