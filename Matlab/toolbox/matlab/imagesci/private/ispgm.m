function tf = ispgm(filename)
%ISPGM Returns true for a PGM file.
%   TF = ISPGM(FILENAME)

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:00:43 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 2, 'uint8');
    fclose(fid);
    tf = isequal(sig, [80;50]) | isequal(sig, [80;53]);
end
