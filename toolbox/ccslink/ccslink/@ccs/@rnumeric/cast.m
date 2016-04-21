function resp = cast(rn,datatype,siz)
%CAST  Returns an object configured for a predefined target data type
%   O = CAST(MM,TYPE) - Defines the numeric representation to be
%   applied to the register object O.  The TYPE input defines 
%   some common data types.  This method coppies the properties of 
%   MM object to O and adjusts the properties of O to 
%   match the specified TYPE.  As a result, future READ/WRITE operations 
%   will apply the appropriate data conversion to implement the numeric 
%   representation. For uncommon datatypes, it is possible to 
%   directly modify the O properties, but generally it is better 
%   to use the CAST method.
% 
%   O = CAST(MM,TYPE,SIZE) - Does an additional reshaping - adjusts the 
%   'size' property - of the O object.
%
%   Note: SIZE is always 1 for register objects.
%
%  See also CONVERT, COPY.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2003/11/30 23:11:12 $

error(nargchk(2,3,nargin));
if ~ishandle(rn),
    error('First Parameter must be a RNUMERIC Handle.');
end
if ~ischar(datatype),
     error('DATATYPE parameter must be a string.');
end

if nargin==2
    resp = cast_rnumeric(rn,datatype);
else
    resp = cast_rnumeric(rn,datatype,siz);
end

% [EOF] cast.m
