function resp = copy_enum(en,resp)
%   Private. Copies over EN properties to RESP.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2003/11/30 23:07:57 $


% public properties

resp.label      = en.label;
resp.value      = en.value;
resp.wordsize   = en.wordsize;
resp.size       = en.size;
resp.endianness = en.endianness;
resp.arrayorder = en.arrayorder;
resp.prepad     = en.prepad;
resp.postpad    = en.postpad;
resp.represent  = en.represent;
resp.binarypt   = en.binarypt;
resp.storageunitspervalue = en.storageunitspervalue;

% private properties

% - none - 

% [EOF] copy_enum.m
