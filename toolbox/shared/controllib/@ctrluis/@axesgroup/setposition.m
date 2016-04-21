function setposition(h,varargin)
%SETPOSITION   Sets axes group position.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:20 $

% Default implementation: delegate to @plotarray object
h.Axes.setposition(h.Position);