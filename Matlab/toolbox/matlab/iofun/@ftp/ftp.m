function h = ftp(host,username,password)
% FTP Create an FTP object.
%    FTP(host,username,password) returns an FTP object.  If only a host is 
%    specified, it defaults to "anonymous" login.
%
%    An alternate port can be specified by separating it from the host name
%    with a colon.  For example: ftp('ftp.mathworks.com:34')

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/03/18 17:59:22 $

% Our FTP implementation uses code from the Apache Jakarta Project.
% Copyright (c) 2001 The Apache Software Foundation.  All rights reserved.

error(javachk('jvm','The FTP object'))

% Short-circut cases.
if (nargin == 0)
   % All MATLAB objects need a default constructor.  It is useless, though.
   % Immutable fields.
   h.jobject = org.apache.commons.net.ftp.FTPClient;
   h.host = '';
   h.port = 21;
   h.username = '';
   h.password = '';
   % Mutable fields.  Use StringBuffers so these will act as references.
   h.remotePwd = java.lang.StringBuffer('');
   h.type = java.lang.StringBuffer('binary');
   % Make the cast.
   h = class(h,'ftp');
   return
elseif isa(host,'ftp')
   % If given an FTP object, give it back.
   h = host;
   return
end

% Agrument parsing
error(nargchk(1,3,nargin))
switch nargin
case 3
    % Everything passed in.
case 1
    % Default to anonymous login
    username = 'anonymous';
    password = 'anonymous@example.com';
otherwise
    error('Incorrect number of arguments.')
end

% Immutable fields.
h.jobject = org.apache.commons.net.ftp.FTPClient;
colon = find(host==':');
if isempty(colon)
    h.host = host;
    h.port = 21;
else
    h.host = host(1:colon-1);
    h.port = str2double(host(colon+1:end));
end
h.username = username;
h.password = password;

% Mutable fields.  Use StringBuffers so these will act as references.
h.remotePwd = java.lang.StringBuffer('');
h.type = java.lang.StringBuffer('binary');

% Make the cast.
h = class(h,'ftp');

% Connect.
connect(h)