function data = memread(obj, varargin)
%MEMREAD High-level memory read from VXI register.
%
%   OUT = MEMREAD(OBJ) reads a uint8 value from the A16 address space
%   with an offset of 0 from interface object, OBJ. OBJ must be a 
%   1-by-1 VISA-VXI or VISA-GPIB-VXI interface object.
%
%   The interface object must be connected to the instrument with the 
%   FOPEN function before any data can be read from the instrument
%   otherwise an error is returned. A connected interface object
%   has a Status property value of open.
%
%   OUT = MEMREAD(OBJ, OFFSET) reads a uint8 value from the A16 address
%   space with an offset, OFFSET. OFFSET is a decimal value.
% 
%   OUT = MEMREAD(OBJ, OFFSET, 'PRECISION') reads the number of bits
%   specified by PRECISION from the A16 address space with an offset, 
%   OFFSET. The precision can be 'uint8', 'uint16', 'uint32', or 'single'.
%
%   OUT = MEMREAD(OBJ, OFFSET, 'PRECISION', 'ADRSPACE') reads the 
%   specified number of bits from the address space, ADRSPACE. ADRSPACE
%   can be 'A16', 'A24' or 'A32'. OBJ's MemorySpace property indicates
%   which VXI address space(s) are used by the instrument.
%
%   OUT = MEMREAD(OBJ, OFFSET, 'PRECISION', 'ADRSPACE', SIZE) reads a
%   block of data with a size specified by SIZE.
%    
%   Example:
%       v = visa('agilent', 'VXI0::8::INSTR');
%       fopen(v)
%       data = memread(v, 0, 'uint16');
%       data = memread(v, 2, 'uint8', 'A16', 3);
%       fclose(v);
%
%   See also ICINTERFACE/FOPEN, MEMWRITE, MEMPEEK, INSTRUMENT/PROPINFO,
%   INSTRHELP.
%

%   MP 11-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.11.2.4 $  $Date: 2004/01/16 20:02:22 $

% Error checking.
if nargin > 5
    error('instrument:memread:invalidSyntax', 'Too many input arguments.');
end

if (length(obj) > 1)
    error('instrument:memread:invalidOBJ', 'OBJ must be a 1-by-1 VISA-VXI or VISA-GPIB-VXI object.');
end

if ~isa(obj, 'instrument')
   error('instrument:memread:invalidOBJ', 'OBJ must be an interface object.');
end	

if ~(strcmp(obj.type, 'vxi') || strcmp(obj.type, 'gpib-vxi'))
    error('instrument:memread:invalidOBJ', 'MEMREAD is supported for VISA-VXI and VISA-GPIB-VXI objects.');
end

% Parse the input.
switch nargin
case 1
    addressSpace = 'A16';
    offset = 0;
	precision = 'uint8';
    size = 1;
case 2
    offset = varargin{1};
    addressSpace = 'A16';
    precision = 'uint8';
    size = 1;
case 3
    [offset, precision] = deal(varargin{:});
    addressSpace = 'A16';
    size = 1;
case 4
    [offset, precision, addressSpace] = deal(varargin{:});
    size = 1;
case 5
    [offset, precision, addressSpace, size] = deal(varargin{:});
end


% Verify offset.
if ~isa(offset, 'double')
    error('instrument:memread:invalidOFFSET', 'OFFSET must be a double.');
elseif isnan(offset) || ~isreal(offset)
    error('instrument:memread:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be finite.');
elseif isinf(offset)
    error('instrument:memread:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be finite.');
elseif (offset < 0)
	error('instrument:memread:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be greatert than or equal to 0.');
elseif (length(offset) > 1)
	error('instrument:memread:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be a scalar.');
end

% Verify size.
if ~isa(size, 'double')
    error('instrument:memread:invalidSIZE', 'SIZE must be a double.');
elseif isnan(size) || ~isreal(size)
    error('instrument:memread:invalidSIZE', 'Invalid SIZE specified. SIZE must be finite.');
elseif isinf(size)
    error('instrument:memread:invalidSIZE', 'Invalid SIZE specified. SIZE must be finite.');
elseif (size < 1)
	error('instrument:memread:invalidSIZE', 'Invalid SIZE specified. SIZE must be greater than 0.');
elseif (length(size) > 1)
	error('instrument:memread:invalidSIZE', 'Invalid SIZE specified. SIZE must be a scalar.');
end

% Verify addressSpace.
if ~ischar(addressSpace)
    error('instrument:memread:invalidADRSPACE', 'Invalid ADRSPACE specified. ADRSPACE must be ''A16'', ''A24'' or ''A32''.');
end

switch lower(addressSpace)
case 'a16'
    space = 1;
case 'a24'
    space = 2;
case 'a32'
    space = 3;
otherwise
    error('instrument:memread:invalidADRSPACE', 'Invalid ADRSPACE specified. ADRSPACE must be ''A16'', ''A24'' or ''A32''.');
end
    
% Verify precision.
if ~ischar(precision)
    error('instrument:memread:invalidPRECISION', 'Invalid PRECISION specified. PRECISION must be ''uint8'', ''uint16'', ''uint32'' or ''single''.');
end

switch lower(precision)
case 'uint8'
    precision = 0;
case 'uint16'
    precision = 1;
case 'uint32'
    precision = 2;
case 'single'
    precision = 3;
otherwise
    error('instrument:memread:invalidPRECISION', 'Invalid PRECISION specified. PRECISION must be ''uint8'', ''uint16'', ''uint32'' or ''single''.');
end

% Call the java memread method.
try
    data = memread(obj.jobject, space, offset, precision, size);
catch
    error('instrument:memread:opfailed', lasterr);
end

% Cast the results into the correct unsigned precision.
data = double(data);
switch precision
case 0
    data = data + (data<0).*256;
case 1
    data = data + (data<0).*65536;
case 2
    data = data + (data<0).*(2^32);
end

