function memwrite(obj, varargin)
%MEMWRITE High-level memory write to VXI register.
%
%   MEMWRITE(OBJ, DATA) writes the uint8 value, DATA, to the A16 address
%   space with an offset of 0 for interface object, OBJ. OBJ must be a 
%   1-by-1 VISA-VXI or VISA-GPIB-VXI interface object. DATA can be an 
%   array of values.
%
%   The interface object must be connected to the instrument with the 
%   FOPEN function before any data can be written to the instrument 
%   otherwise an error is returned. A connected interface object has
%   a Status property value of open.
%
%   MEMWRITE(OBJ, DATA, OFFSET) writes a uint8 value, DATA, to the A16 
%   address space with an offset, OFFSET. OFFSET is specified as a decimal
%   value.
% 
%   MEMWRITE(OBJ, DATA, OFFSET, 'PRECISION') writes DATA with precision,
%   PRECISION. PRECISION can be 'uint8', 'uint16', 'uint32' or 'single'.
%
%   MEMWRITE(OBJ, DATA, OFFSET, 'PRECISION', 'ADRSPACE') writes DATA to 
%   the address space, ADRSPACE. ADRSPACE can be 'A16', 'A24' or 'A32'.
%   OBJ's MemorySpace property indicates which VXI address space(s) are 
%   used by the instrument.
%
%   Example:
%       v = visa('ni', 'VXI0::1::INSTR');
%       fopen(v);
%       memwrite(v, 45056, 6, 'uint16', 'A16');
%       fclose(v)
%
%   See also ICINTERFACE/FOPEN, MEMREAD, MEMPOKE, INSTRUMENT/PROPINFO,
%   INSTRHELP.
%

%   MP 11-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.12.2.4 $  $Date: 2004/01/16 20:02:24 $

% Error checking.
if nargin > 5
    error('instrument:memwrite:invalidSyntax', 'Too many input arguments.');
end

if (length(obj) > 1)
    error('instrument:memwrite:invalidOBJ', 'OBJ must be a 1-by-1 VISA-VXI or VISA-GPIB-VXI object.');
end

if ~isa(obj, 'instrument')
   error('instrument:memwrite:invalidOBJ', 'OBJ must be an interface object.');
end	

if ~(strcmp(obj.type, 'vxi') || strcmp(obj.type, 'gpib-vxi'))
    error('instrument:memwrite:invalidOBJ', 'MEMWRITE is supported for VISA-VXI and VISA-GPIB-VXI objects.');
end

% Parse the input.
switch nargin
case 1
	error('instrument:memwrite:invalidSyntax', 'DATA must be specified');
case 2
    data = varargin{1};
    offset = 0;
    addressSpace = 'A16';
    precision = 'uint8';
case 3
    [data, offset] = deal(varargin{:});
    addressSpace = 'A16';
    precision = 'uint8';
case 4
    [data, offset, precision] = deal(varargin{:});
    addressSpace = 'A16';
case 5
    [data, offset, precision, addressSpace] = deal(varargin{:});
end

% Verify addressSpace.
if ~ischar(addressSpace)
    error('instrument:memwrite:invalidADRSPACE', 'Invalid ADRSPACE specified. ADRSPACE must be ''A16'', ''A24'' or ''A32''.');
end

switch lower(addressSpace)
case 'a16'
    space = 1;
case 'a24'
    space = 2;
case 'a32'
    space = 3;
otherwise
    error('instrument:memwrite:invalidADRSPACE', 'Invalid ADRSPACE specified. ADRSPACE must be ''A16'', ''A24'' or ''A32''.');
end
    
% Verify data.
if ~(isnumeric(data) || ischar(data))
	error('instrument:memwrite:invalidDATA', 'Invalid DATA specified. DATA must be numeric or a string.');
elseif ~all(isfinite(data))
    error('instrument:memwrite:invalidDATA', 'Invalid DATA specified. DATA must be finite.')
elseif isempty(data)
    return;
end

% Verify precision.
if ~ischar(precision)
    error('instrument:memwrite:invalidPRECISION', 'Invalid PRECISION specified. PRECISION must be ''uint8'', ''uint16'', ''uint32'' or ''single''.');
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
    error('instrument:memwrite:invalidPRECISION', 'Invalid PRECISION specified. PRECISION must be ''uint8'', ''uint16'', ''uint32'' or ''single''.');
end

% Verify offset.
if ~isa(offset, 'double')
    error('instrument:memwrite:invalidOFFSET', 'OFFSET must be a double.');
elseif isnan(offset) || ~isreal(offset)
    error('instrument:memwrite:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be finite.');
elseif isinf(offset)
    error('instrument:memwrite:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be finite.');
elseif (offset < 0)
	error('instrument:memwrite:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be greater than or equal to 0.');
elseif (length(offset) > 1)
	error('instrument:memwrite:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be a scalar.');
end

% Call the java memwrite method.
try
    memwrite(obj.jobject, space, data, offset, precision, length(data));
catch
    error('instrument:memwrite:opfailed', lasterr);
end