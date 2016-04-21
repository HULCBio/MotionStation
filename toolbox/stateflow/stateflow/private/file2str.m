function str = file2str(fileName),

% Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:57:44 $

fid = fopen(fileName, 'r');
F = fread(fid);
str = char(F');
fclose(fid);
