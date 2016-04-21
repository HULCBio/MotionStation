function f = vrfigure(world, position)
%VRFIGURE Create a new Virtual Reality figure.
%   F = VRFIGURE(WORLD) creates a new Virtual Reality figure
%   showing the specified world and returns an appropriate
%   VRFIGURE object.
%
%   F = VRFIGURE(WORLD, POSITION) creates a new Virtual Reality
%   figure at the specified position.
%
%   F = VRFIGURE returns an empty VRFIGURE object which does not
%   have a visual representation.
%
%   F = VRFIGURE([]) returns an empty vector of type VRFIGURE.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.8.4.4 $ $Date: 2004/03/02 03:08:07 $ $Author: batserve $


% create an invalid VRFIGURE
if nargin==0
  f = struct('handle', 0);
  f = class(f, 'vrfigure');
  return;
end

% return VRFIGURE 0x0 array for VRFIGURE([])
if isempty(world)
  f = struct('handle', {});
  f = class(f, 'vrfigure');
  return;
end
        
% for internal use: create a VRFIGURE object referencing existing figures
if isa(world, 'double')

  % use the supplied handle
  f = struct('handle', num2cell(world));
    
  % add the class information
  f = class(f, 'vrfigure');
  return;
end
    
% now the argument must be a WRWORLD
if ~isa(world, 'vrworld')
  error('VR:invalidinarg', 'Argument must be of type VRWORLD.');
end

% handle position
if nargin>1
  if iscell(position)
    if numel(position) ~= numel(world)
      error('VR:invalidinarg', 'Cell array of positions must have the same length as array of worlds.');
    end
    pos = position;
  else
    pos(1:numel(world)) = {position};
  end
else
  pos(1:numel(world)) = {vrgetpref('DefaultFigurePosition')};
end

% initialize variables
f = struct('handle', cell(1,numel(world)));
f = class(f, 'vrfigure');

% loop through worlds
for i=1:numel(world)

  % look if the world is open
  if ~isopen(world(i))
    error('VR:worldnotopen', 'World is invalid or not open.');
  end

  % create the figure
  f(i).handle = vrsfunc('VRT3ViewScene', get(world(i), 'id'), pos{i});

  % set figure description 
  set(f(i), 'Name', get(world(i), 'Description'));      % title is the world description
end

% read preferences that start with 'DefaultFigure'
prefs = vrgetpref;
prefnames = fieldnames(prefs);
prefs = struct2cell(prefs);
prefidx = strncmp(prefnames, 'DefaultFigure', 13);
prefnames = prefnames(prefidx);
prefs = prefs(prefidx);

% remove the 'DefaultFigure' string from the preference name
for i=1:numel(prefnames)
  prefnames{i} = prefnames{i}(14:end);
end

% add clone function and edit function
prefnames = [prefnames; {'CreateFigureFcn'; 'StartEditorFcn'}];
prefs = [prefs; {'vrfigure(get(vrgcbf,''World''));'; 'edit(get(vrgcbf,''World''));'}];

% set figure defaults
set(f, prefnames, prefs');
