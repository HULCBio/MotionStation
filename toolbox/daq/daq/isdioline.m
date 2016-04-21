function out = isdioline(obj)
%ISDIOLINE True for lines.
%
%    ISDIOLINE(OBJ) returns a logical 1 if OBJ is a line or line 
%    array and returns a logical 0 otherwise.
%
%    See also ISVALID.
%

%    MP 3-24-99
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.4.2.4 $  $Date: 2003/08/29 04:40:58 $

% A non-daqchild object cannot be a line.
out = logical(0);