function boo = isstatic(L)
%ISSTATIC  True for static gains
%
%   ISSTATIC(SYS.LTI) returns 1 if the LTI parent SYS.LTI has
%   no time delays.
%
%   See also TF/ISSTATIC.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 05:50:26 $

boo = ~any(L.ioDelay(:)) & ~any(L.InputDelay(:)) & ...
      ~any(L.OutputDelay(:));
