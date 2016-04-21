function out=rgstoredata(z,in)
%RGSTOREDATA Save information in a structure
%
%

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 16:56:37 $

persistent RPTGEN_STORED_FIXED_POINT_DATA

mlock

if nargin>1
   RPTGEN_STORED_FIXED_POINT_DATA=in;
end

out=RPTGEN_STORED_FIXED_POINT_DATA;
