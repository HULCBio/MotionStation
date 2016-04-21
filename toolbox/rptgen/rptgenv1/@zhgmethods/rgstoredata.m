function out=rgstoredata(z,in)
%RGSTOREDATA saves an information structure

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:47 $

persistent RPTGEN_STORED_HANDLE_GRAPHICS_DATA

mlock

if nargin>1
   RPTGEN_STORED_HANDLE_GRAPHICS_DATA=in;
end

out=RPTGEN_STORED_HANDLE_GRAPHICS_DATA;
