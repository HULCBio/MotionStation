function varargout = construct_warning( ids, warnType, warnMsg)

    if(nargout==0)
        construct_error( ids, warnType, warnMsg, -2);
    else
        varargout = cell(1,max(1,nargout));
        varargout{:} = construct_error( ids, warnType, warnMsg, -2);
    end
    
% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/15 00:56:26 $
