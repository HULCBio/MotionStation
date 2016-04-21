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

%   MP 1-31-00
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.5.2.3 $  $Date: 2004/01/16 20:00:48 $

error('instrument:close:unsupportedFcn', 'Use FCLOSE to disconnect an interface object from the instrument.');