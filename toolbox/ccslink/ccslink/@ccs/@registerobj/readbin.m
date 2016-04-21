function resp = readbin(mm,index,timeout)
%READ2BIN Retrieves a block of DSP memory as hexadecimal strings.
%   DN = READ2BIN(MM)
%   DN = READ2BIN(MM,[],TIMEOUT) - reads a 
%
%
%   DN = READ2BIN(MM,INDEX)
%   DN = READ2BIN(MM,INDEX,TIMEOUT) - reads a ?
%
%   HS = READ2BIN(MM) - returns a binary string representation of 
%   the DSP's numeric values.  For arrays, the returned values will 
%   be a cell array of binary strings.  Conversely, if MM.SIZE equals 1,
%   (indicating a scalar), the output is an array of hex characters. 
%
%   DN = READ2BIN(MM,TIMEOUT) - The time alloted to perform the read is 
%   limited  by the MM.TIMEOUT property of the MM object.  However, 
%   this method can be used to explicitly define a different timeout
%   for the read.  For example, this may be necessary for very large 
%   data transfers.
%  
%   See also WRITE, READ, CAST, NUMERICMEM.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $ $Date: 2003/11/30 23:10:44 $

error(nargchk(1,3,nargin));
if ~ishandle(nn),
    error('First Parameter must be a NUMERIC Handle.');
end
% Call base class (registerobj) to get unformatted data
if nargin == 1,
    uidata = read_registerobj(nn);
elseif nargin == 2, % index only (1 value)
    uidata = read_registerobj(nn,index);
elseif nargin == 3 & isempty(index),
    uidata = read_registerobj(nn,[],timeout); % read all
else
    uidata = read_registerobj(nn,index,timeout);
end

% Re-arrange data as described by object
nvalues = prod(nn.size);
uidata = reshape(uidata,[nn.storageunitspervalue nvalues]);

% Endianness swap (if necessary)    
if ~strcmp( nn.endianness,'little') & (nn.storageunitspervalue > 1),
    uidata = flipud(uidata);
end

% Trim pre/post bytes (if necessary)
% For now, limited to increments of bitsperstorageunit
if nn.prepad > 0 |  nn.postpad > 0,
    preaus  = nn.prepad/nn.bitsperstorageunit;
    postaus = nn.postpad/nn.bitsperstorageunit;
    if preaus + postaus > nn.storageunitspervalue,
        error(' Pre/Post padding exceeds available memory area');
    end    
    uidata = uidata(1+prepaus:end-postaus,:);
end

% Convert adjusted array of 'valid' au into binary array
if nvalues == 1,
   resp{1} = reshape(fliplr(dec2bin(double(uidata),nn.bitsperstorageunit)'),1,[]);
else % create cell array TBD
   for iv=1:nvalues,
       resp{iv} = reshape(fliplr(dec2bin(double(uidata(:,iv)),nn.bitsperstorageunit)'),1,[]);
   end
   if length(nn.size) > 1,
        resp = reshape(resp,nn.size);
   end 
end

% [EOF] readbin.m