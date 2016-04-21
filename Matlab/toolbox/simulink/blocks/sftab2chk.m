function sftab2chk(xindex,yindex,table)
%SFTAB2CHK Checks input to SFTABLE2 for correctness.
%   SFTAB2CHK(XINDEX,YINDEX,TABLE) makes sure that all of the arguments
%   to SFTABLE2 are appropriate.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.12 $
%   Ned Gulley 3-9-92

xlen = length(xindex);
ylen = length(yindex);
[m,n] = size(table);
if m ~= xlen,
  error('XINDEX must have the same number of elements as TABLE has rows');
end
if n ~= ylen,
  error('YINDEX must have the same number of elements as TABLE has columns');
end

if any(diff(xindex) <= 0),
  error('XINDEX must increase monotonically');
end
if any(diff(yindex) <= 0),
  error('YINDEX must increase monotonically');
end
