function save(world, filename)
%SAVE Save the virtual world to a VRML file.
%   SAVE(WORLD, FILENAME) saves the virtual world referred to
%   by VRWORLD handle W to the VRML file FILENAME.
%
%   The resulting file is a VRML97 compliant, UTF-8 encoded text file.
%   Lines are indented using spaces. Line ends are encoded as CR-LF
%   or LF according to the local system default. Values are separated
%   by spaces.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.10.4.3 $ $Date: 2004/04/06 01:11:11 $ $Author: batserve $


% use this overloaded SAVE only if the first argument is of type VRWORLD
if ~isa(world, 'vrworld')
  builtin('save',world,filename);
  return;
end

if nargin<2
  warning('VR:obsoletesave', ...
         ['The form "save(world)" is now obsolete and performs no action for security reasons.\n', ...
          'To get equivalent functionality, please use "save(world,get(world,''FileName''))" instead.']);
  return;
end

% check arguments
if ischar(filename)
  filename = {filename};
elseif ~iscellstr(filename)
  error('VR:invalidinarg', 'File name must be a string or a cell array of strings.');
end
if numel(world) ~= numel(filename)
  error('VR:invalidinarg', 'There must be a file name for each world.');
end

% save all the worlds in a loop
for i = 1:numel(world)
  vrsfunc('SaveScene', get(world, 'Id'), filename{i});
end
