function Extent = extent(Constr)
%EXTENT  Returns bounding rectangle [Xmin Xmax Ymin Ymax]

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 05:10:08 $

if Constr.Ts
    Extent = [-1 1 -1 1];
else
    Extent = [-1.05*Constr.Frequency 0 0 0];
end