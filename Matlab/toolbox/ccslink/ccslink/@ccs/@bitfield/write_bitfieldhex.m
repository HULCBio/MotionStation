function dummy = write_bitfieldhex(nn,index,data)
% Private. Bitfield hexadecimal write.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $ $Date: 2003/11/30 23:06:43 $

error(nargchk(2,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a BITFIELD handle.');
end
if nargin==2,   
    data = index;
    index = [];
end
index = p_checkerforindex(nn,index);

if ~isequal(length(index),length(nn.size)) & length(index)
    error(generateccsmsgid('InvalidIndexInput'),['Index does not match size of bit field, use a (1 x '  num2str(length(nn.size)) ') array.' ]);
end
    
% Is data a valid input
if isempty(data), 
    error(generateccsmsgid('InvalidInput'),'DATA must be a hexadecimal string or a cell array of hexadecimal strings.');
end
data = CheckDataIfValid(data);

% Convert from hex to valid numeric value
data = ConvertHex2ValidNumeric(data,nn.offset,nn.length);

% Reshape value according to ARRAYORDER property
data = ApplyArrayOrder(nn,data);

% Convert numeric values into array of AUs 
uidata = ConvertNumeric2Raw(nn,data);

% Endianness swap (if necessary)
uidata = ApplyEndianness(nn,uidata);

% Call base class (memoryobj) to get unformatted data
uidata = MergeBitfieldWithWord(nn,uidata);

% Write raw values to memory
WriteRawToMemory(nn,uidata,index);

%------------------------------------------------
function data = CheckDataIfValid(data)
if ischar(data) || iscellstr(data),
    data = char(data);
    if size(data,1)>1
        data = data(1,:); % remove other elements and leave only one
        warning(generateccsmsgid('TooMuchData'),'DATA has more elements than the specified bitfield size, DATA will be limited to defined memory area.');
    end
else
    error(generateccsmsgid('InvalidInput'),'DATA must be an array of valid hexidecimal string.');
end
CheckStringIfValidHex(data);

%-------------------------------------------------
function CheckStringIfValidHex(h)
% hex2dec checking -----
if isempty(h), return, end
[m,n]=size(h);
% Right justify strings and form 2-D character array.
if ~isempty(find(h==' ' | h==0)),
  h = strjust(h);
  % Replace any leading blanks and nulls by 0.
  h(find(cumsum(h ~= ' ' & h ~= 0,2) == 0)) = '0';
else
  h = reshape(h,m,n);
end
% end: hex2dec checking -----

% Check for out of range values
chksum = (h < '0' | (h > '9' & h < 'A') | (h > 'F' & h < 'a') | h > 'f');
while prod(size(chksum))~=1
    chksum = sum(chksum);
end
if chksum>0
  errmsg = 'Input string found with characters other than 0-9, a-f, or A-F.';
  error(generateccsmsgid('InvalidInput'),sprintf('%s\n%s','DATA contains an invalid hexidecimal string.',errmsg));
end

%-------------------------------------------------
% Reshape value according to ARRAYORDER property
function data = ApplyArrayOrder(nn,data)
if strcmp(nn.arrayorder,'row-major'),
    data = reshape(permute(data,[2 1]),1,[]);
else  
    data = reshape(data,1,[]);
end

%--------------------------------------------
% Endianness swap (if necessary), Little endian only
function uidata = ApplyEndianness(nn,uidata)
if strcmp( nn.endianness,'big') & (nn.storageunitspervalue > 1),
    uidata = flipud(uidata);
end    

%--------------------------------------------
% Convert numeric values into array of AUs 
%  where each column is the the AUs necessary for one numeric value
%  The data will be little-endian (swapped later if necessary)
%  thus cc.write([1 256]), where storageunitspervalue = 3, represent = 'unsigned', bitsperstorageunit = 8
%  fdata = 
%    1  0
%    0  1
%    0  0
function uidata = ConvertNumeric2Raw(nn,data)
data = dec2hex( data );
zerostr = '0';
uidata = [];
mustlen = round( nn.bitsperstorageunit * nn.storageunitspervalue/4 ); % total bits in a value div (4 bits in a character)
needzerochars = mustlen-length(data);
if needzerochars > -1
    data  = [zerostr(ones(1,needzerochars)) data];
else
    warning(generateccsmsgid('DataIsSaturated'),['Overflow: Saturation was required to fit into the specified numeric range.']);
    data  = data(1+abs(needzerochars):end);
end
uidata  = hex2dec( flipud(reshape(data,mustlen/nn.storageunitspervalue,[])') )';
uidata = uidata';

%---------------------------------------------------
% Call base class (memoryobj) to get unformatted data
function uidata = MergeBitfieldWithWord(nn,uidata)
memdata  = read_memoryobj(nn);
memdata  = reshape(double(memdata),nn.storageunitspervalue,[]);
base     = dec2bin( bitshift((2^nn.length-1), ...
					nn.prepad+nn.offset,nn.prepad+nn.offset+nn.length), nn.wordsize);
baseinv  = dec2bin( (2^nn.wordsize-1) - bin2dec(base) );
baseinv  = bin2dec(flipud(reshape(baseinv,[],nn.storageunitspervalue)'));
if strcmp( nn.endianness,'big') & (nn.storageunitspervalue > 1),
    base    = flipud(base);
    baseinv = flipud(baseinv);
end
memdata = bitand(memdata,baseinv); % zero out bit field only
uidata  = bitor(memdata,uidata);

%--------------------------------------------
% Write raw values to memory
function WriteRawToMemory(nn,uidata,index)
write_memoryobj(nn,uidata);
% index version - one value only so not being used
% --> write_memoryobj(nn,(index-1).*nn.storageunitspervalue+1,uidata);

%-------------------------------------------
% Convert from hex to valid numeric value
function data = ConvertHex2ValidNumeric(data,offset,len)
n_data = hex2dec(data);
b_data = dec2bin(n_data);
bitsize = length(b_data);
if bitsize>len, % if hex value contains more bits than the allotted length
    warning(generateccsmsgid('DataIsTruncated'),'Hexadecimal DATA is too long, DATA will be truncated.');
    n_data = bin2dec(b_data(end-len:end));
end
data = n_data * (2^offset);  % shift data by its offset

% [EOF] write_bitfieldhex.m