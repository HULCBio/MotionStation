function [th,r,z] = cart2pol(x,y,z)
%CART2POL Transform Cartesian to polar coordinates.
%   [TH,R] = CART2POL(X,Y) transforms corresponding elements of data
%   stored in Cartesian coordinates X,Y to polar coordinates (angle TH
%   and radius R).  The arrays X and Y must be the same size (or
%   either can be scalar). TH is returned in radians. 
%
%   [TH,R,Z] = CART2POL(X,Y,Z) transforms corresponding elements of
%   data stored in Cartesian coordinates X,Y,Z to cylindrical
%   coordinates (angle TH, radius R, and height Z).  The arrays X,Y,
%   and Z must be the same size (or any of them can be scalar).  TH is
%   returned in radians.
%
%   See also CART2SPH, SPH2CART, POL2CART.

%   L. Shure, 4-20-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10 $  $Date: 2002/04/15 03:55:36 $

th = atan2(y,x);
r = sqrt(x.^2+y.^2);
