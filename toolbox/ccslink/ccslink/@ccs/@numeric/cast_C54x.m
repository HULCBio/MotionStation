function cast_C54x(mm,datatype)
% Private. Casting for C54x memory symbols.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2003/11/30 23:09:37 $

if (mm.bitsperstorageunit ~=16)
    error('An addressable unit must contain 16 bits for C54x memory objects');
end

% Initialize (pre/post)pad, binarypt
mm.prepad   = 0;  % Modified later, if necessary
mm.postpad  = 0;
mm.binarypt = 0;

switch datatype
case {'double','long double'},
    totalbits = 32;        
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'float';
    
case {'single','float'}
    totalbits = 32;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'float';
    
case {'long','signed long'}
    totalbits  = 32;        
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case {'int','signed int'}
    totalbits  = 16;        
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case {'short','signed short'}
    totalbits  = 16;        
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case {'char','signed char'}
    totalbits  = 16;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case 'unsigned long',
    totalbits  = 32;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case 'unsigned short'
    totalbits  = 16;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case 'unsigned int'
    totalbits  = 16;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case 'unsigned char'
    totalbits  = 16;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case 'int64'
    error('INT64 type not supported');
    
case 'uint64'
    error('UINT64 type not supported');
    
case 'int32'
    mm.storageunitspervalue = round(32/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case 'uint32'
    mm.storageunitspervalue = round(32/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case 'int16'
    mm.storageunitspervalue = 1;
    mm.represent = 'signed';
    
case 'uint16'
    mm.storageunitspervalue = 1;
    mm.represent = 'unsigned';
    
case 'int8'
    error('INT8 type not supported');    
    
case 'uint8'
    error('UINT8 type not supported');


%==========================================================================
% Special TI types

case 'Q0.15',
    mm.storageunitspervalue = round(16/mm.bitsperstorageunit);
    mm.represent = 'fract';
    mm.binarypt = 15; % future expansion?    
    
case 'Q0.31',
    mm.storageunitspervalue = round(32/mm.bitsperstorageunit);
    mm.represent = 'fract';
    mm.binarypt = 31; % future expansion?
    
otherwise,
    error(['DATATYPE:' datatype ' is not recognized']);
    
end

% [EOF] cast_C54x.m