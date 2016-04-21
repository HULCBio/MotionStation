function  [xt,yt] = xyklein(t)
%XYKLEIN Coordinate functions for the figure-8 that
%   generates the Klein bottle in KLEIN1.

%   C. Henry Edwards, Univerity of Georgia. 6/20/93.
%
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.2 $  $Date: 2004/04/10 23:26:02 $

xt = sin(t);   yt = sin(2*t);
