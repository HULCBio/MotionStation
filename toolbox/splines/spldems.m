function spldems
%SPLDEMS Set up the command line demos.

%   Ned Gulley, 6-21-93
%   Copyright 1987-2002 C. de Boor and The MathWorks, Inc.
%   $Revision: 5.16 $  $Date: 2002/02/05 14:50:43 $

labelList=str2mat( ...
   'Cubic spline interpolation', ...
   'Cubic smoothing spline', ...
   'Knot choices', ...
   'Chebyshev spline', ...
   'Some B-splines', ...
   'Spline curves', ...
   'Simple ODE', ...
   'Bivariate approximation');


nameList= ...
   ['csapidem'
   'csapsdem'
   'pckkntdm'
   'chebdem '
   'bsplidem'
   'spcrvdem'
   'difeqdem'
   'tspdem  '];


cmdlnwin(labelList,nameList);
