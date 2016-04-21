function bb = cast(mm,datatype,siz)
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
%   Note: SIZE is always 1 for bit fields.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $ $Date: 2003/11/30 23:06:16 $

error(nargchk(2,3,nargin));
if ~ishandle(mm),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a BITFIELD Handle.');
end
if ~ischar(datatype),
     error(generateccsmsgid('InvalidInput'),'Second Parameter must be a string.');
end
if nargin==3
	if ~isnumeric(siz),
         error(generateccsmsgid('InvalidInput'),'Third Parameter must be numeric.');
    else
        if isempty(siz),
            siz = mm.size;
        elseif any(siz<1)==1 || prod(siz)~=1,
            error(generateccsmsgid('InvalidSizeAssigment'),['Invalid bit field size [' num2str(siz) '], size must always be equivalent to 1. ']);
        end
    end    
end

bb = copy(mm); % copy constructor

convert(bb,datatype); % convert data type

if nargin==3, set(bb,'size',siz); end;  % reshape size (to 1)

% [EOF] convert.m
