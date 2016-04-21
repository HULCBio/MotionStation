function connect(h)
%CONNECT Open a connection to the server.
%    CONNECT(FTP) opens a connection to the server.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/03/18 17:59:41 $

% If we're already connected, exit.
try
    h.jobject.getStatus;
    return
end

% Try to open.
try
    h.jobject.connect(h.host,h.port);
catch
    error('MATLAB:ftp:NoConnection', ...
        'Could not open a connection to "%s", port "%.0f".',h.host,h.port)
end

% Try to login.
try
    isSuccess = h.jobject.login(h.username,h.password);
catch
    isSuccess = false;
end
if ~isSuccess
    error('MATLAB:ftp:BadLogin','Connection refused for "%s".',h.username)
end

% Try to return to the directory we were in before, if any.
if (h.remotePwd.length == 0)
    h.remotePwd.append(h.jobject.printWorkingDirectory);
else
    cd(h,char(h.remotePwd.toString));
end
