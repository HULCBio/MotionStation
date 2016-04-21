function A = geoattribstruct(S)
%GEOATTRIBSTRUCT Obtain the attributes from a geographic data structure.
%
%   A = GEOATTRIBSTRUCT(S) returns the attributes of the geographic data
%   struct S in the structure A. A will be [] if no attributes are present
%   in S.
%
%   Example
%   -------
%       shape = shaperead('ponds.shp');
%       attributes = geoattribstruct(shape);
%
%   See also GEOATTRIBNAMES, SHAPEREAD.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:52:36 $

checkstruct(S,mfilename,'S',1);
A = rmReservedFields(S);

%-------------------------------------------------------------------

function attribs = rmReservedFields(S)

% Set initial values
attribs = S;
names = {};
reservedNames = geoReservedNames;

% Obtain the names that match the reservedNames
fieldNames = fields(S);
for i=1:length(fieldNames)
    if ~isempty(strmatch(fieldNames{i}, reservedNames, 'exact'))
        names{end+1} = fieldNames{i};
    end
end

% If the number of names equals number of fieldNames
%  then no attributes are present and return [];
% otherwise, remove the reserved fields from the 
%  original structure. 
if  numel(names) == numel(fieldNames) 
   attribs = [];
elseif ~isempty(names)
   attribs = rmfield(S, names);
end

