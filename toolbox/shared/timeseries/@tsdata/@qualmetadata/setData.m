function out = setData(h, newval)
%SETDATA Assigns data into quality ValueArray
%
%   SETDATA is used to assign data into the quality ValueArray. It checks
%   that the stored quality codes match the conversion table specified in
%   the qualmetadata object and convertis to int8 values prior to storage.
%
%   Author(s): J.G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:33:33 $

% Sets data to the ValueArray data property if the "data" property

if size(newval,2)>1
    error('Quality variable must be a single numeric column vector')
end
if ~all(ismember(newval,h.Code))
    warning('One or more quality codes are not specified in qualityInfo')
end

% Cast quality codes to integers and check that this does not currupt the
% data
newvalint = int8(newval);
if abs(newval-double(newvalint))>eps(255)
    error('qualmetadata:setData:allint','Quality codes must all be in the range -128 to 127')
end

out = newvalint;