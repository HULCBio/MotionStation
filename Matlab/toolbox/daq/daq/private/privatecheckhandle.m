function out = privatecheckhandle(varargin)
%PRIAVTECHECKHANDLE Determine if data acquisition objects are valid.
%
%    OUT = PRIAVTECHECKHANDLE(OBJ1, OBJ2,...) determines if data
%    acquisition objects OBJ1, OBJ2,... have valid handles.
%    OUT is 1 if the object's have valid handles and 
%    OUT is 0 if the object's do not have valid handles.
%

%    PRIAVTECHECKHANDLE is a helper function for HORZCAT and VERTCAT.

%    MP 6-12-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.4 $  $Date: 2003/08/29 04:42:24 $

% Initialize variables.
out = 1;
chan = varargin{:};

% Determine if an invalid object was passed.
for i = 1:length(chan)
   if ~isempty(chan{i})
      out = isvalid(chan{i});
      if out == 0
         return;
      end
   end
end
