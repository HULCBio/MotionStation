function out = ischannel(obj)
%ISCHANNEL True for channels.
%
%    ISCHANNEL(OBJ) returns a logical 1 if OBJ is a channel or channel array
%    and returns a logical 0 otherwise.
%
%    See also ISVALID.
%

%    MP 3-24-99
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.4 $  $Date: 2003/08/29 04:40:57 $

% A non-daqchild object cannot be a channel.
out = logical(0);