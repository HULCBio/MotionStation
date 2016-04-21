function file = readxpcfile(data)
%  READXPCFILE Reads an xpc file format.
%     DATA must be a vector of bytes (uint8) read from an
%     xpc file.  These are files written by a scope of
%     type file.  Data is typically obtained by using
%     xpctarget.fs.fread or by transfering a file from the 
%     target using xpctarget.ftp.get
%     
%     See also FTP.GET, FS.FOPEN, FS.FREAD

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4 $ $Date: 2003/04/24 18:22:57 $

file = xpcconvert('FILE', data);
if (file.numSignals > 1)
    file.data=real(file.data)';
end
% eof readxpcfile.m

