function f = filesep
%FILESEP Directory separator for this platform.
%   F = FILESEP returns the file separator character for this platform.
%   The file separator is the character that separates
%   directory names in filenames.
%
%   See also PATHSEP, FULLFILE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.17.4.2 $  $Date: 2004/04/10 23:29:24 $

if strncmp(computer,'PC',2)
    f = '\';
else  % isunix
    f = '/';
end
