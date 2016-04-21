function resp = typeinfo_c55x(td,datatype)
% Private. returns a struct info for a given datatype.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:47:13 $

% Initialize (pre/post)pad, binarypt
resp.prepad   = 0;  % Modified later, if necessary
resp.postpad  = 0;
resp.binarypt = 0;
resp.bitsize = 0;
resp.storageunitspervalue = 0;
resp.represent = '';

% C55xx
bitsperstorageunit = 16;

switch datatype
case {'float','double','long double','single'},
    resp.bitsize = 32;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'float';
    
case 'unsigned long long',
    resp.bitsize  = 64;
    resp.postpad = 24;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'unsigned';
    
case {'long long','signed long long'}
    resp.bitsize  = 64;
    resp.postpad = 24;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'signed';
    
case {'long','signed long'}
    resp.bitsize  = 32;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'signed';
    
case 'unsigned long',
    resp.bitsize  = 32;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'unsigned';
    
case 'unsigned int'
    resp.bitsize  = 16;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'unsigned';
    
case {'int','signed int'}
    resp.bitsize  = 16;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'signed';
    
case 'unsigned short'
    resp.bitsize  = 16;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'unsigned';
    
case {'short','signed short'}
    resp.bitsize  = 16;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'signed';
    
case 'unsigned char'
    resp.bitsize  = 16;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'unsigned';
    
case {'char','signed char'}
    resp.bitsize  = 16;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'signed';
    
case 'void'
    resp.storageunitspervalue = 0;
    resp.represent = 'unsigned';    
%==========================================================================
% Special MATLAB types

case 'int64'
    resp.bitsize = 64;
    resp.storageunitspervalue = round(64/bitsperstorageunit);
    resp.represent = 'signed';
    
case 'uint64'
    resp.bitsize = 64;
    resp.storageunitspervalue = round(64/bitsperstorageunit);
    resp.represent = 'unsigned';
    
case 'int32'
    resp.bitsize = 32;
    resp.storageunitspervalue = round(32/bitsperstorageunit);
    resp.represent = 'signed';
    
case 'uint32'
    resp.bitsize = 32;
    resp.storageunitspervalue = round(32/bitsperstorageunit);
    resp.represent = 'unsigned';
    
case 'int16'
    resp.bitsize = 16;
    resp.storageunitspervalue = round(16/bitsperstorageunit);
    resp.represent = 'signed';
    
case 'uint16'
    resp.bitsize = 16;
    resp.storageunitspervalue = round(16/bitsperstorageunit);
    resp.represent = 'unsigned';
    
case 'int8'
    errid = ['MATLAB:NUMERIC:' mfilename '_m:Int8NotSupported'];
    error(errid,'Data type ''int8'' is not supported on C5500 memory variables.');
    
case 'uint8'
    errid = ['MATLAB:NUMERIC:' mfilename '_m:Uint8NotSupported'];
    error(errid,'Data type ''uint8'' is not supported on C5500 memory variables.');
    
%==========================================================================
% Special TI types

case 'Q0.15',
    resp.bitsize = 16;
    resp.storageunitspervalue = round(16/bitsperstorageunit);
    resp.represent = 'fract';
    resp.binarypt = 15;
    
case 'Q0.31',
    resp.bitsize = 32;
    resp.storageunitspervalue = round(32/bitsperstorageunit);
    resp.represent = 'fract';
    resp.binarypt = 31; 
    
otherwise,
    errid = ['MATLAB:NUMERIC:' mfilename '_m:DataTypeNotRecognized'];
    error(errid,['DATATYPE: ' datatype ' is not recognized.']);
    
end

% [EOF] typeinfo_c55x.m
