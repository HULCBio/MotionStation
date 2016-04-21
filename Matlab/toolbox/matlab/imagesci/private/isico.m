function tf = isico(filename)
%ISICO Returns true for an ICO file.
%   TF = ISICO(FILENAME)

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:00:39 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 2, 'uint16');
    fclose(fid);
    tf = isequal(sig, [0; 1]);
end
