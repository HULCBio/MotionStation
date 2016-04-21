function result = find_by_type(varargin)
%find_by_type(object, 'type', options)
%  Finds objects of the specified type
%   shorthand for object.find('-isa', 'Package.type', options)
%
%	Tom Walsh
%   Copyright 2001-2002 The MathWorks, Inc.
%   $Revision: 1.1.2.1 $  $Date: 2004/04/15 00:57:46 $

if (nargin<2)
   error('Usage: find_by_type(object, type, findOptions');
end

obj = varargin{1};
pkgname = obj.classhandle.Package.Name;

% Here, we do a special case for searches from Stateflow.Root.
% We have to redirect calls to simulink's root instead
if (strcmp(obj.classhandle.Name, 'Root') & ...
    strcmp(pkgname, 'Stateflow'))
    obj = slroot;
end

% Interpret args
type = varargin{2};
varargin(1:2) = [];
    
% Get the objects
fullType = [pkgname '.' type];
result = obj.find('-isa', fullType, varargin);

% Filter out the original object
if (~isempty(result))
    originalIndices = find(result==obj);
    result(originalIndices) = [];
end
