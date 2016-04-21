function residnrmTxtH = bfitcreatenormresidtxt(residaxesH,residfigH,datahandle,fitsshowing);
% BFITCREATENORMRESIDTXT Add to plot the text norm of residuals for Basic Fitting GUI.

%   Copyright 1984-2002 The MathWorks, Inc.  
%   $Revision: 1.17 $  $Date: 2002/04/15 04:06:33 $

residnrmTxtH = [];

n = length(fitsshowing);
if n==0 |  isempty(residaxesH) % no fits plotted OR no residuals plotted
    return
end

if ishandle(residfigH)
    bfitlistenoff(residfigH);
end

txt = cell(n,1);
for i = 1:n
    % get fit type
    fittype = fitsshowing(i)-1;
    % add string to matrix
    resid = getappdata(datahandle,'Basic_Fit_Resids');
    txt{i,:} = residtxtstring(fittype,norm(resid{fitsshowing(i)}));
end

figure(residfigH)
% check hold state and save it
fignextplot = get(residfigH,'nextplot');
axesnextplot = get(residaxesH,'nextplot');
axesunits = get(residaxesH,'units');
set(residfigH,'nextplot','add');
set(residaxesH,'nextplot','add');
set(residaxesH,'units','normalized');

xlims = get(residaxesH,'xlim');
ylims = get(residaxesH,'ylim');
residnrmTxtH = getappdata(datahandle,'Basic_Fit_ResidTxt_Handle');
if ~isempty(residnrmTxtH)
    delete(residnrmTxtH);
end
residnrmTxtH=text(xlims*[.95;.05],ylims*[.05;.95],txt,'parent',residaxesH, ...
    'tag', 'norm of residuals', ...
    'verticalalignment','top');

% reset plot: hold and units
set(residfigH,'nextplot',fignextplot);
set(residaxesH,'nextplot',axesnextplot);
set(residaxesH,'units',axesunits);

bfitlistenon(residfigH)

%-------------------------------------------------------
function s = residtxtstring(fit,resid)
% RESIDTXTSTRING Create the text with norm of residuals.

s='';

switch fit
case 0
    s = sprintf('%s%s',s,'Spline: norm of residuals = ');
    s = sprintf('%s%s',s, num2str(0));
case 1
    s = sprintf('%s%s',s,'Shape-preserving: norm of residuals = ');
    s = sprintf('%s%s',s, num2str(0));
case 2
    s = sprintf('%s%s',s,'Linear: norm of residuals = ');
    s = sprintf('%s%s',s, num2str(resid));
case 3
    s = sprintf('%s%s',s,'Quadratic: norm of residuals = ');
    s = sprintf('%s%s',s, num2str(resid));
case 4
    s = sprintf('%s%s',s,'Cubic: norm of residuals = ');
    s = sprintf('%s%s',s, num2str(resid));
otherwise
    s = sprintf('%s%s%s',s,num2str(fit-1),'th degree: norm of residuals = ');
    s = sprintf('%s%s',s, num2str(resid));
end
