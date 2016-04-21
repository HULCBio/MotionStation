function mkdir(h,dirname)
%MKDIR Creates a new directory on an FTP site.
%    MKDIR(FTP,DIRECTORY) creates a directory on the FTP site.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/03/18 17:59:25 $

% Make sure we're still connected.
connect(h)

h.jobject.makeDirectory(dirname);
