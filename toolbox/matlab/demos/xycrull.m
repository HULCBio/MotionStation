function  [xt,yt] = xycrull(t)
%XYCRULL Function that returns the coordinate functions
%   for the eccentric ellipse that generates the cruller
%   in the M-file CRULLER.
 
%   C. Henry Edwards, Univerity of Georgia. 6/20/93.
%
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/10 23:26:01 $

xt = 3*cos(t);   yt = sin(t);

