function resp = read(nn,index,timeout)
%READ Retrieves memory area and converts into a numeric array.
%  DN = READ(NN)
%  DN = READ(NN,[],TIMEOUT) - reads all data from the specified memory 
%  area and converts it into a numeric representation.  Numeric conversion is 
%  controlled by the properties of the NN object.  The output 'DN' will be a 
%  numeric array that has dimensions defined by NN.SIZE, which is the dimensions 
%  array. Each element in the dimensions array contains the size of the array in 
%  that dimension.  If SIZE is a scalar, the output is a column vector of the specified 
%  length. 
%
%  DN = READ(NN,INDEX)
%  DN = READ(NN,INDEX,TIMEOUT) - read a subset of the numeric values from
%  the specified numeric array.  Each row of INDEX is applied as a subscript into the 
%  full NN array.  The output DN will be a column vector with one value per entry in the
%  INDEX.  Arrays indices start at 1 and range up the maximum value defined by SIZE.
%  If INDEX is a vector, each row is an single index  that defines one entry
%  from the defined numeric array.  The output DN will be a column vector of values
%  corresponding to the specified indices. A new TIMEOUT value can be
%  explicitly passed to temporarily modify the default timeout property of the nn object.
%
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $ $Date: 2004/04/08 20:46:39 $

error(nargchk(1,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a NUMERIC Handle.');
end
if nargin == 1,
    resp = read_numeric(nn);
elseif nargin == 2,
    resp = read_numeric(nn,index);     
else
    resp = read_numeric(nn,index,timeout);
end

% [EOF] read.m