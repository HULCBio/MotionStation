function sv = checkerforsuperval(nn,usersSV)
%CHECKERFORSUPERVAL - private function to verify operations on property STORAGEUNITSPERVALUE
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.2.1 $  $Date: 2003/11/30 23:13:32 $

if usersSV < 1,
    error('Numeric bit sizes are limited to byte increments (8,16,24,etc)');
    return;
end
sv = round(usersSV);
nn.numberofstorageunits = sv*prod(nn.size);

% [EOF] checkerforsuperval.m