function tf = ispbm(filename)
%ISPBM Returns true for a PBM file.
%   TF = ISPBM(FILENAME)

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:00:41 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 2, 'uint8');
    fclose(fid);
    tf = isequal(sig, [80;49]) | isequal(sig, [80;52]);
end
