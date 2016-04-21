function data = setid(data)
%SETID set the Identification tag of a data set
% This is just a temporary tag to be used inside estimation algorithms

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2003/03/05 17:41:10 $

 try
    id = data.Utility.Idn;
catch
    id = [];
end
if isempty(id)
    try
    data.Utility.Idn = datenum(data.Utility.last);
end
end
