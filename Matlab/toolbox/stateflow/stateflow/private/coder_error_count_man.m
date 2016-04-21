function count = coder_error_count_man(method,errorCount)
% STATEFLOW CODER ERROR COUNT MANAGER
%   COUNT = CODER_ERROR_COUNT_MAN( METHOD)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.6.2.1 $  $Date: 2004/04/15 00:56:19 $


persistent sErrorCount;

if(isempty(sErrorCount))
   sErrorCount = 0;
end

switch(method)
case 'reset'
   sErrorCount = 0;
case 'add'
   if(nargin<2)
      errorCount = 1;
   end
   sErrorCount = sErrorCount+errorCount;
case 'get'
end

count = sErrorCount;