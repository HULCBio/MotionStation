function [name, isnormal, newfit, type, dataset, outlier, hint, results] = cftoolgetopeneditorinfo(cftoolFit)
%CFTOOLGETOPENEDITORINFO Get information needed to open the cftool fit editor

%   $Revision: 1.1.6.1 $  $Date: 2004/02/01 21:40:11 $
%   Copyright 2004 The MathWorks, Inc.

cftoolFit=handle(cftoolFit);

name = cftoolFit.name;
fitOptions = cftoolFit.fitOptions;
isnormal = false;
if isequal(fitOptions.Normalize, 'on')
    isnormal = true;
end
type = cftoolFit.type;
if isempty(type)
    newfit=true;
    dataset='';
    outlier='';
    hint='';
    results='';
else
    newfit = false;
    dataset = cftoolFit.dataset;
    outlier = cftoolFit.outlier;
    hint = cftoolFit.hint;
    results = cftoolFit.results;
end
    


