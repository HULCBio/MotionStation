function [x_str,y_str] = bfitevalfitbutton(datahandle,fit, expression, plotresultson, clearresults)
% BFITEVALFITBUTTON Interpolate/exrapolate using expression for fit.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.17 $  $Date: 2002/04/15 04:06:37 $

if nargin < 5
    clearresults = 0;
end
if clearresults
    x = []; y = []; errmsg = []; 
else
    [x,y,errmsg] = bfitevalfit(expression,datahandle,fit);
end
evalresults = getappdata(datahandle,'Basic_Fit_EvalResults');
evalresults.x = x; % x that we eval over (x = expression)
evalresults.y = y; % y = f(x) that we eval over (x = expression)
evalresults.string = expression;
% evalresults.handle will get set in bfitcheckplotresults below
% so we don't want to overwrite that handle since we'll need to delete
% the old one.
if ~isfield(evalresults,'handle')
	evalresults.handle = [];
end
setappdata(datahandle,'Basic_Fit_EvalResults',evalresults);
if isempty(errmsg)
    format = '%10.3g';
    x_str = cellstr(num2str(x,format));
    y_str = cellstr(num2str(y,format));
else
    x_str = {''};
    y_str = {''};
end
plotresults = bfitcheckplotresults(plotresultson,datahandle,fit);
 
