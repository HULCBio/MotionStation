function rmdir(h,dirname)
%rmdir Remove a directory on an FTP site.
%    RMDIR(FTP,DIRECTORY) removes a directory on an FTP site.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/03/18 17:59:43 $

% Make sure we're still connected.
connect(h)

status = h.jobject.removeDirectory(dirname);
if (status == 0)
    code = h.jobject.getReplyCode;
    switch code
        case 550
            error('Could not remove "%s" on the server.',dirname);
        otherwise
            error('FTP error %.0f.',code)
    end
end