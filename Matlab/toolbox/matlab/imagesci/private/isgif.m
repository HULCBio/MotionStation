function tf = isgif(filename)
%ISGIF Returns true for a GIF file.
%   TF = ISGIF(FILENAME)

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:00:37 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 3, 'uint8');
    fclose(fid);
    tf = isequal(sig, [71; 73; 70]);
end
