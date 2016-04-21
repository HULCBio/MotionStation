function disp(hObj)
%DISP DISP for an hdf5.hdf5type object

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:36 $

if size(hObj) == [1 1]
    disp([class(hObj) ':']);
    disp(' ');
    disp(get(hObj));
else
    builtin('disp', hObj);
end



