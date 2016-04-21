function resp = read_enum(en,index,timeout)
%READ_ENUM Retrieves a string representation of the enumerated label from DSP memory
%  DN = READ_ENUM(EN)
%  DN = READ_ENUM(EN,[],TIMEOUT) - reads all data from the specified memory 
%  area and converts it into equivalent enumerated label.  When the embedded
%  data types is scalar, the output is a string (i.e. char array).  For arrays
%  of enumerated data, the result is a cell array of strings.  The size of the
%  returned cell array is defined by the EN.SIZE property.  
%
%  DN = READ_ENUM(EN,INDEX)
%  DN = READ_ENUM(EN,INDEX,TIMEOUT) - read a subset of the enumerated values from
%  the specified array indices.  Each row of INDEX is applied as a subscript into the 
%  full EN array.  The output (DN) will be a column vector with one value per entry in
%  INDEX.  Arrays indices start at 1 and range up the maximum value defined in EN.SIZE.
%  If INDEX is a vector, each row of INDEX represents the multi-dimesional index to a
%  single value in the embedded array.  The output DN will be a column vector of values
%  corresponding to the specified indices.   A new TIMEOUT value can be explicitly 
%  passed to temporarily modify the default timeout property of the EN object.  
%
%  Examples:
%   DSP Embedded C code:
%   enum TAG_ebases {First,Second,Third,Home} eBases = Home;
%   
%   > en = cc.symobj('eBases');  % cc = link object
%   > en.read
%     'Home'
%
%   See also READ, WRITE, READ_NUMERIC.

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.5.2.2 $ $Date: 2004/04/08 20:46:02 $

error(nargchk(1,3,nargin));
if ~ishandle(en),
    error('First Parameter must be a ENUM Handle.');
end
if nargin == 1,
    dspvalue = read_numeric(en);
elseif nargin == 2,
    dspvalue = read_numeric(en,index);
else
    dspvalue = read_numeric(en,index,timeout);
end

resp = en.equivalent(dspvalue);

% [EOF] read_enum.m
