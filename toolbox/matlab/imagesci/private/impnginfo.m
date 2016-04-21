function [info,msg] = impnginfo(filename)
%IMPNGNFO Information about a PNG file.
%   [INFO,MSG] = IMPNGINFO(FILENAME) returns a structure containing
%   information about the PNG file specified by the string
%   FILENAME.  
%
%   If any error condition is encountered, such as an error opening
%   the file, MSG will contain a string describing the error and
%   INFO will be empty.  Otherwise, MSG will be empty.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, August 1996
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:32 $

info = [];
msg = '';

if (~ischar(filename))
    msg = 'FILENAME must be a string';
    return;
end

try
    info = png('info',filename);
    s = dir(filename);
    info.FileModDate = s.date;
    info.FileSize = s.bytes;
catch
    info = [];
    msg = lasterr;
end

