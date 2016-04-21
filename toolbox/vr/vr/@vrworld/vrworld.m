function w = vrworld(filename)
%VRWORLD Create a virtual world.
%   W = VRWORLD(FILENAME) creates a virtual world associated with VRML file
%   FILENAME and returns its handle. If the virtual world already exists a
%   handle to the existing virtual world is returned.
%
%   W = VRWORLD creates an empty VRWORLD handle which does not
%   refer to any virtual world.
%
%   W = VRWORLD([]) returns an empty array of VRWORLD handles.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.11.4.6 $ $Date: 2004/04/06 01:11:14 $ $Author: batserve $



% create an empty VRWORLD if no arguments or for VRWORLD('')
if nargin==0 || (isempty(filename) && ischar(filename))
  This = struct('id', 0);
  w = class(This, 'vrworld');
  return;
end

% return VRWORLD 0x0 array for VRWORLD([])
if isempty(filename)
  This = struct('id', {});
  w = class(This, 'vrworld');
  return;
end

% argument is a number: return a VRWORLD representing that scene number
if isa(filename, 'double')
  This = struct('id', num2cell(filename));
  w = class(This, 'vrworld');
  return;
end

% validate input arguments
if ~ischar(filename)
  error('VR:invalidinarg', 'FILENAME must be a string.');
end

% add '.wrl' extension if no extension
[p,n,e,v] = fileparts(filename);
if isempty(e)
  filename = fullfile(p, [n '.wrl' v]);
end

% try finding the file on MATLABPATH, consider the path absolute if not found
foundname = which(filename);
if isempty(foundname)
  foundname = filename;
end

% load it or use previously loaded version
previd = vrsfunc('VRT3SceneByFilename', foundname);
if previd~=0
  This.id = previd;
else 
  This.id = vrsfunc('VRT3LoadScene', foundname);
end
w = class(This, 'vrworld');

% set world defaults only for newly created world
if previd==0
  % read preferences that start with 'DefaultWorld'
  prefs = vrgetpref;
  prefnames = fieldnames(prefs);
  prefs = struct2cell(prefs);
  prefidx = strncmp(prefnames, 'DefaultWorld', 12);
  prefnames = prefnames(prefidx);
  prefs = prefs(prefidx);

  % remove the 'DefaultWorld' string from the preference name
  for i=1:numel(prefnames)
    prefnames{i} = prefnames{i}(13:end);
  end

  % set world defaults
  set(w, prefnames, prefs');
end
