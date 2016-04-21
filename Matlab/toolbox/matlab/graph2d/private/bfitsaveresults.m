function bfitsaveresults(datahandle)
% BFITSAVERESULTS Save evaluated results of a fit to the workspace. 
%
%   BFITSAVERESULTS(DATAHANDLE)saves the x values evaluated of current fit of 
%   data DATAHANDLE to the base workspace.  

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2002/10/24 02:10:44 $

evalresults = getappdata(datahandle,'Basic_Fit_EvalResults');
xvalue = evalresults.x;
yvalue = evalresults.y;

checkLabels = {'Save X in a MATLAB variable named:', ...
               'Save f(X) in a MATLAB variable named:'};
defaultNames = {'x', 'fx'};
items = {xvalue, yvalue};

export2wsdlg(checkLabels, defaultNames, items, 'Save Results to Workspace');
