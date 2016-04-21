function resp = copy_renum(re,resp)
%   Private. Copies over RE properties to RESP.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2003/11/30 23:10:57 $

% public properties

resp.label      = re.label;
resp.value      = re.value;
resp.wordsize   = re.wordsize;
resp.size       = re.size;
resp.endianness = re.endianness;
resp.arrayorder = re.arrayorder;
resp.prepad     = re.prepad;
resp.postpad    = re.postpad;
resp.represent  = re.represent;
resp.binarypt   = re.binarypt;
resp.storageunitspervalue = re.storageunitspervalue;

% private properties
% - none - 

% [EOF] copy_renum.m


