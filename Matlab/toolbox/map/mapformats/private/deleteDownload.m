function deleteDownload(filename)
%DELETEDOWNLOAD Delete a temporary filename from the system.

%   Copyright 1996-2003  The MathWorks, Inc.
%   $Revision: 1.1.10.2 $ $Date: 2003/08/01 18:23:35 $

try
    delete(filename);
catch
    wid = sprintf('%s:%s:warnDelete', getcomp, mfilename);
    s=sprintf('Unable to delete temporary file "%s".', filename);
    warning(wid, s);
end
