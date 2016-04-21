function disp(h)
% DISP Display method for the FTP object.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/03/18 17:59:20 $

disp(sprintf( ...
    '  FTP Object\n     host: %s\n     user: %s\n      dir: %s\n     mode: %s', ...
    h.host,h.username,char(h.remotePwd.toString),char(h.type.toString)));
