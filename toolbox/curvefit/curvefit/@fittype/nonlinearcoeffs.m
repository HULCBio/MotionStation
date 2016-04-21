function cella = nonlinearcoeffs(model)
%NONLINEARCOEFFS array of indices of nonlinear coefficients.
%   NONLINEARCOEFFS(FITTYPE) returns the array of indices of 
%   nonlinear coefficients of FITTYPE.
%
%   See also FITTYPE/COEFF.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.2.2.1 $  $Date: 2004/02/01 21:41:52 $

cella = model.nonlinearcoeffs;
