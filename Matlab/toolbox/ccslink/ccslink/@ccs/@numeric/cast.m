function resp = cast(nn,datatype,siz)
%CAST  Returns an object configured for a predefined target data type
%   O = CAST(MM,TYPE) - Defines the numeric representation to be
%   applied to the memory array O.  The TYPE input defines 
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
%  See also CONVERT, COPY.

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.3 $ $Date: 2004/04/08 20:46:32 $

error(nargchk(2,3,nargin));

if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a NUMERIC handle.');
end

if nargin==2
    resp = cast_numeric(nn,datatype);
else
    resp = cast_numeric(nn,datatype,siz);
end

% [EOF] cast.m