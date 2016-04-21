function dummy = write_registerobj(mm,index,data)
%WRITE_REGISTER Writes data into DSP memory
%   WRITE_REGISTER(MM,DATA)
%   WRITE_REGISTER(MM,DATA,[],TIMEOUT) - write the passed DATA into the memory area
%   defined by the MM object.  DATA can be either arrays of unsigned integers 
%   or arrays of hexidecimal strings.  If necessary, data will be saturated to
%   fit within the memory size (as defined by the bitsperstorageunit property). The DATA array 
%   can not extend past the memory area defined by the MM object. 
%   
%   WRITE_REGISTER(MM,DATA,INDEX)
%   WRITE_REGISTER(MM,DATA,INDEX,TIMEOUT) - write the passed DATA into the memory area,
%   but with an address offset of INDEX.  This offset is relative to the beginning 
%   of the define memory area.  The values in DATA will be written sequential 
%   from this offset location.  The DATA array can not extend past the memory area
%   defined by the MM object. 
%
%   See also WRITE, READ, CAST, NUMERICMEM.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $ $Date: 2003/11/30 23:10:51 $

error(nargchk(2,3,nargin));
if ~ishandle(mm),
    error('First Parameter must be a REGISTER Handle.');
end
if nargin==2,   
    data = index;
end

% convert strings/cell array into unsigned integer vector
if iscell(data) | ischar(data),   % Data is a cell array of hexidecimal (value sized)
    data = hex2dec(data);
end

% Convert data into an array of appropriately sized objects (AU)
if ~isnumeric(data),    % Data is an array of address unit sized binary values
    error('DATA must be a numeric array or hexidecimal strings (cell array) ');
end

% Convert data into unsigned integers representing au values
minau = 0;
maxau = 2^mm.wordsize-1;

data = round(reshape(data,1,[]));
if any( maxau < data),
    warning('Overflow: Saturation was required to fit into an register unit');
elseif any(minau > data),
    warning('Underflow: Saturation was required to fit into an register unit');
end
nelemindata = prod(size(data));    % Number of elements in input data array
if nargin > 2 & ~isempty(index),  % index mode
    if index < 1 | index+length(data)-1 >  mm.numberofstorageunits,
        error('Index parameter must remain within the defined storage area (numberofstorageunits)');
    end
else
	if nelemindata < mm.numberofstorageunits,
	    warning('DATA has less elements than specified memory area, DATA will only be applied to beginning of storage (register) area');
	elseif nelemindata > mm.numberofstorageunits,
	    warning('DATA has more elements than specified memory area, write will be be limited to defined storage (register) area');
	    data = data(1:mm.numberofstorageunits);
	end
end

if mm.bitsperstorageunit <= 8, % (we've already applied rounding)
    data = uint8(data);
elseif mm.bitsperstorageunit <= 16,
    data = uint16(data);
elseif mm.bitsperstorageunit <= 32,
    data = uint32(data);
else
    warning('Host computer does not natively support integer values > 32, data truncation likely')
    data = uint32(data);
end

if nargin == 2,
    for i=1:mm.numberofstorageunits
        regwrite(mm.link,mm.regname{i},data(i),'binary',mm.timeout);
    end
elseif nargin == 3, % timeout% index version - one value only!
    for i=0:mm.storageunitspervalue-1
        regwrite(mm.link,mm.regname{index+i},data(index+i),'binary',mm.timeout);
    end
elseif nargin == 4 & isempty(index), % timeout specified
    for i=1:mm.numberofstorageunits
        regwrite(mm.link,mm.regname{i},data(i),'binary',timeout);
    end
else % timeout specified, non-empty index
    for i=0:mm.storageunitspervalue-1
        regwrite(mm.link,mm.regname{index+i},data(index+i),'binary',timeout);
    end
end

% [EOF] write_registerobj.m
