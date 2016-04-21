function dummy = copy_bitfield(bb,resp)
%   Private. Copies over BB properties to RESP.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.2.1 $  $Date: 2003/11/30 23:06:27 $

% public properties

resp.name                   = bb.name;
resp.wordsize               = bb.wordsize;
resp.storageunitspervalue   = bb.storageunitspervalue;
resp.size                   = bb.size;
resp.endianness             = bb.endianness;
resp.arrayorder             = bb.arrayorder;
resp.prepad                 = bb.prepad;
resp.postpad                = bb.postpad;
resp.represent              = bb.represent;
resp.binarypt               = bb.binarypt;
resp.offset                 = bb.offset;
resp.length                 = bb.length;

% private properties

% - none -

% [EOF] copy_bitfield.m


