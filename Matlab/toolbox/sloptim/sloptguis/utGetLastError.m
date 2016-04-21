function errmsg = utGetLastError()
% Extracts error message from LASTERR.

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:45:23 $
%   Copyright 1990-2004 The MathWorks, Inc.
[head,errmsg]=strtok(lasterr,sprintf('\n'));
if isempty(errmsg)
   errmsg = head;
end
