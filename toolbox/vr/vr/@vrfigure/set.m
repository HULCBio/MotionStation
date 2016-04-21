function set(fig, varargin)
%SET Sets a Virtual Reality figure property.
%   SET(F, PROPNAME, PROPVALUE) sets a specified property PROPNAME
%   of the Virtual Reality Figure F to given value PROPVALUE.
%
%   SET(F, PROPNAME, PROPVALUE, PROPNAME, PROPVALUE, ...)
%   changes the given set of properties of the figure.
%
%   See VRFIGURE/GET for a detailed list of world properties.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.10.4.4 $ $Date: 2004/03/02 03:08:06 $ $Author: batserve $


% use this overloaded SET only if the first argument is of type VRWORLD
if ~isa(fig, 'vrfigure')
  builtin('set', fig, varargin{:});
  return;
end

% prepare pair of cell array of names and arguments
[propname, propval] = vrpreparesetargs(numel(fig), varargin, 'property');

% create the renamed properties table
renametbl = { 'InfoStrip', 'StatusBar';
              'PanelMode', 'NavPanel';
              'Title',     'Name';
            };

% loop through figures
for i=1:size(propval, 1)
  fh = fig(i).handle;

  % loop through property names
  for j=1:size(propval, 2)
    val = propval{i, j};

    % handle the renamed properties
    newname = renametbl(strcmpi(propname{j}, renametbl(:,1)), 2);
    if ~isempty(newname)
      newname = newname{1};
      warning('VR:obsoleteproperty', 'The property "%s" has been renamed to "%s". The old name still works, but will stop working in future releases.', ...
              propname{j}, newname);
      propname{j} = newname;
    end

    switch lower(propname{j})

      % 'World', 'Handle'
      case {'world', 'handle' }
        error('VR:propreadonly', 'Figure property ''%s'' is read-only.', propname{j});

        otherwise
        % the new way of setting figure properties
        % (vrsfunc handles errors automatically).
        vrsfunc('SetFigureProperty', fh, propname{j}, val);

    end

  end
end
