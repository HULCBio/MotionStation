function close(varargin) 
%CLOSE Close figure.
%
%   CLOSE(H) closes the window with handle H.
%   CLOSE, by itself, closes the current figure window.
%  
%   CLOSE('name') closes the named window.
%  
%   CLOSE ALL  closes all the open figure windows.
%   CLOSE ALL HIDDEN  closes hidden windows as well.
%     
%   STATUS = CLOSE(...) returns 1 if the specified windows were closed
%   and 0 otherwise.
%  
%   See also DELETE.

%   MP 5-14-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 19:59:04 $

error('icdevice:close:unsupportedFcn', 'Use DISCONNECT to disconnect a device object from the instrument.');