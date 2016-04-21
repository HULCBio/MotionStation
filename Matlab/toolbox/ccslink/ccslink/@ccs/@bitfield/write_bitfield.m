function write_bitfield(nn,index,data)
% WRITE_BITFIELD (Private) Writes bit field value.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $ $Date: 2003/11/30 23:06:42 $

error(nargchk(2,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a BITFIELD handle.');
end
% If index is not specified,
if nargin==2,   
    data = index;   
    index = [];
end
index = p_checkerforindex(nn,index);

if ~isequal(length(index),length(nn.size)) & length(index)
    error(generateccsmsgid('InvalidIndexInput'),['Index does not match size of bit field, use a (1 x '  num2str(length(nn.size)) ') array.' ]);
end
    
% Is data a valid input ?
if ~isnumeric(data),
    error(generateccsmsgid('InvalidInput'),'DATA must be a numeric array. ');
end

% Reshape value according to ARRAYORDER property
data = ApplyArrayorder(data,nn.arrayorder); 

% Check number of elements
data = CheckSizeOfData(data,nn.size); 

% Convert numeric values into array of AUs 
uidata = ConvertNumeric2Raw(nn,data);

uidata = ApplyEndianness(uidata,nn.endianness,nn.storageunitspervalue);

uidata = MergeBitfieldWithMemoryValue(nn,uidata);

% Write raw values to memory
WriteRaw2Memory(nn,uidata,index);

%------------------------------
function data = ApplyArrayorder(data,arrayorder)
if strcmp(arrayorder,'row-major'),
    data = reshape(permute(data,[2 1]),1,[]);
else  
    data = reshape(data,1,[]);
end

%--------------------------------
function data = CheckSizeOfData(data,nsize)
% Do we have sufficent values ?
nvalues = numel(data);
nvaldef = prod(nsize);
if nvalues < nvaldef,
    warning(generateccsmsgid('NotEnoughData'),sprintf(['DATA has less elements than specified numeric array,\n'...
            'DATA will only be applied to beginning of memory area.']));
elseif nvalues > nvaldef,
    warning(generateccsmsgid('TooMuchData'),sprintf(['DATA has more elements than specified numeric array,\n'...
            'DATA will be be limited to defined memory area.']));
    data = data(1:nvaldef);  % Truncate!
end

%------------------------------
function data = CheckRangeOfData(data,minval,maxval)
if any( maxval < data),
    warning(generateccsmsgid('DataIsSaturated'),'Overflow: Saturation was required to fit into the specified numeric range.');
    [maxdat,inx] = max(data);
    while maxdat > maxval,
        data(inx)    = maxval;
        [maxdat,inx] = max(data);
    end 
end
if any(minval > data),
    warning(generateccsmsgid('DataIsSaturated'),'Underflow: Saturation was required to fit into the specified numeric range.');
    [mindat,inx] = min(data);
    while mindat < minval,
        data(inx) = minval;
        [mindat,inx] = min(data);
    end 
end

%---------------------------
function uidata = ConvertUnsignedInt2Raw(nn,data)
data = data*2^(nn.prepad+nn.offset);  % scale data by prepend to shift bits within word    
bscaler = nn.bitsperstorageunit*(0:nn.storageunitspervalue-1);
uidata = [];
for val = data,  % Do conversion
    uidata = horzcat(uidata,mod(fix(val./2.^bscaler),2^nn.bitsperstorageunit)');
end

%--------------------------------
function [minval,maxval] = GetUnsignedNumericRange(blength)
minval = 0;
maxval = 2^blength-1;

%--------------------------------
function [minval,maxval] = GetSignedNumericRange(blength)
minval = -1*2^(blength-1);
maxval = abs(minval)-1;

%----------------------------------
% Endianness swap (if necessary), Big endian only
function uidata = ApplyEndianness(uidata,endianness,storageunitspervalue)
if strcmp( endianness,'big') & (storageunitspervalue > 1),
    uidata = flipud(uidata);
end    

%----------------------------------
% Call base class (memoryobj) to get unformatted data
function uidata = MergeBitfieldWithMemoryValue(nn,uidata)
memdata  = read_memoryobj(nn);
memdata  = reshape(double(memdata),nn.storageunitspervalue,[]);
base     = dec2bin( bitshift((2^nn.length-1), ...
					nn.prepad+nn.offset,nn.prepad+nn.offset+nn.length), nn.wordsize);
baseinv = dec2bin( (2^nn.wordsize-1) - bin2dec(base),nn.wordsize );
baseinv = bin2dec(flipud(reshape(baseinv,[],nn.storageunitspervalue)'));
if strcmp( nn.endianness,'big') & (nn.storageunitspervalue > 1),
    base    = flipud(base);
    baseinv = flipud(baseinv);
end
memdata = bitand(memdata,baseinv); % zero out bit field only
uidata  = bitor(memdata,uidata);

%----------------------------------------
% Convert numeric values into array of AUs 
%  where each column is the the AUs necessary for one numeric value
%  The data will be little-endian (swapped later if necessary)
%  thus cc.write([1 256]), where storageunitspervalue = 3, represent = 'unsigned', bitsperstorageunit = 8
%  fdata = 
%    1  0
%    0  1
%    0  0
function uidata = ConvertNumeric2Raw(nn,data)
switch (nn.represent)
case 'unsigned',
    data = round(double(data));
    [minval,maxval] = GetUnsignedNumericRange(nn.length);
    data   = CheckRangeOfData(data,minval,maxval);
    uidata = ConvertUnsignedInt2Raw(nn,data);
case 'signed',  % 2's Complement
    data = round(double(data));
    [minval,maxval] = GetSignedNumericRange(nn.length);
    data   = CheckRangeOfData(data,minval,maxval);

    negEs  = (0 > data)*2^nn.length; % if negative, adjust data to equivalent unsigned integer 
    data   = data + negEs;
    uidata = ConvertUnsignedInt2Raw(nn,data);
case {'float','fract','ufract'},
    error(generateccsmsgid('InvalidRepresentation'),['A bit field cannot be a represented as a floating point or a fractional number. ']);
otherwise 
    error(generateccsmsgid('InvalidRepresentation'),['Unexpected numeric representation: ''' nn.represent '''. ' ]);
end

%--------------------------------
% Write raw values to memory
function WriteRaw2Memory(nn,uidata,index)
if isempty(index),
    write_memoryobj(nn,uidata);
else % index version - one value only!
    write_memoryobj(nn,(index-1).*nn.storageunitspervalue+1,uidata);
end

% [EOF] write_bitfield.m