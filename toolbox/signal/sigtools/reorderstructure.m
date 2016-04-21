function sout = reorderstructure(sin, varargin)
%REORDERSTRUCTURE   Reorder the structure fields
%   REORDERSTRUCTURE(S, FIELD1, FIELD2, etc) reorders the structure S so
%   that FIELD1 is the first field, FIELD2 is the second field, etc.  Any
%   fields that are not specified are added to the end of the new structure
%   in their orignal order.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:32:45 $

% We need to know at least 1 field.
error(nargchk(2,inf,nargin));

allfields = fieldnames(sin);

for indx = 1:length(varargin)
    sout.(varargin{indx}) = sin.(varargin{indx});
    allfields(find(strcmp(varargin{indx}, allfields))) = [];
end

for indx = 1:length(allfields)
    sout.(allfields{indx}) = sin.(allfields{indx});
end

% [EOF]
