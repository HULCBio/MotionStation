function [fullname, name]=getimgname(propval)

% GETIMGNAME - xPC Target private function

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.5.2.1 $ $Date: 2004/03/04 20:09:56 $

dir = fullfile(xpcroot, 'target', 'kernel');
if strcmpi(propval{25}, 'DOSLoader') || strcmpi(propval{25}, 'Standalone')
  dir = fullfile(dir, 'embedded');
end

name = ['xpc' ...
        assoc('HostTargetComm', propval{11},                              ...
              {'RS232', 'TCPIP'},                        {'s', 't'})      ...
        assoc('TargetScope', propval{23},                                 ...
              {'Disabled', 'Enabled'},                   {'t', 'g'})      ...
        assoc('TargetBoot', propval{25},                                  ...
              {'BootFloppy', 'DOSLoader', 'Standalone'}, {'b', 'o', 'a'}) ...
        assoc('MaxModelSize', propval{8},                                 ...
              {'1MB', '4MB', '16MB'},                   {'1', '4', '16'}) ...
        '.rtb'];

fullname = fullfile(dir, name);

function result = assoc(name, lookFor, keys, values)
% Return the value associated with lookFor. Keys and values are cell
% arrays of the same length. Errors out if not found. name is used in the
% error message. The match is case insensitive
idx = strmatch(lower(lookFor), lower(keys), 'exact');
if length(idx) ~= 1
  error('xPCTarget:InvalidEnvValue', ...
        'Invalid or ambiguous value %s for property %s\n', lookFor, name);
  result = [];
else
  result = values{idx};
end
