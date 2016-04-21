function cast_C6xx(mm,datatype)
% Private. Casting for C6xx memory symbols.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2003/11/30 23:09:39 $

if (mm.bitsperstorageunit ~=8)
    error('An addressable unit must contain 8 bits for C6xx memory objects. ');
end

% Initialize (pre/post)pad, binarypt
mm.prepad   = 0;  % Modified later, if necessary
mm.postpad  = 0;
mm.binarypt = 0;

switch datatype
case {'double','long double'},
    totalbits = 64;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'float';
    
case {'single','float'}
    totalbits = 32;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'float';
    
case {'long','signed long'}
    totalbits  = 64;
    mm.postpad = 24;  % c6000 specific!
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case {'int','signed int'}
    totalbits  = 32;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case {'short','signed short'}
    totalbits  = 16;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case {'char','signed char'}
    totalbits  = 8;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case 'unsigned long',
    totalbits  = 64;
    mm.postpad = 24;  % c6000 specific!
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case 'unsigned short'
    totalbits  = 16;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case 'unsigned int'
    totalbits  = 32;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case 'unsigned char'
    totalbits  = 8;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case 'int64'
    totalbits = 64;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case 'uint64'
    totalbits = 64;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case 'int32'
    mm.storageunitspervalue = round(32/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case 'uint32'
    mm.storageunitspervalue = round(32/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case 'int16'
    mm.storageunitspervalue = round(16/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case 'uint16'
    mm.storageunitspervalue = round(16/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case 'int8'
    mm.storageunitspervalue = round(8/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case 'uint8'
    mm.storageunitspervalue = round(8/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
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

% [EOF] cast_C6xx.m