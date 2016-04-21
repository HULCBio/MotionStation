function isok = isvalid(obj)
%ISVALID True for data acquisition objects associated with hardware.
%
%    OUT = ISVALID(OBJ) returns a logical array, OUT, that contains a 1 
%    where the elements of OBJ are data acquisition objects associated 
%    with hardware and a 0 where the elements of OBJ are data acquisition 
%    objects not associated with hardware.
%
%    OBJ is an invalid data acquisition object when it is no longer 
%    associated with any hardware.  If this is the case, OBJ should be 
%    cleared from the workspace.
%
%    See also DAQHELP, DAQDEVICE/DELETE, DAQRESET, DAQ/PRIVATE/CLEAR.
%

%   CP 2-25-98
%   Copyright 1998-2003 The MathWorks, Inc.
%   $Revision: 1.10.2.4 $  $Date: 2003/08/29 04:40:26 $

isok = daqmex('IsValidHandle', obj);


