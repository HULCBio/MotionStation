function Slope = slope(Constr)
%SLOPE  Computes constraint slope

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 05:08:10 $

Slope = round(diff(Constr.Magnitude) / diff(log10(Constr.Frequency)));
