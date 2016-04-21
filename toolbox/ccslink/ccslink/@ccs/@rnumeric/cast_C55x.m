function cast_C55x(mm,datatype,bypassFlag)
% Private. Casting for C55x register symbols.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2003/11/30 23:11:15 $

error(nargchk(2,3,nargin));
if nargin==2,
    bypassFlag = 0;
end
    
if mm.bitsperstorageunit~=16 && mm.bitsperstorageunit~=23 && mm.bitsperstorageunit~=32,
    error('An register unit must contain 16, 23, or 32 bits for C55x register objects. ');
end

if bypassFlag==0,
    % Data types with wordsize > 16 bits
    if any(strcmp(datatype,{'float','double','long double','single','unsigned long long',...
                'long long','long','signed long','unsigned long','int32','uint32','Q0.31'})) ...
       && mm.wordsize<=16,
            error('Object cannot be casted or converted to a data type having size >16 bits.');
    % Data types with wordsize <= 16 bits
    elseif any(strcmp(datatype,{'unsigned int','int','signed int','unsigned short','short',...
                'signed short','char','usigned char','signed char','int16','uint16','Q0.15'})) ...
       && mm.wordsize>16,
            error('Object cannot be casted or converted to a data type having size 16 bits.');
    end
end

% Initialize (pre/post)pad, binarypt
mm.prepad   = 0;  % Modified later, if necessary
mm.postpad  = 0;
mm.binarypt = 0;
mm.storageunitspervalue = 1;

switch datatype
case {'float','double','long double','single'},
    totalbits = 32;
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'float';
    
case 'unsigned long long',
    warnid = ['MATLAB:RNUMERIC:RegULongLongAsRegULong'];
    warning(warnid,'Register objects with data type ''unsigned long long'' is treated as ''unsigned long'' in C5500.');
    totalbits  = 32; % 40 bits in memory
    mm.storageunitspervalue = round(totalbits/mm.bitsperstorageunit);
    mm.represent = 'unsigned';
    
case {'long long','signed long long'}
    warnid = ['MATLAB:RNUMERIC:RegLongLongAsRegLong'];
    warning(warnid,'Register objects with data type ''long long'' is treated as ''long'' in C5500.');
    totalbits  = 32; % 40 bits in memory
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
    
case 'pointer_ml'
    mm.bitsperstorageunit = 23;
    mm.storageunitspervalue = 1;
    mm.numberofstorageunits = 1;
    mm.postpad = 0;
    mm.prepad  = 0;
    mm.wordsize = (mm.storageunitspervalue * mm.bitsperstorageunit) - mm.postpad - mm.prepad;
    mm.represent = 'unsigned';
    
%==========================================================================
% Special MATLAB types

case 'int64'
    errid = ['MATLAB:RNUMERIC:Int64NotSupported'];
    error(errid,'Data type ''int64'' is not supported on C5500 register variables.');
    
case 'uint64'
    errid = ['MATLAB:RNUMERIC:Uint64NotSupported'];
    error(errid,'Data type ''uint64'' is not supported on C5500 register variables.');
    
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
    errid = ['MATLAB:RNUMERIC:Int8NotSupported'];
    error(errid,'Data type ''int8'' is not supported on C5500 register variables.');
    
case 'uint8'
    errid = ['MATLAB:RNUMERIC:Uint8NotSupported'];
    error(errid,'Data type ''uint8'' is not supported on C5500 register variables.');
    
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
    errid = ['MATLAB:RNUMERIC:DataTypeNotRcognized'];
    error(errid,['DATATYPE: ' datatype ' is not recognized.']);
    
end

% [EOF] cast_C6xx.m