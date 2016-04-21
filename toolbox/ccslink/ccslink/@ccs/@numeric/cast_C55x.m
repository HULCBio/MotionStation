function cast_C55x(mm,datatype)
% Private. Casting for C55x memory symbols.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/11/30 23:09:38 $

if (mm.bitsperstorageunit ~=16)
    error('An addressable unit must contain 16 bits for C55x memory objects. ');
end

% Initialize (pre/post)pad, binarypt
mm.prepad   = 0;  % Modified later, if necessary
mm.postpad  = 0;
mm.binarypt = 0;

switch datatype
case {'float','double','long double','single'},
    totalbits = 32;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'float';
    
case 'unsigned long long',
    totalbits  = 64;
    mm.postpad = 24;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case {'long long','signed long long'},
    totalbits  = 64;
    mm.postpad = 24;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case {'long','signed long'}
    totalbits  = 32;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case 'unsigned long',
    totalbits  = 32;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case 'unsigned int'
    totalbits  = 16;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case {'int','signed int'}
    totalbits  = 16;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case 'unsigned short'
    totalbits  = 16;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case {'short','signed short'}
    totalbits  = 16;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case 'unsigned char'
    totalbits  = 16;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case {'char','signed char'}
    totalbits  = 16;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
%==========================================================================
% Special MATLAB types

case 'int64'
    mm.storageunitspervalue = round(64/mm.bitsperstorageunit);
    mm.represent = 'signed';
    
case 'uint64'
    mm.storageunitspervalue = round(64/mm.bitsperstorageunit);
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
    errid = ['MATLAB:NUMERIC:Int8NotSupported'];
    error(errid,'Data type ''int8'' is not supported on C5500 memory variables.');
    
case 'uint8'
    errid = ['MATLAB:NUMERIC:Uint8NotSupported'];
    error(errid,'Data type ''uint8'' is not supported on C5500 memory variables.');
    
%==========================================================================
% Special TI types

case 'Q0.15',
    mm.storageunitspervalue = round(16/mm.bitsperstorageunit);
    mm.represent = 'fract';
    mm.binarypt = 15;
    
case 'Q0.31',
    mm.storageunitspervalue = round(32/mm.bitsperstorageunit);
    mm.represent = 'fract';
    mm.binarypt = 31; 
    
otherwise,
    errid = ['MATLAB:NUMERIC:DataTypeNotRecognized'];
    error(errid,['DATATYPE: ' datatype ' is not recognized.']);
    
end

% [EOF] cast_C55x.m