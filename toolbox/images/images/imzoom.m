function imzoom(varargin)
%IMZOOM Zoom in and out on a 2-D plot.
%
%   Note: This function is obsolete and may be removed in future
%   versions. Use ZOOM instead.
%
%   See also ZOOM.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.13.4.2 $  $Date: 2003/08/01 18:09:13 $

wid = sprintf('Images:%s:obsoleteFunction',mfilename);
msg1 = 'This function is obsolete and may be removed ';
msg2 = 'in future versions. Use ZOOM instead.';
warning(wid,'%s\n%s',msg1,msg2);
zoom(varargin{:});
