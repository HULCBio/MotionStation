function resp = read_bitfield(nn,index,timeout)
% (Private) Reads bitfield value.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $ $Date: 2003/11/30 23:06:36 $

error(nargchk(1,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a BITFIELD Handle.');
end
if nargin==2,
    if any(index<1),
        error(generateccsmsgid('InvalidIndexInput'),['Invalid subscript [' num2str(index) '], negative indices are not allowed. ']);
    elseif prod(index)>1,
        error(generateccsmsgid('InvalidIndexInput'),['Invalid subscript [' num2str(index) '], a bit field cannot be an array with more than one elements. ']);
    else
        nsize = length(nn.size);
        if (length(index)~=nsize), % for consistency
            warning(generateccsmsgid('InvalidIndexInput'),['Subscript [' num2str(index) '] does not match size of bit field, use a [1x' num2str(nsize) '] vector of indices. ']);
        end
        index = 1; % always set to 1 if index is equivalent to 1 (ex. [1 1 1] )
    end
end

uidata = GetRawDataFromMemory(nn);
uidata = ApplyEndianness(nn,uidata);
uidata = CheckPadding(nn,uidata);
uidata = GetBitfieldData(nn,uidata);

% Convert adjusted array of 'valid' au into numeric values
switch (nn.represent), 
case {'fract','signed'}
    fdata = ConvertRaw2SignedInt(nn,uidata);
    fdata = AdjustBinaryPoint(fdata,nn.binarypt,nn.represent);
    
case {'ufract','unsigned'}
    fdata = ConvertRaw2UnsignedInt(nn,uidata);
    fdata = AdjustBinaryPoint(fdata,nn.binarypt,nn.represent);
    
case 'float',
    error(generateccsmsgid('RepresentationNotRecognized'),['Unexpected numeric representation ''' nn.represent ''', cannot represent a bit field as a floating point number.']);
otherwise  
    error(generateccsmsgid('RepresentationNotRecognized'),['Unexpected numeric representation: ' nn.represent]);
end

% Arrange data accordingly
if (nargin==1) || (nargin==3 & isempty(index)),  % Non-indexed
    resp = ApplyArrayOrder(nn,fdata);
else % Indexed - Don't bother try to shape it
    resp = fdata;
end

%-------------------------------
% Trim pre/post bytes (if necessary)
% For now, limited to increments of bitsperstorageunit
function uidata = CheckPadding(nn,uidata)
if nn.prepad>0 ||  nn.postpad>0,
    preaus = nn.prepad/nn.bitsperstorageunit;
    postaus = nn.postpad/nn.bitsperstorageunit;
    if (preaus+postaus) > nn.storageunitspervalue,
        error(generateccsmsgid('IncorrectPrePostPadValue'),' Pre/Post padding exceeds available memory area');
    end    
    uidata = uidata(1+preaus:end-postaus,:); % extract only relevant bits
end 

%---------------------------------
% Endianness swap (if necessary)    
function uidata = ApplyEndianness(nn,uidata)
if ~strcmp( nn.endianness,'little') & (nn.storageunitspervalue > 1),
    uidata = flipud(uidata);
end

%--------------------------
% Call base class (memoryobj) to get unformatted data
function uidata = GetRawDataFromMemory(nn)
uidata  = read_memoryobj(nn);
uidata  = reshape(uidata,nn.storageunitspervalue,[]);

%------------------------
function uidata = GetBitfieldData(nn,uidata)
uidata = uidata';
uidata = dec2bin(double(uidata),nn.bitsperstorageunit);
uidata = fliplr(reshape(flipud(uidata)',1,[])); % format LSB,...,MSB
uidata = uidata(nn.offset+1:nn.offset+nn.length)' - '0';

%----------------------------------
% Array-order not followed in bit fields because they are always scalars
function resp = ApplyArrayOrder(nn,fdata)
resp = fdata;
% if strcmp(nn.arrayorder,'row-major'), % apply arrayordering
%    rowmajdim = [nn.size(2) nn.size(1) nn.size(3:end)];
%    resp = permute(reshape(fdata,rowmajdim),[2 1]);
% else
%    resp = reshape(fdata,nn.size);
% end

%-------------------------
% Adjust binary point, for fractionals  
function fdata = AdjustBinaryPoint(fdata,binarypt,represent)
if strcmp(represent,'ufract') || strcmp(represent,'fract'),
    fdata = fdata./ (2^binarypt); 
end

%---------------------------------
function fdata = ConvertRaw2SignedInt(nn,uidata)
% nvalues = prod(nn.size); % always equal to 1
validbits = size(uidata,1);  % Not storageunitspervalue (padding!!)
maxposbit = 0;
iv = 1;
% for iv=1:nvalues, % nvalues MUST always be equal to 1
uival = double(uidata(:,iv))';
if uival(validbits) > maxposbit,  % Negative 
    fdata(iv) = uival*[2.^(0:nn.length-2)'; -2.^(nn.length-1)];
else % Positive 
    fdata(iv) = uival*[2.^(0:nn.length-1)'];
end 
% end 

%---------------------------------
function fdata = ConvertRaw2UnsignedInt(nn,uidata)
% nvalues = prod(nn.size); % always equal to 1
validbits = size(uidata,1);  % Not storageunitspervalue (padding!!)
scale     = 2.^(0:nn.length-1)';
iv = 1;
% for iv=1:nvalues,
uival     = double(uidata(:,iv))';
fdata(iv) = uival*scale;
% end

% [EOF] read_bitfield.m
