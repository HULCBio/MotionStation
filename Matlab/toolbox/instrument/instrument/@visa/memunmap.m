function memunmap(obj)
%MEMUNMAP Unmap memory for low-level memory read and write operations.
%
%   MEMUNMAP(OBJ) unmaps memory space previously mapped by the MEMMAP
%   function. OBJ must be a 1-by-1 VISA-VXI or VISA-GPIB-VXI instrument
%   object.
%
%   OBJ's MappedMemorySize property will be set to 0 and OBJ's 
%   MappedMemoryBase property will be set to 0H if the memory was
%   unmapped successfully.
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
%   See also MEMPEEK, MEMPOKE, MEMMAP, INSTRUMENT/PROPINFO, INSTRHELP.
%

%   MP 11-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.10.2.3 $  $Date: 2004/01/16 20:02:23 $


% Error checking.
if (length(obj) > 1)
    error('instrument:memunmap:invalidOBJ', 'OBJ must be a 1-by-1 VISA-VXI or VISA-GPIB-VXI object.');
end

if ~(strcmp(obj.type, 'vxi') || strcmp(obj.type, 'gpib-vxi')) 
    error('instrument:memunmap:invalidOBJ', 'MEMUNMAP is supported for VISA-VXI and VISA-GPIB-VXI objects.');
end

% Call the java memunmap method.
try
    memunmap(obj.jobject);
catch
    error('instrument:memunmap:opfailed', lasterr);
end
	