function fig = fighndl(h)
%FIGHNDL  Gets handle of parent figure.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:17 $

if isa(h.Axes(1),'hg.axes')
   fig = h.Axes(1).Parent;
else
   fig = fighndl(h.Axes(1));
end
