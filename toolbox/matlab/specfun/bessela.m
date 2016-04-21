function [J,digits] = bessela(nu,x)
%BESSELA Obsolete Bessel function.
%   BESSELA is obsolete and will be eliminated in future versions.
%   Please use BESSELJ instead.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.13 $  $Date: 2002/04/15 03:55:22 $

warning('MATLAB:bessela:ObsoleteFunction',['BESSELA is obsolete and will be' ...
       ' eliminated in future versions.\n         Please use BESSELJ instead.'])
J = besselj(nu,x);
digits = log10(1/eps);
