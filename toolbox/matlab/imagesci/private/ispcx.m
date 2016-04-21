function tf = ispcx(filename)
%ISPCX Returns true for a PCX file.
%   TF = ISPCX(FILENAME)

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/01 16:12:28 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    header = fread(fid, 128, 'uint8');
    fclose(fid);
    if (length(header) < 128)
        tf = false;
    else
        tf = (header(1) == 10) && ...
             (ismember(header(2), [0 2 3 4 5])) && ...
             (header(3) == 1);
    end
end
