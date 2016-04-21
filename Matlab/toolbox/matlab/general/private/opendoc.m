function opendoc(file)
%OPENDOC Opens a Microsoft Word file.

% Copyright 1984-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2002/09/26 01:52:44 $

if ispc
    try
        winopen(file)
    catch
        edit(file)
    end
else
    edit(file)
end