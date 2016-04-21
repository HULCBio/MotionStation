function write_numerichex(nn,index,data)
%WRITE_NUMERICHEX - Writes hexadecimal data into DSP memory.
%   See also READ, WRITEBIN, WRITEHEX.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $ $Date: 2003/11/30 23:10:15 $

error(nargchk(2,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidInput'),'First Parameter must be a NUMERIC Handle.');
end
if nargin==2,   
    data  = index;
    index = [];
end
% Is data a valid input
if isempty(data), 
    error(generateccsmsgid('InvalidInput'),'DATA must be a hexadecimal string or a cell array of hexadecimal strings');
end
data = CheckDataIfValid(data);

% Process address offset from index
linearoffset = 1; % 1-based array offset
if nargin==3,
    [addroffset,linearoffset] = ComputeOffsetFromIndex(nn,nargin,index);
end

% Reshape value according to ARRAYORDER property
data = ArrangeBasedOnArrayOrder(nn,data);

% Do we have sufficent values ?
data = CheckForSize(nn,data,index,linearoffset);
 
% Convert numeric values into array of AUs 
uidata = ConvertHex2Raw(nn,data);

% Endianness swap (if necessary), Big endian only    
uidata = ApplyEndiannness(nn,uidata);

% Write raw values to memory
if nargin==2, % all
    write_memoryobj(nn,uidata);
else % index version
    write_memoryobj(nn,addroffset,uidata);
end

%----------------------------------------
% Endianness swap (if necessary), Big endian only    
function uidata = ApplyEndiannness(nn,uidata)
if strcmp( nn.endianness,'big') && (nn.storageunitspervalue > 1),
    uidata = flipud(uidata);
end    

%-----------------------------------------
function [addroffset,linearoffset] = ComputeOffsetFromIndex(nn,numargs,index)
if isempty(index),      
    addroffset   = 1;
    linearoffset = 1; % 1-based offset
    
elseif isnumeric(index) 
    index = p_checkerforindex(nn,index);
    nsiz = length(nn.size);
    if length(index)~=nsiz,
        error(generateccsmsgid('InvalidIndexInput'),['Index must be a (1 x '  num2str(nsiz) ') numeric vector ' ]);
    end
    
    if nsiz>1,
        index = p_sub2ind(nn,nn.size,index,nn.arrayorder);
    end
    addroffset = (index-1).*nn.storageunitspervalue + 1;
    linearoffset = index;
    
else
    error(generateccsmsgid('InvalidIndexInput'),['Index must be a (1 x '  num2str(nsiz) ') numeric vector ' ]);
    
end

%-----------------------------------
function fdata = ArrangeDataInCFormat(nn,data)
a = [];
siz = size(data);
totalnumel = prod(siz);
if totalnumel<prod(nn.size)
	a   = p_ind2sub(nn,siz,[1:totalnumel]',nn.arrayorder);
	ndx = p_sub2ind(nn,siz,a,'col-major');
elseif totalnumel==prod(nn.size)
	a   = p_ind2sub(nn,nn.size,[1:totalnumel]',nn.arrayorder);
	ndx = p_sub2ind(nn,nn.size,a,'col-major');
else
	a   = p_ind2sub(nn,siz,[1:totalnumel]',nn.arrayorder);
	ndx = p_sub2ind(nn,siz,a,'col-major');
end
fdata = data(ndx);
%----------------------------------------------
function bindata = GetBinaryRep(val,wordsize)
onebin  = dec2bin(1,wordsize);
negdata = dec2bin(abs(val),wordsize);
negdata = strrep(negdata,'1','x');
negdata = strrep(negdata,'0','1');
negdata = strrep(negdata,'x','0');
bindata = addbinstr(negdata,onebin);
%------------------------------
function out = addbinstr(data,onebin)
rem = '0';
for i=length(data):-1:1
    [out(i),rem_n] = addbin(data(i),onebin(i));
    for j = 1:length(rem)
        [out(i),rem_n(j+1)] = addbin(out(i),rem(j));
    end
    rem = rem_n;
end
%----------------------------
function [out,rem] = addbin(bin1,bin2)
if bin1=='1' & bin2=='1'
    out = '0';  rem = '1';
elseif ~strcmp(bin1,bin2)
    out = '1';  rem = '0';
else
    out = '0';  rem = '0';
end
%--------------------------------
function data = CheckIfWithinRange(data,minval,maxval)
if any( maxval < data),
    warning(generateccsmsgid('DataIsSaturated'),'Overflow: Saturation was required to fit into the specified numeric range');
    [maxdat,inx] = max(data);
    while maxdat > maxval,
        data(inx) = maxval;
        [maxdat,inx] = max(data);
    end
end
if any(minval > data),
    warning(generateccsmsgid('DataIsSaturated'),'Underflow: Saturation was required to fit into the specified numeric range');
    [mindat,inx] = min(data);
    while mindat < minval,
        data(inx) = minval;
        [mindat,inx] = min(data);
    end
end
%------------------------------------------
function data = CheckForSize(nn,data,index,linearoffset)
nvalues = numel(data);
nvaldef = prod(nn.size);
if isempty(index),
	if nvalues < nvaldef,
		warning(generateccsmsgid('NotEnoughData'),'DATA has less elements than the specified numeric array size, DATA will only be applied to beginning of memory area');
	elseif nvalues > nvaldef,
        warning(generateccsmsgid('TooManyData'),'DATA has more elements than the specified numeric array size, DATA will be be limited to defined memory area');
        data = { data{1:nvaldef} };  % Truncate!
    end
else
    if (length(linearoffset)==1) && (linearoffset<=nvaldef) && ((linearoffset+nvalues-1)>nvaldef),
        warning(generateccsmsgid('DataIsTruncated'),'DATA has extra elements, DATA will be truncated ');
        data = { data{1:nvaldef-linearoffset+1} };  % Truncate!
    end
end
%---------------------------------------
function data = ArrangeBasedOnArrayOrder(nn,data)
sizdata = size(data);
if length(sizdata)==2 && any(sizdata==1) && strcmp(nn.arrayorder,'row-major')
    % if writing a vector to a row-major, no arranging of data necessary
    return;
end
% Regular arranging of input data
if strcmp(nn.arrayorder,'col-major')
    data = data(1:numel(data));  % linear - write as it is referenced by Matlab
else
    data = reshape( ArrangeDataInCFormat(nn,data),1,[] );
end
%------------------------------------------
% Convert numeric values into array of AUs 
%  where each column is the the AUs necessary for one numeric value
%  The data will be little-endian (swapped later if necessary)
%  thus cc.write([1 256]), where storageunitspervalue = 3, represent = 'unsigned', bitsperstorageunit = 8
%  fdata = 
%    1  0
%    0  1
%    0  0
function uidata = ConvertHex2Raw(nn,data)
len = prod(size(data));
numhexperunit = ceil(nn.bitsperstorageunit/4);
uidata = [];
for i=1:len,
    data{i} = CheckStringSize(nn,data{i});
    data{i} = ApplyPadding(data{i},nn.prepad,nn.postpad);
    audata  = flipud(reshape(data{i},numhexperunit,[])');
    % check range here?
    uidata = horzcat(uidata,hex2dec(audata));
end

%---------------------------------------------
function data = CheckStringSize(nn,data)
len = length(data);
mustlen = round(nn.storageunitspervalue*nn.bitsperstorageunit/4); % required length of hex string
if len<mustlen
    z = '0'; 
    data = [z(ones(1,mustlen-len)), data];
elseif len>mustlen,
    if hex2dec(data(1:end-mustlen))~=0,
        warning(generateccsmsgid('DataIsTruncated'),'DATA string is too long, the most significant characters are truncated.');
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

%---------------------------------------------
function [minval,maxval] = GetRange(nn)
switch (nn.represent),
case {'unsigned','ufract'},
    % Check if data is within allowed range - saturate if above or below
    f = 'f'; o = '0';
    hexpervalue = round(nn.wordsize/4);
    maxval = f(ones(1,hexpervalue));
    minval = o(ones(1,hexpervalue));
%     data = CheckIfWithinRange(data,minval,maxval);
case {'signed','fract'},  % 2's Complement
    % Check if data is within allowed range - saturate if above or below
    f = 'f'; o = '0';
    maxval = ['8' o(ones(1,hexpervalue-1))];
    minval = ['7' f(ones(1,hexpervalue-1))];
%     data   = CheckIfWithinRange(data,minval,maxval);
case 'float',
otherwise 
    error(generateccsmsgid('InvalidRepresentation'),['Unexpected numeric representation: ''' nn.represent]);
end

%------------------------------------------------
function data = CheckDataIfValid(data)
if ischar(data),
    nsiz = size(data,1);
    % convert data to cell string
    if nsiz==1,
        data = { data }; % data has >1 lines of hex
    else
        tmp{nsiz} = []; % data has >1 lines of hex
        for i=1:nsiz,
            tmp{i} = data(i,:);
        end
        data = tmp;
    end
end
if ~iscellstr(data) ,
    error(generateccsmsgid('InvalidInput'),'DATA must be an array of valid hexidecimal string.');
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

% [EOF] write_numerichex.m