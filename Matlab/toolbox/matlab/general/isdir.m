function result = isdir(dirpath)
%ISDIR  True if argument is a directory.
%   ISDIR(DIR) returns a 1 if DIR is a directory and 0 otherwise.
%
%   See also FINFO, MKDIR.

%   P. Barnard 1-10-95
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.20.4.1 $  $Date: 2004/03/17 20:05:16 $

result = exist(dirpath,'dir') == 7;
