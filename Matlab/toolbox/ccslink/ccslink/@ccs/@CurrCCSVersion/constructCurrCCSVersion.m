function h = constructCurrCCSVersion(h,args)

%   Copyright 2004 The MathWorks, Inc.

nargs = nargin;

% Process constructor's input arguments, if any
if nargs <= 1
    return;      % Use defaults
else
    
    if(mod(nargs,2)~=0)
        error(['CurrCCSVersion constructor requires property and value ', ...
                'arguments to be specified in pairs.']);
    end
    
    % Get property / value pairs from argument list
    for i = 1:2:nargs
        prop = lower(args{i});
        val  = args{i+1};
        % Argument checking
        switch prop
        case 'apiversion'
            h.apiVersion = val;
        otherwise
            error('Unknown property specified for CurrCCSVersion object.')
        end
    end
    
    % Set ccsversion (for now, we rely on the API version to determine the
    % CCS version).
    [supportedApi,supportedCcs] = p_supportedApiVersions;
    if h.apiversion(1)==supportedApi(end,1) && h.apiversion(2)==supportedApi(end,2),
        h.ccsVersion = supportedCcs{2};
    else
        h.ccsVersion = supportedCcs{1};
    end
    
end

% [EOF] constructCurrCCSVersion.m