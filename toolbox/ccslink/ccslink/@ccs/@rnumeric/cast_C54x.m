function cast_C54x(rr,datatype)
% Private. Casting for C54x register symbols.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2003/11/30 23:11:14 $

if (rr.bitsperstorageunit ~=16)
    error('A register unit must contain 16 bits for C54x register objects');
end

% Initialize (pre/post)pad
rr.prepad   = 0;  % Modified later, if necessary
rr.postpad  = 0;
rr.binarypt = 0;

switch datatype
case {'double','long double'},
    % totalbits = 32;
    % rr.storageunitspervalue = round(totalbits/rr.bitsperstorageunit);
    rr.storageunitspervalue = 2;
    rr.represent = 'float';
    
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
    
case 'int64'
    error('INT64 type not supported');
    
case 'uint64'
    error('UINT64 type not supported');
    
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
    error(['DATATYPE:' datatype ' is not recognized']);
end

% [EOF] cast_C54x.m