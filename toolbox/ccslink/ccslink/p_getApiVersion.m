function [apiver,varargout] = p_getApiVersion
% P_GETAPIVERSION (Private) Returns the API version of the active Code
% Composer Studio IDE.

%   Copyright 2004 The MathWorks, Inc.
try
    
    ccsapp = actxserver('CodeComposer.Application');
    [apiver(1), apiver(2)] = GetApiVersion(ccsapp);
    if isempty(apiver) || length(apiver)~=2,
        error('Wrong API version format returned by the GetApiVersion().');
    end
    
    % Important: The following lines are very important for the CCSDSP
    % constructor to save time when instantiating the CCS application
    if nargout==2, 
        varargout{1} = ccsapp;
    end
    
catch
    error(generateccsmsgid('ApiVersionNotFound'),...
        'The API version of your Code Composer Studio IDE cannot be determined.');
end

% [EOF] p_getApiVersion.m