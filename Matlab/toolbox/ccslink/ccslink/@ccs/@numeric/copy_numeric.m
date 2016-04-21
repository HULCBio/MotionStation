function dummy = copy_numeric(nn,resp)
%   Private. Copies over NN properties to RESP.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.2.1 $  $Date: 2003/11/30 23:09:50 $

% public properties

resp.name                   = nn.name;
resp.wordsize               = nn.wordsize;
resp.storageunitspervalue   = nn.storageunitspervalue;
resp.size                   = nn.size;
resp.endianness             = nn.endianness;
resp.arrayorder             = nn.arrayorder;
resp.prepad                 = nn.prepad;
resp.postpad                = nn.postpad;
resp.represent              = nn.represent;
resp.binarypt               = nn.binarypt;

% private properties

% [EOF] copy_numeric.m
