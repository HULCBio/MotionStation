function cvresolve(model)
%CVRESOLVE - Update the links between coverage data and Simulink.
%
%   CVRESOLVE Update the links between the Simulink models and
%   their equivalent representations within the coverage data
%   dictionary.  The update is performed for all models that are
%   loaded in both Simulink and the coverage data dictionary.
%
%   CVRESOLVE(MODEL) Update the links for the specified model.
%
%   See also CVLOAD, CVSAVE.

%   Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.9.2.2 $  $Date: 2004/04/15 00:36:59 $

if check_cv_license==0
    error(['Failed to check out Simulink Verification and Validation license,', ...
           ' required for model coverage']);
end

if ~isempty(model)
    if ~ischar(model)
        error('Model name should be a string');
    end
    try
        bdHandle = get_param(model,'Handle');
    catch
        error('Could not find the specified model');
    end

    modelId = cv('find','all','modelcov.name',model);
    switch length(modelId)
    case 0,
        warning('The model does not exist in the coverage data dictionary');
        return;
    case 1,
        resolve_this_model(modelId,bdHandle);
        return;
    otherwise
        error('More than one model with the same name');
    end
end

cvModels = cv('get','all','modelcov.id');

for modelId = cvModels(:)'
    try
        bdHandle = get_param(cv('get',modelId,'.name'),'Handle')
    catch
        break;
    end
    resolve_this_model(modelId,bdHandle);
end


function resolve_this_model(modelId,bdHandle)

    cv('ResolveSlLinks',modelId);