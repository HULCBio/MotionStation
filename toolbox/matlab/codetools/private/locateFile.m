function fullPathToFile = locateFile(file)
% LOCATEFILE Resolve a filename to an absolute location.
%   LOCATEFILE(FILE) returns the absolute path to FILE.  If FILE cannot be
%   found, it returns an empty string.

% Matthew J. Simoneau, November 2003
% $Revision: 1.1.6.1 $  $Date: 2003/12/24 19:11:53 $
% Copyright 1984-2003 The MathWorks, Inc.

% Checking that the length is exactly one in the first two checks automatically
% excludes directories, since directory listings always include '.' and '..'.

if (length(dir(fullfile(pwd,file))) == 1)
    % Relative path.
    fullPathToFile = fullfile(pwd,file);
elseif (length(dir(file)) == 1)
    % Absolute path.
    fullPathToFile = file;
elseif ~isempty(which(file))
    % An m-file on the path.
    fullPathToFile = which(file);
else
    fullPathToFile = '';
end
