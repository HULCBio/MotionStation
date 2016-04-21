function boo = hasdelay(sys)
%HASDELAY  True for LTI models with time delays.
%
%   HASDELAY(SYS) returns 1 (true) if the LTI model SYS has input, 
%   output, or I/O delays.
%
%   See also TOTALDELAY, DELAY2Z, LTIPROPS.

%   Author(s):  P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 05:50:44 $


% Check for delays
if any(sys.ioDelay(:)) | ...
      any(sys.InputDelay(:)) | ...
      any(sys.OutputDelay(:)),
   boo = 1;
else
   boo = 0;
end

