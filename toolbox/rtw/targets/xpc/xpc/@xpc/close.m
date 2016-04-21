function close(xpcObj)
% CLOSE Close the connection to the xPC target.
%
%   This function closes the serial or TCP/IP connection to the target,
%   freeing it up for use with other applications.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/03/25 04:16:58 $
%  

try, xpcgate('closecom'); catch, error(xpcgate('xpcerrorhandler')); end

%% EOF close.m
