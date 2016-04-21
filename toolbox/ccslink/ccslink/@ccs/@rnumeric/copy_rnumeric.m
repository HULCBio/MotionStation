function dummy = copy_rnumeric(rn,resp)
%   Private. Copies over RN properties to RESP.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2003/11/30 23:11:28 $

% public properties

resp.name                       = rn.name;
resp.wordsize                   = rn.wordsize;
resp.storageunitspervalue       = rn.storageunitspervalue;
resp.size                       = rn.size;
resp.endianness                 = rn.endianness;
resp.arrayorder                 = rn.arrayorder;
resp.prepad                     = rn.prepad;
resp.postpad                    = rn.postpad;
resp.represent                  = rn.represent;
resp.binarypt                   = rn.binarypt;

% private properties
% -none-

% [EOF] copy_rnumeric.m
