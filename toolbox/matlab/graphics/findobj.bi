%FINDOBJ Find objects with specified property values.
%   H = FINDOBJ('P1Name',P1Value,...) returns the handles of the
%   objects at the root level and below whose property values
%   match those passed as param-value pairs to the FINDOBJ
%   command.
%
%   H = FINDOBJ(ObjectHandles, 'P1Name', P1Value,...) restricts
%   the search to the objects listed in ObjectHandles and their
%   descendents.
%
%   H = FINDOBJ(ObjectHandles, 'flat', 'P1Name', P1Value,...)
%   restricts the search only to the objects listed in
%   ObjectHandles.  Their descendents are not searched.
%
%   H = FINDOBJ returns the handles of the root object and all its
%   descendents.
%
%   H = FINDOBJ(ObjectHandles) returns the handles listed in
%   ObjectHandles, and the handles of all their descendents.
%
%   See also SET, GET, GCF, GCA.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.7 $  $Date: 2002/04/10 17:07:56 $
%   Built-in function.
