function [axesCount,fitschecked,bfinfo, ...
        evalresultsstr,evalresultsxstr,evalresultsystr,currentfit,coeffresidstrings] = ...
    bfitgetcurrentinfo(datahandle);
% BFITGETCURRENTINFO

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 04:05:51 $

fighandle = get(get(datahandle,'parent'),'parent');
axesCount = getappdata(fighandle,'Basic_Fit_Fits_Axes_Count');
fitschecked = getappdata(datahandle,'Basic_Fit_Showing');

evalresults = getappdata(datahandle,'Basic_Fit_EvalResults');
format = '%10.3g';
evalresultsstr = evalresults.string;
if isempty(evalresults.x)
    evalresultsxstr = '';
else   
    evalresultsxstr = cellstr(num2str(evalresults.x,format));
end
if isempty(evalresults.y)
    evalresultsystr = '';
else
    evalresultsystr = cellstr(num2str(evalresults.y,format));
end

currentfit = getappdata(datahandle,'Basic_Fit_NumResults_');

allcoeff = getappdata(datahandle,'Basic_Fit_Coeff');
allresids = getappdata(datahandle,'Basic_Fit_Resids');

if ~isempty(currentfit)
coeffresidstrings = ...
    bfitcreateeqnstrings(currentfit,allcoeff{currentfit+1},norm(allresids{currentfit+1}));
else
    coeffresidstrings = '';
end

guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
guistatecell = struct2cell(guistate);
bfinfo = [guistatecell{:}];