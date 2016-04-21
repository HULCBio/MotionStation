function names = geoattribnames(S)
%GEOATTRIBNAMES Obtain the attribute names from a geographic data struct.
%
%   NAMES = GEOATTRIBNAMES(S) returns the attribute names of the geographic
%   data struct S in the cell array NAMES. NAMES will be {} if no
%   attributes are present in S.
%
%   Example
%   -------
%       shape = shaperead('ponds.shp');
%       names = geoattribnames(shape);
%
%   See also GEOATTRIBSTRUCT, SHAPEREAD.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:52:35 $

% Extract the non-reserved names
checkstruct(S,mfilename,'S',1);
names = extractNames(S);

%-------------------------------------------------------------------

function names = extractNames(S)
names = {};
reservedNames = geoReservedNames;
fieldNames = fields(S);
for i=1:length(fieldNames);
    if isempty(strmatch(fieldNames{i}, reservedNames, 'exact'))
        names{end+1} = fieldNames{i};
    end
end

