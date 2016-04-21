function wk1wrec(fid, rectype, vreclen)
%WK1WREC Write a WK1 record header.
%   WK1WREC(FID, RECTYPE, VRECLEN) writes out the WK1 record header
%   where RECTYPE(1) contains the record type, and RECTYPE(2) = -1
%   for fixed length records.
%   VRECLEN is the length for variable length records.
%
%   See also WK1WRITE, WK1READ.

%   Brian M. Bourgault 10/22/93
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.8.4.1 $  $Date: 2004/03/26 13:26:36 $

%
%   Write out the record type
%
fwrite(fid, rectype(1), 'ushort');

%
%   Write out the record length
%
if rectype(2) ~= -1
    % fixed length records
    fwrite(fid, rectype(2), 'ushort');
else
    % variable length records
    fwrite(fid, vreclen, 'ushort');
end

