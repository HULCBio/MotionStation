function memmap(obj, varargin)
%MEMMAP Map memory for low-level memory read and write.
%
%   MEMMAP(OBJ, 'ADRSPACE', OFFSET, SIZE) maps the amount of memory
%   specified by SIZE in address space, ADRSPACE, with the offset, 
%   OFFSET, for interface object OBJ. OBJ must be a 1-by-1 VISA-VXI 
%   or VISA-GPIB-VXI interface object. ADRSPACE can be set to 'A16', 
%   'A24' or 'A32'. 
%
%   OBJ's MemorySpace property indicates which VXI address space(s) are
%   used by the instrument.
%
%   The interface object must be connected to the instrument with the 
%   FOPEN function before memory can be mapped for low-level memory read
%   and write operations otherwise an error is returned. A connected
%   interface object has a Status property value of open.
%
%   The MappedMemorySize property returns the amount of memory mapped.  
%   If this value is 0, then no memory has been mapped.
%
%   The memory space must be mapped before MEMPOKE or MEMPEEK can be
%   used.
%
%   To unmap the memory use the MEMUNMAP function. If memory is mapped
%   and FCLOSE is called, the memory is unmapped before the object is 
%   disconnected from the instrument.
%
%   Example:
%       v = visa('agilent', 'VXI0::8::INSTR');
%       fopen(v)
%       memmap(v, 'A16', 0, 16);
%       data = mempeek(v, 0);
%       data = mempeek(v, 2, 'uint16');
%       memunmap(v);
%       fclose(v);
%
%   See also ICINTERFACE/FOPEN, ICINTERFACE/FCLOSE, MEMPEEK, MEMPOKE, 
%   MEMUNMAP, INSTRUMENT/PROPINFO, INSTRHELP.
%

%   MP 11-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.11.2.4 $  $Date: 2004/01/16 20:02:19 $

% Error checking.
if nargin > 4
    error('instrument:memmap:invalidSyntax', 'Too many input arguments.');
end

if (length(obj) > 1)
    error('instrument:memmap:invalidOBJ', 'OBJ must be a 1-by-1 VISA-VXI or VISA-GPIB-VXI object.');
end

if ~isa(obj, 'instrument')
   error('instrument:memmap:invalidOBJ', 'OBJ must be an interface object.');
end	

if ~(strcmp(obj.type, 'vxi') || strcmp(obj.type, 'gpib-vxi'))
    error('instrument:memmap:invalidOBJ', 'MEMMAP is supported for VISA-VXI and VISA-GPIB-VXI objects.');
end

% Parse the input.
switch nargin
case 1
    error('instrument:memmap:invalidSyntax', 'ADRSPACE must be specified.');
case 2
    error('instrument:memmap:invalidSyntax', 'OFFSET must be specified.');
case 3
    error('instrument:memmap:invalidSyntax', 'SIZE must be specified.');	
case 4
    [addressSpace, offset, size] = deal(varargin{:});
end

% Verify addressSpace.
if ~ischar(addressSpace)
    error('instrument:memmap:invalidADRSPACE', 'Invalid ADRSPACE specified. ADRSPACE must be ''A16'', ''A24'' or ''A32''.');
end

switch lower(addressSpace)
case 'a16'
    space = 1;
case 'a24'
    space = 2;
case 'a32'
    space = 3;
otherwise
    error('instrument:memmap:invalidADRSPACE', 'Invalid ADRSPACE specified. ADRSPACE must be ''A16'', ''A24'' or ''A32''.');
end

% Verify offset.
if ~isa(offset, 'double')
    error('instrument:memmap:invalidOFFSET', 'OFFSET must be a double.');
elseif isnan(offset) || ~isreal(offset)
    error('instrument:memmap:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be finite.');
elseif isinf(offset)
    error('instrument:memmap:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be finite.');
elseif (offset < 0)
	error('instrument:memmap:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be greater than or equal to 0.');
elseif (length(offset) > 1)
	error('instrument:memmap:invalidOFFSET', 'Invalid OFFSET specified. OFFSET must be a scalar.');
end

% Verify size.
if ~isa(size, 'double')
    error('instrument:memmap:invalidSIZE', 'SIZE must be a double.');
elseif isnan(size) || ~isreal(size)
    error('instrument:memmap:invalidSIZE', 'Invalid SIZE specified. SIZE must be finite.');
elseif isinf(size)
    error('instrument:memmap:invalidSIZE', 'Invalid SIZE specified. SIZE must be finite.');
elseif (size < 1)
	error('instrument:memmap:invalidSIZE', 'Invalid SIZE specified. SIZE must be greater than 0.');
elseif (length(size) > 1)
	error('instrument:memmap:invalidSIZE', 'Invalid SIZE specified. SIZE must be a scalar.');
end	

% Call the java memmap method.
try
    memmap(obj.jobject, space, offset, size);
catch
    error('instrument:memmap:opfailed', lasterr);
end
	