function bfitsavefit(datahandle, fit)
% BFITSAVEFIT Save a fit, as a struct, and the norm of resids to the workspace. 
%
%   BFITSAVEFIT(DATAHANDLE, FIT) saves the coefficients and type of FIT for data 
%   DATAHANDLE 

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2002/10/24 02:10:43 $

coeff = getappdata(datahandle,'Basic_Fit_Coeff');
resids = getappdata(datahandle,'Basic_Fit_Resids');
normvalue = norm(resids{fit+1});
fitvalue.type = fittype(fit);
fitvalue.coeff = coeff{fit+1};

checkLabels = {'Save fit as a MATLAB struct named:', ...
               'Save norm of residuals as a MATLAB variable named:'};
defaultNames = {'fit', 'normresid'};
items = {fitvalue, normvalue};
export2wsdlg(checkLabels, defaultNames, items, 'Save Fit to Workspace');

%------------------------------------------------------
function s = fittype(fit)
% FITTYPE Create fit type string.

switch fit
case 0
    s = 'spline';
case 1
    s = 'shape-preserving';
otherwise
    s = ['polynomial degree ',num2str(fit-1)];
end
