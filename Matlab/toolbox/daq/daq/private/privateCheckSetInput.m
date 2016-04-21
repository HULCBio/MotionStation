function errflag = privateCheckSetInput(prop)
% PRIVATECHECKSETINPUT Verify SET property is valid.
%
%    ERRFLAG = PRIVATECHECKSETINPUT(PROP) returns a 1 if the specified
%    property, PROP, is invalid and returns a 0 if the specified property
%    PROP, is valid.
%

%    PRIVATECHECKSETINPUT is a helper function for daqdevice\set and
%    daqchild\set.

%    MP 8-04-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.7.2.4 $  $Date: 2003/08/29 04:42:14 $

% Initialize variabls.
errflag = 0;

% Error if PROP is empty.
% Error if PROP is not a cell, structure or string.
if (isempty(prop) && ~ischar(prop)) ||...
   (~(iscell(prop) || isstruct(prop) || ischar(prop)))
   errflag = 1;
   lasterr('Invalid parameter/value pair arguments.');
   return;
end
