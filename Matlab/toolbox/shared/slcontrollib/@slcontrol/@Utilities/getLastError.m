function errmsg = getLastError(this)
% Extracts error message from LASTERR.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:08 $

[head, errmsg] = strtok( lasterr, sprintf('\n') );
if isempty(errmsg)
  errmsg = head;
end
