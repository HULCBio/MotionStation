function tf = istif(filename)
%ISTIF Returns true for a TIF file.
%   TF = ISTIF(FILENAME)

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:00:48 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 4, 'uint8');
    fclose(fid);
    tf = isequal(sig, [73; 73; 42; 0]) | isequal(sig, [77; 77; 0; 42]);
end
