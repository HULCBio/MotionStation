function dummy = copy_registerobj(rr,resp)
%   Private. Copies over RR properties to RESP.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2003/11/30 23:10:36 $

% public properties

resp.regname                = rr.regname;
resp.bitsperstorageunit     = rr.bitsperstorageunit;
resp.numberofstorageunits   = rr.numberofstorageunits;
resp.link                   = rr.link;
resp.timeout                = rr.timeout;

% private properties

resp.regid                  = rr.regid;
resp.procsubfamily          = rr.procsubfamily;

% [EOF] copy_registerobj.m


