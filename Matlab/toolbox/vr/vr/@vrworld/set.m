function set(world, varargin)
%SET Change a property of a VRWORLD object.
%   SET(W, PROPNAME, PROPVALUE) changes a property of the
%   virtual world associated with the given VRWORLD object.
%
%   SET(W, PROPNAME, PROPVALUE, PROPNAME, PROPVALUE, ...)
%   changes the given set of properties of the virtual world.
%
%   See VRWORLD/GET for a detailed list of world properties.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.9.2.3 $ $Date: 2004/03/02 03:08:16 $ $Author: batserve $


% use this overloaded SET only if the first argument is of type VRWORLD
if ~isa(world, 'vrworld')
  builtin('set',world,varargin{:});
  return;
end

% prepare pair of cell array of names and arguments
[propname, propval] = vrpreparesetargs(numel(world), varargin, 'property');

% loop through worlds
for i=1:size(propval, 1)
  wid = world(i).id;

  % loop through property names
  for j=1:size(propval, 2)
    val = propval{i, j};

    switch lower(propname{j})

      case { 'clients', 'figures', 'nodes', 'id' }
        % some properties need special handling
        error('VR:propreadonly', 'World property ''%s'' is read-only.', propname{j});
        
      otherwise
        % it is not a special property, use the common way
        vrsfunc('SetSceneProperty', wid, propname{j}, val);
    end
  end
end
