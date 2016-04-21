function idx = convhullx(varargin)
%CONVHULLX Compatibility wrapper for CONVHULL.
%   IDX = CONVHULLX(X,Y,TRI) is the same as IDX = CONVHULL(X,Y) except
%   that the obsolete syntax warnings in MATLAB 6.1 are automatically
%   suppressed.
%
%   See also CONVHULL.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/03/22 22:03:59 $

if length(varargin) > 2
    idx = convhull(varargin{1:2});
else
    idx = convhull(varargin{:});
end
