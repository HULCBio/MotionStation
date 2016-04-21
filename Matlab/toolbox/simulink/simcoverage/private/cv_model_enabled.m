function	modelcovId = cv_model_enabled(model)
%CV_MODEL_ENABLED Check if coverage is enabled for a model.

%   Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.6 $

modelcovId = get_param(model,'CoverageId');
if modelcovId~=0
    activeRoot = cv('get',modelcovId,'.activeRoot');
    if activeRoot== 0,
        modelcovId = 0;
    end
end

