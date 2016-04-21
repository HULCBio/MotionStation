function box = getClosedBox(this)
%GETBOXCORNERS Return 5 Box Corners
%
%  BOX = GETCLOSEDBOX returns all 5 bos corners.  The corners are orders
%  counter-clockwise starting in the lower-left.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:07 $

bb = this.Corners;

box = [bb(1,1) bb(1,2);...
       bb(2,1) bb(1,2);...
       bb(2,1) bb(2,2);...
       bb(1,1) bb(2,2);...
       bb(1,1) bb(1,2)];

