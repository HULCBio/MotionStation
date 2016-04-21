function cast_C28x(rr,datatype)
% Private. Casting for C28x register symbols.

% Copyright 2003 The MathWorks, Inc.

if (rr.bitsperstorageunit ~=16)
    error(generateccsmsgid('InvalidBitsPerStorageUnit'),'A register unit must contain 16 bits for C28x register objects');
end

% Initialize (pre/post)pad
rr.prepad   = 0;  % Modified later, if necessary
rr.postpad  = 0;
rr.binarypt = 0;

switch datatype
case 'double',
    % totalbits = 32;
    % rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.storageunitspervalue = 2;
    rr.represent = 'float';
case 'long double',
    error(generateccsmsgid('DataTypeNotSupported'),'Converting a register numeric object to a 64-bit data type is not allowed.');
    
case {'single','float'}
	% totalbits = 32;        
	% rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.storageunitspervalue = 2;
    rr.represent = 'float';
    
case {'long','signed long'}
    totalbits  = 32;        
    rr.postpad = 0;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'signed';
    
case {'int','signed int'}
    totalbits  = 16;        
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'signed';
    
case {'short','signed int'}
    totalbits  = 16;
    rr.postpad = 0;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'signed';

case {'char','signed char'}
    totalbits  = 16;        
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'signed';
    
case 'unsigned long',
    totalbits  = 32;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'unsigned';
    
case 'unsigned int'
    totalbits  = 16;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'unsigned';
    
case 'unsigned short'
    totalbits  = 16;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'unsigned';
    
case 'unsigned char'
    totalbits  = 16;        
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'unsigned';
    
case 'pointer_ml'
    rr.bitsperstorageunit = 22;
    rr.storageunitspervalue = 1;
    rr.numberofstorageunits = 1;
    rr.postpad = 0;
    rr.prepad  = 0;
    rr.wordsize = (rr.storageunitspervalue * rr.bitsperstorageunit) - rr.postpad - rr.prepad;
    rr.represent = 'unsigned';
    
case 'int64'
    error(generateccsmsgid('DataTypeNotSupported'),'INT64 type not supported');
    
case 'uint64'
    error(generateccsmsgid('DataTypeNotSupported'),'UINT64 type not supported');
    
case 'int32'
    rr.storageunitspervalue = round(32/rr.bitsperstorageunit);
    rr.represent = 'signed';
    
case 'uint32'
    rr.storageunitspervalue = round(32/rr.bitsperstorageunit);
    rr.represent = 'unsigned';
    
case 'int16'
    totalbits  = 16;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'signed';
    
case 'uint16'
    totalbits  = 16;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'unsigned';
    
case 'int8'
    totalbits  = 16;
    rr.postpad = 8;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'signed';
    
case 'uint8'
    totalbits  = 16;
    rr.postpad = 8;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'unsigned';

%==========================================================================
% Special TI types
case 'Q0.15',
    %rr.storageunitspervalue = round(16/rr.bitsperstorageunit);
    rr.storageunitspervalue = 1;
    rr.postpad = 0;
    rr.represent = 'fract';
    rr.binarypt = 15; % future expansion? 
    
case 'Q0.31',
    %rr.storageunitspervalue = round(32/rr.bitsperstorageunit);
    rr.storageunitspervalue = 2;
    rr.represent = 'fract';
    rr.binarypt  = 31; % future expansion?
    
otherwise,
    error(generateccsmsgid('DataTypeNotSupported'),['DATATYPE:' datatype ' is not recognized']);
end

% [EOF] cast_C28x.m