function resp = readbin(nn,index,timeout)
%READ_NUMERIC Retrieves memory area and converts into a numeric array
%  DN = READ_NUMERIC(NN)
%  DN = READ_NUMERIC(NN,[],TIMEOUT) - reads all data from the specified memory 
%  area and converts it into a numeric representation.  Numeric conversion is 
%  controlled by the properties of the NN object.  The output 'DN' will be a 
%  numeric array that has dimensions defined by NN.SIZE, which is the dimensions 
%  array. Each element in the dimensions array contains the size of the array in 
%  that dimension.  If SIZE is a scalar, the output is a column vector of the specified 
%  length. 
%
%  DN = READ_NUMERIC(NN,INDEX)
%  DN = READ_NUMERIC(NN,INDEX,TIMEOUT) - read a subset of the numeric values from
%  the specified numeric array.  Each row of INDEX is applied as a subscript into the 
%  full NN array.  The output DN will be a column vector with one value per entry in the
%  INDEX.  Arrays indices start at 1 and range up the maximum value defined by SIZE.
%  If INDEX is a vector, each row is an single index  that defines one entry
%  from the defined numeric array.  The output DN will be a column vector of values
%  corresponding to the specified indices.   A new TIMEOUT value can be
%  explicitly passed to temporarily modify the default timeout property of the nn object.  
%
% Array properties
% NN.SIZE - Dimensions of output numeric array.  This defines the size of 'DN'
% NN.ARRAYORDER - Defines how sequential memory locations are mapped into matrices.
%   The default is 'col-major', which is the arrangment used by MATLAB.  Alternatively,
%   use 'row-major', which is the memory organization applied in C.
% Numeric representation 
%  NN.REPRESENT - Numeric representation
%    'float' - IEEE floating pointer representation (32 or 64 bits)
%    'signed' - 2's Compliment signed integers
%    'unsigned'- Unsigned binary integer
%    'fract' - Fractional fixed-point, see nn.p
%  NN.WORDSIZE - Number of valid bits in numeric representation.  This
%   property is computed from other properties such as 'storageunitspervalue' and therefore
%   read-only
%  NN.BINARYPT
%  Other properties of NN control the placement and arrangement of
%  the numeric values in memory.
%
%  Changes to the numeric representation are possible by modifying the
%  class properties.  However, the CONVERT method implements the adjusting
%  the properties to implement some common data types.
%
%   See also READ, WRITE, CONVERT, INT32.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.2.1 $  $Date: 2003/11/30 23:06:37 $
error(nargchk(1,3,nargin));
if ~ishandle(nn),
    error('First Parameter must be a BITFIELD Handle.');
end
if nargin==2 & prod(index)>1
    error('Bitfield has only one element.');
end

% Call base class (memoryobj) to get unformatted data
uidata  = read_memoryobj(nn);
uidata  = reshape(uidata,nn.storageunitspervalue,[]);
nvalues = prod(nn.size); % always equal to 1

% Endianness swap (if necessary)    
if ~strcmp( nn.endianness,'little') & (nn.storageunitspervalue > 1),
    uidata = flipud(uidata);
end

% Trim pre/post bytes (if necessary)
% For now, limited to increments of bitsperstorageunit
if nn.prepad > 0 |  nn.postpad > 0,
    preaus = nn.prepad/nn.bitsperstorageunit;
    postaus = nn.postpad/nn.bitsperstorageunit;
    if preaus + postaus > nn.storageunitspervalue,
        error(' Pre/Post padding exceeds available memory area');
    end    
    uidata = uidata(1+preaus:end-postaus,:); % extract only relevant bits
end 

uidata = uidata';
uidata = dec2bin(double(uidata),nn.bitsperstorageunit);
uidata = fliplr(reshape(flipud(uidata)',1,[])); % format LSB,...,MSB

% readbin operation
resp{1} = fliplr(uidata(nn.offset+1:nn.offset+nn.length));

% [EOF] readbin.m
