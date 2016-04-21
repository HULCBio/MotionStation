function clear(varargin)
%CLEAR Clear data acquisition object from the workspace.
%
%    CLEAR OBJ removes the data acquisition object, OBJ, from the
%    MATLAB workspace but not from the data acquisition engine.
%    OBJ can be a device object or a channel or a line.
%  
%    Therefore, if multiple references to an object exist in the workspace,
%    removing one reference will not invalidate the remaining references.
%    Cleared objects can be restored to the MATLAB workspace with DAQFIND.
%
%    To remove device objects, channels, or lines from the data acquisition
%    engine, DELETE should be used.
%
%    See also DAQFIND, DAQDEVICE/DELETE, ISVALID.
%

%   MP 9-30-98
%   Copyright 1998-2003 The MathWorks, Inc.
%   $Revision: 1.8.2.4 $  $Date: 2003/08/29 04:42:04 $
