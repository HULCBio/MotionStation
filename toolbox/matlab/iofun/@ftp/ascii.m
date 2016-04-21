function ascii(f)
%BINARY  Sets ascii transfer type.
%   BINARY(F) sets ascii transfer type for the FTP object F.

% Matthew J. Simoneau, 31-Jan-2002
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/03/18 17:59:14 $

% Make sure we're still connected.
connect(f)

% There isn't an easier way to set the value of a StringBuffer.
f.type.setLength(0);
f.type.append('ascii');