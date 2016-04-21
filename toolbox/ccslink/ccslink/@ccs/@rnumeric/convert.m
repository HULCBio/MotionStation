function mm = convert(mm,datatype,siz)
%CONVERT  Configures properties for predefined target data types
%   CONVERT(MM,TYPE) - Defines the numeric representation to be
%   applied to the register object MM.  The TYPE input defines 
%   some common data types.  This method adjusts the properties
%   of MM object to match the specified TYPE.  As a result,
%   future READ/WRITE operations will apply the appropriate
%   data conversion to implement the numeric representation.
%   For uncommon datatypes, it is possible to directly modify
%   the MM properties, but generally it is better to use the CONVERT
%   method.
% 
%   CONVERT(MM,TYPE,SIZE) - Does an additional reshaping - adjusts the 
%   'size' property - of the MM object.
%
%   Note: SIZE is always 1 for register objects.
%
%   See also CAST, COPY.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2003/11/30 23:11:25 $

error(nargchk(2,3,nargin));
if nargin==2
    mm = convert_rnumeric(mm,datatype);
else
    mm = convert_rnumeric(mm,datatype,siz);
end

% [EOF] convert.m