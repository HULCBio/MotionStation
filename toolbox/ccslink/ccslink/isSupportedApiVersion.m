function issupported = isSupportedApiVersion(ver)
% ISSUPPORTEDAPIVERSION Checks if the API version of the active CCS is
% currently supported.
% This function returns:
%   - 0 if earlier version, not supported
%   - 1 if older version, supported
%   - 2 if later version, supported
%   - 3 if new version, not supported

%   Copyright 2004 The MathWorks, Inc.

ver = str2num([num2str(ver(1)) '.' num2str(ver(2))]);

supported = p_supportedApiVersions;
oldestSupportedVersion = str2num([num2str(supported(1,1)) '.' num2str(supported(1,2))]);
newestSupportedVersion = str2num([num2str(supported(end,1)) '.' num2str(supported(end,2))]);

issupported = 0;

if ver<oldestSupportedVersion
    % Old CCS, not supported
    issupported = 0;
elseif ver>newestSupportedVersion
    % Newly released CCS, not tested - plug-in may run on this CCS
    issupported = 3;
else
    if ver==newestSupportedVersion
        issupported = 2; % New CCS - supported
    elseif ver==1.3, % exception
        issupported = 2; % New CCS - supported
    else, % older
        issupported = 1; % Old CCS - supported
    end
end


% [EOF] isSupportedApiVersion.m