function openppt(file)
%OPENPPT Opens a Microsoft PowerPoint file.

% Copyright 1984-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2002/09/26 01:52:45 $

if ispc
    try
        winopen(file)
    catch
        edit(file)
    end
else
    edit(file)
end