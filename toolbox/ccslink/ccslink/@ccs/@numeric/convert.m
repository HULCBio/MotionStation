function mm = convert(mm,datatype,siz)
%CONVERT  Configures properties for predefined target data types
%   CONVERT(MM,TYPE) - Defines the numeric representation to be
%   applied to the memory array MM.  The TYPE input defines 
%   some common data types.  This method adjusts the properties
%   of MM object to match the specified TYPE.  As a result,
%   future READ/WRITE operations will apply the appropriate
%   data conversion to implement the numeric representation.
%   For uncommon datatypes, it is possible to directly modify
%   the MM properties, but generally it better to use the CONVERT
%   method.
% 
%   CONVERT(MM,TYPE,SIZE) - Does an additional reshaping - adjusts the 
%   'size' property - of the MM object.
%
%  See also CONVERT, COPY.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $ $Date: 2003/11/30 23:09:47 $

error(nargchk(2,3,nargin));
if nargin==2
    convert_numeric(mm,datatype);
else
    convert_numeric(mm,datatype,siz);
end

% [EOF] convert.m
