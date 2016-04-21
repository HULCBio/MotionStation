function tf = ispnm(filename)
%ISPBM Returns true for a PNM file (PBM, PGM, or PPM).
%   TF = ISPBM(FILENAME)

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:38 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 2, 'uint8');
    fclose(fid);
    tf = ((isequal(sig, [80;49]) || isequal(sig, [80;52])) || ...  % PBM
          (isequal(sig, [80;50]) || isequal(sig, [80;53])) || ...  % PGM
          (isequal(sig, [80;51]) || isequal(sig, [80;54])));      % PPM
end
