function Extent = extent(Constr)
%EXTENT  Returns bounding rectangle [Xmin Xmax Ymin Ymax]

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 05:10:35 $

if Constr.Ts
    Extent = [-1 1 -1 1];
else
    Extent = [-.1 0 -.1 .1];
end