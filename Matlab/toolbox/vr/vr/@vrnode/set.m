function set(node, varargin)
%SET Change a property of a virtual world node.
%   SET(N, PROPNAME, PROPERTYVALUE) changes a property of
%   the given VRNODE object.
%
%   SET(N, FIELDNAME, FIELDVALUE, FIELDNAME, FIELDVALUE, ...)
%   sets multiple property/value pairs.
%
%   Currently VRML nodes have no settable properties.
%   Property names are not case-sensitive.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.17.4.2 $ $Date: 2004/03/02 03:08:10 $ $Author: batserve $


% use this overloaded SET only if the first argument is VRNODE
if ~isa(node, 'vrnode')
  builtin('setfield',node,varargin{:});
  return;
end

% prepare pair of cell array of names and arguments
[propname, propval] = vrpreparesetargs(numel(node), varargin, 'property');

% loop through nodes
for i=1:size(propval, 1)
  
  % loop through property names
  for j=1:size(propval, 2)

    switch lower(propname{j})

      case {'fields', 'name', 'type', 'world'}
        error('VR:propreadonly', 'Node property ''%s'' is read-only.', propname{j});

      case {'parent'}
        warning('VR:obsoleteproperty', 'The ''Parent'' property is now obsolete. Please use ''World'' instead.');
        error('VR:propreadonly', 'Node property ''%s'' is read-only.', propname{j});

      otherwise
        warning('VR:obsoleteset', 'Using SET to set a field value is now obsolete. Please use SETFIELD instead.');
        setfield(node(i), propname{j}, propval{i,j});   %#ok this is overloaded SETFIELD

    end

  end
end
