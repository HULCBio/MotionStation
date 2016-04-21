function result = cv_is_model_autoscale(model)

% Copyright 2003 The MathWorks, Inc.

result = get_param(model, 'CovAutoscale');
result = strcmp(result, 'on');
