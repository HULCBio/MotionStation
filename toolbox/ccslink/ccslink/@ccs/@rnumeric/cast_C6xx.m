function cast_C6xx(rr,datatype)
% Private. Casting for C6xx register symbols.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/11/30 23:11:16 $

if (rr.bitsperstorageunit ~=32)
    error('A register unit must contain 32 bits for C6xx register objects');
end

% Initialize (pre/post)pad, binarypt
rr.prepad   = 0;  % Modified later, if necessary
rr.postpad  = 0;
rr.binarypt = 0;

switch datatype
case {'double','long double'},
    totalbits = 64;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'float';
    
case {'single','float'}
    totalbits = 32;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'float';
    
case {'long','signed long'}
    totalbits  = 64;
    rr.postpad = 24;  % c6000 specific!
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'signed';
    
case {'int','signed int'}
    totalbits  = 32;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'signed';
    
case {'short','signed short'}
    totalbits  = 32;
    rr.postpad = 16;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'signed';

case {'char','signed char'}
    totalbits  = 32;
    rr.postpad = 24;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'signed';
    
case 'unsigned long',
    totalbits  = 64;
    rr.postpad = 24;  
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'unsigned';
    
case 'unsigned int'
    totalbits  = 32;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'unsigned';
    
case 'unsigned short'
    totalbits  = 32;
    rr.postpad = 16;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'unsigned';
    
case 'unsigned char'
	totalbits  = 32;
	rr.postpad = 24;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'unsigned';
    
case 'int64'
    rr.storageunitspervalue = round(64/rr.bitsperstorageunit);
    rr.represent = 'signed';
    
case 'uint64'
    rr.storageunitspervalue = round(64/rr.bitsperstorageunit);
    rr.represent = 'unsigned';
    
case 'int32'
    rr.storageunitspervalue = round(32/rr.bitsperstorageunit);
    rr.represent = 'signed';
    
case 'uint32'
    rr.storageunitspervalue = round(32/rr.bitsperstorageunit);
    rr.represent = 'unsigned';
    
case 'int16'
    totalbits  = 32;
    rr.postpad = 16;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'signed';
    
case 'uint16'
    totalbits  = 32;
    rr.postpad = 16;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'unsigned';
    
case 'int8'
    totalbits  = 32;
    rr.postpad = 24;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'signed';
    
case 'uint8'
    totalbits  = 32;
    rr.postpad = 24;
    rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.represent = 'unsigned';

%==========================================================================
% Special TI types
case 'Q0.15',
    %rr.storageunitspervalue = round(16/rr.bitsperstorageunit);
    rr.storageunitspervalue = 1;
    rr.postpad = 16;
    rr.represent = 'fract';
    rr.binarypt = 15; % future expansion? 
    
case 'Q0.31',
    %rr.storageunitspervalue = round(32/rr.bitsperstorageunit);
    rr.storageunitspervalue = 1;
    rr.represent = 'fract';
    rr.binarypt  = 31; % future expansion?
    
otherwise,
    error(['DATATYPE:' datatype ' is not recognized']);
end

% [EOF] cast_C6xx.m