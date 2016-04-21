function tf = isppm(filename)
%ISPPM Returns true for a PPM file.
%   TF = ISPPM(FILENAME)

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:00:46 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 2, 'uint8');
    fclose(fid);
    tf = isequal(sig, [80;51]) | isequal(sig, [80;54]);
end
