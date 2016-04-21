function ans = uget_param(object, paramName)
% A unified "getparam" utility for Simulink/Stateflow configuration.
%
% Examples:
%     uget_param('model_name', 'SolverMode')
%     uget_param('model_name', 'GenerateSampleERTMain')
%     uget_param('model_name', 'RootIOStructures')
%     uget_param('model_name', 'StateBitSets')
%
% To get the table of supported parameters, use
%     uget_param('model_name')
%
% See also UGET_PARAM, GET_PARAM, SET_PARAM.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/15 00:49:54 $

% calling uset_param to read value
if nargin <2
    ans = uset_param(object, 'uget_param');
else
    ans = uset_param(object, 'uget_param', paramName);
end
