function tf = ispng(filename)
%ISPNG Returns true for a PNG file.
%   TF = ISPNG(FILENAME)

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:00:44 $

fid = fopen(filename, 'r', 'ieee-be');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 8, 'uint8')';
    fclose(fid);
    tf = isequal(sig, [137 80 78 71 13 10 26 10]);
end
