function mempoke(obj, varargin)
%MEMPOKE Low-level memory write to VXI register.
%
%   MEMPOKE(OBJ, DATA, OFFSET) writes a uint8 value, DATA, to the 
%   mapped memory address specified by OFFSET for interface object, 
%   OBJ. OBJ must be a 1-by-1 VISA-VXI or VISA-GPIB-VXI instrument 
%   object.
%
%   The interface object must be connected to the instrument with the 
%   FOPEN function before any data can be written to the instrument 
%   otherwise an error is returned. A connected interface object 
%   has a Status property value of open.
%
%   Before using MEMPOKE, the memory space must be mapped with the 
%   MEMMAP function. OBJ's MappedMemorySize property returns the amount
%   of memory mapped. If this value is 0, then no memory has been mapped.
%
%   MEMPOKE(OBJ, DATA, OFFSET, 'PRECISION') writes DATA with precision,
%   PRECISION, to the mapped memory address specified by OFFSET. PRECISION
%   can be 'uint8', 'uint16', 'uint32' or 'single'.
%
%   OFFSET indicates the offset in the mapped memory space to which the
%   data will be written. For example, if the mapped memory space begins 
%   at 200H, the offset is 2 and the precision is uint8, the data will be
%   written to 202H. If the precision is uint16, the data will be written
%   to 202H and 203H. If the precision is uint32, the data will be written
%   to 202H, 203H, 204H and 205H.
%
%   To increase speed, MEMPOKE does not return error messages from
%   the instrument.
%
%   Example:
%       v = visa('agilent', 'VXI0::8::INSTR');
%       fopen(v)
%       memmap(v, 'A16', 0, 16);
%       mempoke(v, 45056, 6, 'uint16');
%       memunmap(v);
%       fclose(v);
%
%   See also ICINTERFACE/FOPEN, MEMPEEK, MEMMAP, INSTRUMENT/PROPINFO,
%   INSTRHELP.
%

%   MP 11-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.12.2.4 $  $Date: 2004/01/16 20:02:21 $

% Error checking.
if nargin > 4
    error('instrument:mempoke:invalidSyntax', 'Too many input arguments.');
end

if (length(obj) > 1)
    error('instrument:mempoke:invalidOBJ', 'OBJ must be a 1-by-1 VISA-VXI or VISA-GPIB-VXI object.');
end

if ~isa(obj, 'instrument')
   error('instrument:mempoke:invalidOBJ', 'OBJ must be an interface object.');
end	

if ~(strcmp(obj.type, 'vxi') || strcmp(obj.type, 'gpib-vxi'))
    error('instrument:mempoke:invalidOBJ', 'MEMPOKE is supported for VISA-VXI and VISA-GPIB-VXI objects.');
end

% Parse the input.
switch nargin
case 1
    error('instrument:mempoke:invalidSyntax', 'DATA and OFFSET must be specified.');
case 2
    error('instrument:mempoke:invalidSyntax', 'OFFSET must be specified.');
case 3
    [data, offset] = deal(varargin{:});
    precision = 'uint8';
case 4
    [data, offset, precision] = deal(varargin{:});
end

% Verify offset.
if ~isa(offset, 'double')
    error('instrument:mempoke:invalidOFFSET', 'OFFSET must be a double.');
elseif isnan(offset) || ~isreal(offset)
    error('instrument:mempoke:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be finite.');
elseif isinf(offset)
    error('instrument:mempoke:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be finite.');
elseif (offset < 0)
	error('instrument:mempoke:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be greater than or equal to 0.');
elseif (length(offset) > 1)
	error('instrument:mempoke:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be scalar.');
end

% Verify data.
if ~(isnumeric(data) || ischar(data))
	error('instrument:mempoke:invalidDATA', 'Invalid DATA specified. DATA must be numeric or a string.');
elseif length(data) > 1
    error('instrument:mempoke:invalidDATA', 'Invalid DATA specified. DATA must be scalar.');
elseif ~isfinite(data)
    error('instrument:mempoke:invalidDATA', 'Invalid DATA specified. DATA must be finite.')
elseif isempty(data)
    return;
end

% Verify precision.
if ~ischar(precision)
    error('instrument:mempoke:invalidPRECISION', 'Invalid PRECISION specified. PRECISION must be ''uint8'', ''uint16'', ''uint32'' or ''single''.');
end

switch lower(precision)
case 'uint8'
    precision = 0;
    data = uint8(data);
case 'uint16'
    precision = 1;
    data = uint16(data);
case 'uint32'
    precision = 2;
    data = uint32(data);
case 'single'
    precision = 3;
    data = single(data);    
otherwise
    error('instrument:mempoke:invalidPRECISION', 'Invalid PRECISION specified. PRECISION must be ''uint8'', ''uint16'', ''uint32'' or ''single''.');
end

% Call the java mempoke method.
try
    mempoke(obj.jobject, data, precision, offset);
catch
    error('instrument:mempoke:opfailed', lasterr);
end