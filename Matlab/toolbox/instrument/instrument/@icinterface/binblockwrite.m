function binblockwrite(obj, varargin)
%BINBLOCKWRITE Write binblock to instrument.
%
%   BINBLOCKWRITE(OBJ, A) writes a binblock using the data, A, to the 
%   instrument connected to interface object, OBJ.
%
%   The binblock is constructed using the formula:
%   #<Non_Zero_Digit><Digit><A>
%
%   where:
%     Non_Zero_Digit represents the number of <Digit> elements that follow.
%     Digit represents the number of bytes <A> that follow.
%
%   For example, if A was defined as [0 5 5 0 5 5 0], the binblock would
%   be defined as [double('#') 1 7 0 5 5 0 5 5 0].
%
%   The interface object must be connected to the instrument with the 
%   FOPEN function before any data can be written to the instrument
%   otherwise an error will be returned. A connected interface object 
%   has a Status property value of open.
%
%   BINBLOCKWRITE(OBJ,A,'PRECISION') writes binary data translating MATLAB
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
%   BINBLOCKWRITE(OBJ,A,'HEADER') writes a binblock using the data, A, and
%   the ASCII header, HEADER, to the instrument connected to interface 
%   object, OBJ. The data written is constructed using the formula:
%
%   <HEADER>#<Non_Zero_Digit><Digit><A>
%
%   BINBLOCKWRITE(OBJ,A,'PRECISION','HEADER') writes binary data, A, 
%   translating MATLAB values to the specified precision, PRECISION. The 
%   ASCII header, HEADER, is inserted before the binblock.
%
%   BINBLOCKWRITE(OBJ,A,'PRECISION','HEADER','HEADERFORMAT') writes binary
%   data, A, translating MATLAB values to the specified precision, PRECISION.
%   The ASCII header, HEADER, is appended to the binblock using the format
%   specified by HEADERFORMAT. By default, HEADERFORMAT is %s. 
%
%   HEADERFORMAT is a string containing C language conversion specifications. 
%   Conversion specifications involve the character % and the conversion 
%   characters d, i, o, u, x, X, f, e, E, g, G, c, and s. Type 
%   'instrhelp fprintf' for more information on valid values for HEADERFORMAT.
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
%
%       % Write the command: [double('#14') 0 5 0 5] to the instrument.
%       binblockwrite(s, [0 5 0 5]);
%
%       % Write the command: [double('Curve #14') 0 5 0 5] to the instrument.
%       binblockwrite(s, [0 5 0 5], 'Curve ')  
%       fclose(s);
%
%   See also ICINTERFACE/FOPEN, ICINTERFACE/FCLOSE, ICINTERFACE/BINBLOCKREAD, 
%   ICINTERFACE/FWRITE, ICINTERFACE/RECORD, INSTRUMENT/PROPINFO, INSTRHELP.
%

%   MP 11-02-00
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2004/03/05 18:10:15 $

% Error checking.
if ~isa(obj, 'icinterface')
    error('instrument:binblockwrite:invalidOBJ', 'OBJ must be an interface object.');
end

if length(obj)>1
    error('instrument:binblockwrite:invalidOBJ', 'OBJ must be a 1-by-1 interface object.');
end

% Parse the input.
switch nargin
case 1
   error('instrument:binblockwrite:invalidSyntax', 'The input argument A must be specified.');
case 2
   cmd          = varargin{1};
   precision    = 'uchar';
   header       = '';
   headerformat = '%s';
case 3
   [cmd, precision] = deal(varargin{1:2}); 
   if (localIsSupportedPrecision(precision) == false)
       header       = precision;
       precision    = 'uchar';
       headerformat = '%s';
   else
       header       = '';
       headerformat = '%s';
   end
case 4
   [cmd, precision,header] = deal(varargin{1:3});
   headerformat     = '%s';
case 5
   [cmd, precision,header,headerformat] = deal(varargin{1:4});
otherwise
   error('instrument:binblockwrite:invalidSyntax', 'Too many input arguments.');
end   

% Error checking.
if ~isa(precision, 'char')
	error('instrument:binblockwrite:invalidPRECISION', 'PRECISION must be a string.');
end
if ~isa(headerformat, 'char')
	error('instrument:binblockwrite:invalidPRECISION', 'HEADERFORMAT must be a string.');
end

if ~(isnumeric(cmd) || ischar(cmd))
	error('instrument:binblockwrite:invalidA', 'The input argument A must be numeric or a string.');
end
if ~ischar(header)
	error('instrument:binblockwrite:invalidHEADER', 'The input argument HEADER must be a string.');
end

% Convert the data to the requested precision.
[cmd, type, signed, errflag] = localGetDataAndInfo(precision, cmd);
if (errflag == true)
    error('instrument:binblockwrite:invalidPRECISION', 'Invalid PRECISION specified. Type ''instrhelp binblockwrite'' for more information.');
end

% Conver the header to the requested precision.
[headerout, errflag] = localParseString(headerformat, header);
if (errflag == true)
    error('instrument:binblockwrite:invalidPRECISION', 'Invalid HEADERFORMAT specified. Type ''instrhelp binblockwrite'' for more information.');
end

% Call the binblockwrite java method.
try
   binblockwrite(igetfield(obj, 'jobject'), cmd, length(cmd), type, signed, headerout);
catch
   error('instrument:binblockwrite:opfailed', lasterr);
end   

% ------------------------------------------------------------------------
function [cmd, type, signed, errflag] = localGetDataAndInfo(precision, cmd)

% Initialize output.
type    = 0;
signed  = 0;
errflag = false;

switch (precision)
case {'uchar', 'char'}
    cmd    = uint8(cmd);
    type   = 5;
    signed = 0;
case {'schar'}
    cmd    = int8(cmd);
    type   = 5;
    signed = 1;
case {'int8'}
    cmd    = int8(cmd);
    type   = 0;
    signed = 1;
case {'int16', 'short'}
    cmd    = int16(cmd);
    type   = 1;
    signed = 1;
case {'int32', 'int', 'long'}
    cmd    = int32(cmd);
    type   = 2;
    signed = 1;
case {'uint8'}
    cmd    = uint8(cmd);
    type   = 0;
    signed = 0;
case {'uint16', 'ushort'}
    cmd    = uint16(cmd);
    type   = 1;
    signed = 0;
case {'uint32', 'uint', 'ulong'}
    cmd    = uint32(cmd);
    type   = 2;
    signed = 0;
case {'single', 'float32', 'float'}
    cmd    = single(cmd);
    type   = 3;
    signed = 1;
case {'double' ,'float64'}
    cmd    = double(cmd);
    type   = 4;
    signed = 1;
otherwise
    errflag = true;
end

% ------------------------------------------------------------------------
function out = localIsSupportedPrecision(p)

if strcmp(p, 'uchar')
    out = true;
elseif strcmp(p, 'char')
    out = true;
elseif strcmp(p, 'schar')
    out = true;
elseif strcmp(p, 'int8')
    out = true;
elseif strcmp(p, 'int16')
    out = true;
elseif strcmp(p, 'short')
    out = true;
elseif strcmp(p, 'int32')
    out = true;
elseif strcmp(p, 'int')
    out = true;
elseif strcmp(p, 'long')
    out = true;
elseif strcmp(p, 'uint8')
    out = true;
elseif strcmp(p, 'uint16')
    out = true;
elseif strcmp(p, 'ushort')
    out = true;
elseif strcmp(p, 'uint32')
    out = true;
elseif strcmp(p, 'uint')
    out = true;
elseif strcmp(p, 'ulong')
    out = true;
elseif strcmp(p, 'single')
    out = true;
elseif strcmp(p, 'float32')
    out = true;
elseif strcmp(p, 'float')
    out = true;
elseif strcmp(p, 'double')
    out = true;
elseif strcmp(p, 'float64')
    out = true;
else
    out = false;
end

% ------------------------------------------------------------------------
% Determine when the terminator is to be sent.
function [out, errflag] = localParseString(format, cmd)

% Initialize variables.
out       = {};
lastIndex = 1;
count     = 1;
errflag   = false;

% The output will be a cell array.  Each element of the cell array is 
% a string to be written to the device.  The cells that contain a
% -1 will output the Terminating character as defined by the object.

% Format the string.
[h, errmsg] = sprintf(format, cmd);
if ~isempty(errmsg)
    errflag = true;
    lasterr(errmsg, 'instrument:fprintf:invalidFormat');
    return;
end

h1 = real(h);

% Loop through the real formatted command and separate the carriage
% returns into their own cell as -1.
carriageReturn = real(sprintf('\n'));
slash          = real('\');
letterN        = real('n');

for i = 1:length(h1)
	switch (h1(i))
    case carriageReturn
        % A carriage return in the formatted string was found.
        if lastIndex == i
            % No data that hasn't been assigned into a cell exists
            % before the carriage return.
            out{count} = -1;
            count = count+1;
            lastIndex = i+1;
        else
            % Data exists that hasn't been put into a cell before
            % the carriage return.
        	out{count} = h(lastIndex:i-1);
        	out{count+1} = -1;
   			count = count+2;
        	lastIndex = i+1;
        end
	case slash
        if h1(i+1) == letterN
            % A \n was found (this occurs if the \n was placed in 
            % the command rather than the format.)
            if lastIndex == i
                % No data that hasn't been assigned into a cell exists
                % before the \n.
                out{count} = -1;
                count = count+1;
                lastIndex = i+2;
            else
                % Data exists that hasn't been put into a cell before
                % the \n.
		   		out{count} = h(lastIndex:i-1);
           		out{count+1} = -1;
           		count = count+2;
           		lastIndex = i+2;
            end
        end
    end
end

% If any data remains place into into a cell.
if lastIndex <= i
    out{count} = h(lastIndex:i);
end
