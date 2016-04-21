function dummy = copy_memoryobj(mm,resp)
%   Private. Copies over MM properties to RESP.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.2.1 $  $Date: 2003/11/30 23:09:18 $


% public properties

resp.address                = mm.address;
resp.bitsperstorageunit     = mm.bitsperstorageunit;
resp.numberofstorageunits   = mm.numberofstorageunits;
resp.link                   = mm.link;
resp.timeout                = mm.timeout;

% private properties

resp.maxaddress             = mm.maxaddress;
resp.procsubfamily          = mm.procsubfamily;

% [EOF] copy_memoryobj.m


