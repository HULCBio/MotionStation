function c = getBoxCorners(this)
%GETBOXCORNERS Return Box Corners
%
%  C = GETBOXCORNERS returns the lower-left and upper-right corners of the
%  bounding box [lower-left-x,y; upper-right-x,y],
%
%  or equivalently,  [left      bottom;
%                     right        top]

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:06 $

c = this.Corners;
