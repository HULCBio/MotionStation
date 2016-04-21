function resp = typeinfo_c24x(td,datatype)
% Private. returns a struct info for a given datatype.

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/07/07 17:30:26 $


% Initialize (pre/post)pad, binarypt
resp.prepad   = 0;  % Modified later, if necessary
resp.postpad  = 0;
resp.binarypt = 0;
resp.bitsize = 0;
resp.storageunitspervalue = 0;
resp.represent = '';

% C24xx
bitsperstorageunit = 16;

switch datatype
case {'double','long double'},
    resp.bitsize = 32;        
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'float';
    
case {'single','float'}
    resp.bitsize = 32;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'float';
    
case {'long','signed long'}
    resp.bitsize  = 32;        
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'signed';
    
case {'int','signed int'}
    resp.bitsize  = 16;        
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'signed';
    
case {'short','signed short'}
    resp.bitsize  = 16;        
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'signed';
    
case {'char','signed char'}
    resp.bitsize  = 16;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'signed';
    
case 'unsigned long',
    resp.bitsize  = 32;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'unsigned';
    
case 'unsigned short'
    resp.bitsize  = 16;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'unsigned';
    
case 'unsigned int'
    resp.bitsize  = 16;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'unsigned';
    
case 'unsigned char'
    resp.bitsize  = 16;
    resp.storageunitspervalue = round(resp.bitsize/bitsperstorageunit);
    resp.represent = 'unsigned';
    
case 'int64'
    error('INT64 type not supported');
    
case 'uint64'
    error('UINT64 type not supported');
    
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
    resp.storageunitspervalue = 1;
    resp.represent = 'signed';
    
case 'uint16'
    resp.bitsize = 16;
    resp.storageunitspervalue = 1;
    resp.represent = 'unsigned';
    
case 'int8'
    error('INT8 type not supported');    
    
case 'uint8'
    error('UINT8 type not supported');
    
case 'void'
    resp.storageunitspervalue = 0;
    resp.represent = 'unsigned';

%==========================================================================
% Special TI types

case 'Q0.15',
    resp.bitsize = 16;
    resp.storageunitspervalue = round(16/bitsperstorageunit);
    resp.represent = 'fract';
    resp.binarypt = 15; % future expansion?    
    
case 'Q0.31',
    resp.bitsize = 32;
    resp.storageunitspervalue = round(32/bitsperstorageunit);
    resp.represent = 'fract';
    resp.binarypt = 31; % future expansion?
    
otherwise,
    error(['DATATYPE:' datatype ' is not recognized']);
    
end

% [EOF] typeinfo_c24x.m