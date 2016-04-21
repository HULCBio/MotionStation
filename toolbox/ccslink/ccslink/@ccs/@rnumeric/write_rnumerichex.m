function write_rnumerichex(nn,index,data)
% WRITE_RNUMERICHEX Private. Writes a hexadecimal data into a register
% location.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2003/11/30 23:11:51 $

error(nargchk(2,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a RNUMERIC handle.');
end
if nargin==2,
    data  = index;
    index = [];
end

% Is data a valid input
data = CheckDataIfValid(data);

% Is index valid?
shaped_index = CheckIndexIfValid(index,length(nn.size));

% Reshape value according to ARRAYORDER property
data = ArrangeBasedOnArrayOrder(nn,data);

% Do we have sufficent values? 
data = CheckForSize(nn,data);

% Convert numeric values into array of AUs 
uidata = ConvertHex2Raw(nn,data);

% Endianness swap (not - necessary)    

uidata = CastData(uidata,nn.bitsperstorageunit);

if nn.storageunitspervalue > 1
    uidata = reshape(uidata,[],nn.numberofstorageunits)';
end    

% Write raw values to register - always writes one value
if nargin==2 || (nargin==3 && isempty(index)),
    for i=1:nn.numberofstorageunits
        regwrite(nn.link,nn.regname{i},uidata(i),'binary',nn.timeout);
    end
else  % nargin==3, index specified
    for i=1:nn.storageunitspervalue
        regwrite(nn.link,nn.regname{shaped_index},uidata(shaped_index),'binary',nn.timeout);
    end
end

%------------------------------------------------
function data = CheckDataIfValid(data)
if isempty(data),
    error(generateccsmsgid('DataIsEmpty'),...
        'DATA must be a hexadecimal string or a cell array of hexadecimal strings.');
end
if ischar(data),  % change to 1 character array
    data = cellstr(data);
end
if ~iscellstr(data),
    error(generateccsmsgid('DataIsNotHexadecimal'),...
        'DATA must be a hexadecimal string or a cell array of hexadecimal strings.');
end
CheckStringIfValidHex(data);

%-------------------------------------------------
function CheckStringIfValidHex(h)
% hex2dec checking -----
	if iscellstr(h), h = char(h); end
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

% Check for out-of-range values
if any(any(~(h>='0' & h<='9') & ~(h>='a'&h<='f') & ~(h>='A'&h<='F'))) 
	error(generateccsmsgid('IllegalHexCharacters'),... 
	sprintf('DATA found with invalid hexadecimal characters, i.e., characters other than 0-9, a-f, or A-F.'));
end

%------------------------------------------------
% Reshape value according to ARRAYORDER property
function data = ArrangeBasedOnArrayOrder(nn,data)
if strcmp(nn.arrayorder,'row-major'),
    data = reshape(permute(data,[2 1]),1,[]);
else  
    data = reshape(data,1,[]);
end

%----------------------------------------
function data = CheckForSize(nn,data)
nvalues = numel(data);
nvaldef = 1; % nvaldef = prod(nn.size);
if nvalues < nvaldef,
    warning('DATA has less elements than specified numeric array, DATA will only be applied to beginning of storage area');
elseif nvalues > nvaldef,
    warning('DATA has more elements than specified numeric array, DATA will be limited to the defined storage area');
    data = {data{1}};  % data = {data{1:nvaldef}};  % Truncate!
end

%------------------------------------------
% Endianness swap (if necessary), Little endian only
function uidata = ApplyEndianness(nn,uidata)
if strcmp( nn.endianness,'big') && (nn.storageunitspervalue > 1),
    uidata = flipud(uidata);
end    

%-------------------------------------------
function uidata = CastData(uidata,bitsperstorageunit)
if bitsperstorageunit <= 8, % (we've already applied rounding)
    uidata = uint8(uidata);
elseif bitsperstorageunit <= 16,
    uidata = uint16(uidata);
elseif bitsperstorageunit <= 32,
    uidata = uint32(uidata);
else
    warning('Host computer does not natively support integer values > 32, data truncation likely')
    uidata = uint32(uidata);
end

%----------------------------------------
function shaped_index = CheckIndexIfValid(index,nsiz)
errid = generateccsmsgid('InvalidInput');
if isempty(index),
    shaped_index = 1;
elseif isnumeric(index) 
    if any(index<1) || any(mod(index,1))~=0, % check for negative, zero and fract index
        error(errid,'Second Parameter contains invalid numbers, INDEX must contain positive integer numbers.');
    elseif prod(index)>1, % check for any reference to 2nd or above elements
        error(errid,sprintf('%s\n%s','You are trying to write to a non-existent register location. All register objects contain only one element.',...
                    ['INDEX must be unspecified, empty or equal to [' num2str(ones(1,length(nsiz))) '].']));
    elseif length(index)~=nsiz
        error(errid,['Second Parameter INDEX must be a (Nx' num2str(nsiz) ') numeric vector.']);
    else
        shaped_index = 1;
    end
else
    error(errid,'Second Parameter INDEX must be numeric. ');
end

%---------------------------------------------------
% Convert numeric values into array of AUs 
%  where each column is the the AUs necessary for one numeric value
%  The data will be little-endian (swapped later if necessary)
%  thus cc.write([1 256]), where storageunitspervalue = 3, represent = 'unsigned', bitsperstorageunit = 8
%  fdata = 
%    1  0
%    0  1
%    0  0
function uidata = ConvertHex2Raw(nn,data)
len     = 1;    % length(data); % num of inputs
numhexperunit = round(nn.bitsperstorageunit/4);
uidata  = [];
% for - loop for going through all data - for now this is assumed 1 always
data{len} = CheckStringSize(nn,data{len});
data{len} = ApplyPadding(data{len},nn.prepad,nn.postpad);
audata    = flipud(reshape(data{len},numhexperunit,[])');
uidata    = horzcat(uidata,hex2dec(audata));
% end

%---------------------------------------------
function data = CheckStringSize(nn,data)
len = length(data);
mustlen = round(nn.storageunitspervalue*nn.bitsperstorageunit/4); % required length of hex string
if len<mustlen
    z = '0'; 
    data = [z(ones(1,mustlen-len)), data];
elseif len>mustlen,
    if hex2dec(data(1:end-mustlen))~=0,
        warning('DATA string is too long, the most significant characters are truncated.');
    end
    data = data(end-mustlen+1:end);
end

%------------------------------------------
function data = ApplyPadding(data,prepad,postpad)
z = '0';
iprepad = ceil(prepad/4);
xtra = mod(prepad,4);
if xtra, % if prepad not divisible by 4 
    temp = dec2bin(hex2dec(data(end-iprepad+1)));
    temp(end-xtra+1:end) = z(ones(1,xtra));
    data(end-iprepad+1) = dec2hex(bin2dec(temp));
    iprepad = iprepad-1;
end
for i=1:iprepad, % if prepad divisible by 4 
    data(end-i+1) = z;
end
ipostpad = ceil(postpad/4);
xtra = mod(postpad,4);
if xtra, % if postpad not divisible by 4 
    temp = dec2bin(hex2dec(data(ipostpad)));
    temp(1:xtra) = z(ones(1,xtra));
    data(ipostpad) = dec2hex(bin2dec(temp));
    ipostpad = ipostpad-1;
end
for i=1:ipostpad, % if postpad divisible by 4 
    data(i) = z;
end

% [EOF] write_rnumerichex.m