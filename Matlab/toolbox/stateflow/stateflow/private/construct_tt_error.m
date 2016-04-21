function count = construct_tt_error(method,ids,msg,throwFlag)
% CONSTRUCT_CODER_ERROR(IDS,MSG,THROWFLAG)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/15 00:56:25 $
persistent sErrorCount;

if(isempty(sErrorCount))
    sErrorCount = 0;
end

switch(method)
    case 'reset'
        sErrorCount = 0;
    case 'add'
        if(nargin<4)
            throwFlag = 0;
        end
        sErrorCount = sErrorCount+1;
        if(isempty(msg))
            msg = 'Unexpected internal error';
            throwFlag = 1;
        end
        sf('Private','construct_error',ids,'Parse',msg,throwFlag);
    case 'get'
end
count = sErrorCount;
