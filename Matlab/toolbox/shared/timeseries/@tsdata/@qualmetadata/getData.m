function A = getData(h, data)
%GETDATA Extracts data from qualit ValueArray
%
%   GETDATA is used to extract data from the quality ValueArray. It checks
%   that the stored quality codes match the conversion table specified in
%   the qualmetadata object.
%
%   Author(s): J.G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:33:30 $

% Cast quality codes back to doubles
data = double(data);

if ~all(ismember(data,h.Code))
    warning('One or more quality codes are not specified in qualityInfo')
end
A = data;
