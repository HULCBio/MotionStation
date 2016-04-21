function tf = islan(filename)
%ISLAN Returns true for a LAN or GIS file.
%   TF = ISLAN(FILENAME)
%
%   See also READLAN, WRITELAN, IMLANINFO

%   Copyright 1996-2003  The MathWorks, Inc.
%   $Revision: 1.1.10.2 $  $Date: 2003/08/01 18:23:42 $

fid = fopen(filename, 'r', 'ieee-le');

if (fid < 0)
    tf = logical(0);
else
    sig = fread(fid, 4, 'uchar');
    fclose(fid);
    tf = isequal(sig, [72; 69; 65; 68]);
end
