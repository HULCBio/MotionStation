function rename(h,oldname,newname)
%RENAME Rename a file on an FTP site.
%    RENAME(FTP,OLDNAME,NEWNAME) renames a file on an FTP site.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/03/18 17:59:42 $

% Make sure we're still connected.
connect(h)

h.jobject.rename(oldname,newname);
