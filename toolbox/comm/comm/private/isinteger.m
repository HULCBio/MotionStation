function ecode = isinteger(array)
%ISINTEGER Test if all members of an array have integer values.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/01/09 17:35:20 $

array = array(:);
ecode = all(array == floor(array));
end
