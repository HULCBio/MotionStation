function fwrite(obj, varargin)
%FWRITE Write binary data to instrument.
%
%   FWRITE(OBJ, A) writes the data, A, to the instrument connected to
%   interface object, OBJ.
%
%   The interface object must be connected to the instrument with the 
%   FOPEN function before any data can be written to the instrument
%   otherwise an error will be returned. A connected interface object 
%   has a Status property value of open.
%
%   FWRITE(OBJ,A,'PRECISION') writes binary data translating MATLAB
%   values to the specified precision, PRECISION. The supported
%   PRECISION strings are defined below. By default the 'uchar' 
%   PRECISION is used. 
%   
%      MATLAB           Description
%      'uchar'          unsigned character,  8 bits.
%      'schar'          signed character,    8 bits.
%      'int8'           integer,             8 bits.
%      'int16'          integer,             16 bits.
%      'int32'          integer,             32 bits.
%      'uint8'          unsigned integer,    8 bits.
%      'uint16'         unsigned integer,    16 bits.
%      'uint32'         unsigned integer,    32 bits.
%      'single'         floating point,      32 bits.
%      'float32'        floating point,      32 bits.
%      'double'         floating point,      64 bits.
%      'float64'        floating point,      64 bits.
%      'char'           character,           8 bits (signed or unsigned).
%      'short'          integer,             16 bits.
%      'int'            integer,             32 bits.
%      'long'           integer,             32 or 64 bits.
%      'ushort'         unsigned integer,    16 bits.
%      'uint'           unsigned integer,    32 bits.
%      'ulong'          unsigned integer,    32 bits or 64 bits.
%      'float'          floating point,      32 bits.
%
%   FWRITE(OBJ, A, 'MODE')
%   FWRITE(OBJ, A, 'PRECISION', 'MODE') writes data asynchronously
%   to the instrument when MODE is 'async' and writes data synchronously
%   to the instrument when MODE is 'sync'. By default, the data is 
%   written with the 'sync' MODE, meaning control is returned to  
%   the MATLAB command line after the specified data has been written  
%   to the instrument or a timeout occurs. When the 'async' MODE is 
%   used, control is returned to the MATLAB command line immediately 
%   after executing the FWRITE function. 
%
%   The byte order of the instrument can be specified with OBJ's 
%   ByteOrder property. 
%
%   OBJ's ValuesSent property will be updated by the number of values
%   written to the instrument.
%
%   If OBJ's RecordStatus property is configured to on with the RECORD
%   function, the data written to the instrument will be recorded in
%   the file specified by OBJ's RecordName property value.
%
%   Example:
%       s = visa('ni', 'ASRL2::INSTR');
%       fopen(s);
%       fwrite(s, [0 5 5 0 5 5 0]);
%       fclose(s);
%
%   See also ICINTERFACE/FOPEN, ICINTERFACE/FPRINTF, ICINTERFACE/RECORD,
%   ICINTERFACE/PROPINFO, INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/01/16 20:00:36 $

% Error checking.
if ~isa(obj, 'icinterface')
    error('instrument:fwrite:invalidOBJ', 'OBJ must be an interface object.');
end

if length(obj)>1
    error('instrument:fwrite:invalidOBJ', 'OBJ must be a 1-by-1 interface object.');
end

% Parse the input.
switch nargin
case 1
   error('instrument:fwrite:invalidSyntax', 'The input argument A must be specified.');
case 2
   cmd = varargin{1};
   precision = 'uchar';
   mode = 0;	
case 3
   % Original assumption: fwrite(obj, cmd, precision); 
   [cmd, precision] = deal(varargin{1:2});
   mode = 0;

   if ~(isa(precision, 'char') || isa(precision, 'double'))
	   error('instrument:fwrite:invalidArg','The third input argument must be a string.');
   end
   
   if strcmpi(precision, 'sync') 
       % Actual: fwrite(obj, cmd, mode);
       mode = 0;
       precision = 'uchar';
   elseif strcmpi(precision, 'async') 
       % Actual: fwrite(obj, cmd, mode);
       mode = 1;
       precision = 'uchar';
   end
case 4
   % Ex. fprintf(obj, format, cmd, mode); 
   [cmd, precision, mode] = deal(varargin{1:3}); 
   
   if ~ischar(mode)
	   error('instrument:fwrite:invalidMODE','MODE must be either ''sync'' or ''async''.');
   end
   
   if strcmpi(mode, 'sync')
       mode = 0;
   elseif strcmpi(mode, 'async')
       mode = 1;
   else
       error('instrument:fwrite:invalidMODE','MODE must be either ''sync'' or ''async''.');
   end
otherwise
   error('instrument:fwrite:invalidSyntax','Too many input arguments.');
end   

% Error checking.
if ~isa(precision, 'char')
	error('instrument:fwrite:invalidPRECISION','PRECISION must be a string.');
end
if ~(isnumeric(cmd) || ischar(cmd))
	error('instrument:fwrite:invalidA','The input argument A must be numeric or a string.');
end

% Convert the data to the requested precision.
switch (precision)
case {'uchar', 'char'}
    cmd = uint8(cmd);
    type = 5;
    signed = 0;
case {'schar'}
    cmd = int8(cmd);
    type = 5;
    signed = 1;
case {'int8'}
    cmd = int8(cmd);
    type = 0;
    signed = 1;
case {'int16', 'short'}
    cmd = int16(cmd);
    type = 1;
    signed = 1;
case {'int32', 'int', 'long'}
    cmd = int32(cmd);
    type = 2;
    signed = 1;
case {'uint8'}
    cmd = uint8(cmd);
    type = 0;
    signed = 0;
case {'uint16', 'ushort'}
    cmd = uint16(cmd);
    type = 1;
    signed = 0;
case {'uint32', 'uint', 'ulong'}
    cmd = uint32(cmd);
    type = 2;
    signed = 0;
case {'single', 'float32', 'float'}
    cmd = single(cmd);
    type = 3;
    signed = 1;
case {'double' ,'float64'}
    cmd = double(cmd);
    type = 4;
    signed = 1;
otherwise
    error('instrument:fwrite:invalidPRECISION','Invalid PRECISION specified. Type ''instrhelp fwrite'' for more information.');
end

% Call the write java method.
try
   fwrite(igetfield(obj, 'jobject'), cmd, length(cmd), type, mode, signed);
catch
   error('instrument:fwrite:opfailed', lasterr);
end   
