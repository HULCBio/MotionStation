function Extent = extent(Constr)
%EXTENT  Returns bounding rectangle [Xmin Xmax Ymin Ymax]

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 05:08:22 $

if Constr.Ts
    rho = Constr.geometry;
    Extent = [-rho rho -rho rho];
else
    alpha = Constr.geometry;
    Extent = [1.05*alpha 0.95*alpha 0 0];
end