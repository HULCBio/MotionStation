function tf = isfits(filename)
%ISFITS Returns true for a FITS file.
%   TF = ISFITS(FILENAME)

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:00:36 $

fid = fopen(filename, 'r');
if (fid < 0)
    tf = false;
else
    sig = fread(fid, 6, 'char=>char')';
    fclose(fid);
    tf = isequal(sig, 'SIMPLE');
end
