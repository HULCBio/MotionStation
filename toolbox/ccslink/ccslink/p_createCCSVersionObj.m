function hCCSVersion = p_createCCSVersionObj(varargin)
%P_CREATECCSVERSIONOBJ (Private) Creates a CCSVersion object.
%Allowed syntaxes:
%  obj = p_createCCSVersionObj
%  obj = p_createCCSVersionObj([])
%  obj = p_createCCSVersionObj([APImajor,APIminor])
%
%The following are used by CCSDSP constructor only:
%  obj = p_createCCSVersionObj([],'warn')
%  obj = p_createCCSVersionObj([APImajor,APIminor],'warn')
%Tells the function to throw a warning if the API version CCS is a new
% and not yet tested.

% Copyright 2004 The MathWorks, Inc.

error(nargchk(0,2,nargin));

if nargin>=1 && ~isempty(varargin{1})
    apiversion = varargin{1};
else
    apiversion = p_getApiVersion;
end

resp = isSupportedApiVersion(apiversion);

if resp == 3, % advance version
    
    % Warning for any API version > currently supported version
    if nargin==2 && ischar(varargin{2}) && strcmp(varargin{2},'warn')
        warning(sprintf([...
        'This version of the Link for Code Composer Studio® has not been tested \n',...
        'with your version of Code Composer Studio® IDE. Refer to the Link for Code \n',...
        'Composer Studio® data sheet for supported versions of Code Composer Studio®.']));
    end
    
    hCCSVersion = ccs.CurrCCSVersion('apiversion',apiversion);        
    
elseif resp==2, % new version
    
    hCCSVersion = ccs.CurrCCSVersion('apiversion',apiversion);
    
elseif resp==1, % old version
    
    hCCSVersion = ccs.PrevCCSVersion('apiversion',apiversion);
    
else
    
    % Error for any old API version that is not supported anymore
    error(generateccsmsgid('UnsupportedCCSVersion'),...
        sprintf(['This version of the Link for Code Composer Studio® does not support your \n',...
        'version of Code Composer Studio® IDE. Refer to the Link for Code Composer Studio® \n',...
        'data sheet for supported versions of Code Composer Studio®.']));
end

% [EOF] p_createCCSVersionObj.m