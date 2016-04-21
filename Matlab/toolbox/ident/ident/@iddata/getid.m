function id = getid(data)
%GETID get the Identification tag of a data set

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2003/03/05 17:41:06 $

try
    id = data.Utility.Idn;
catch
    id = [];
end

