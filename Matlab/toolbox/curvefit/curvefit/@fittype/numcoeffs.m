function num = numcoeffs(model)
%NUMCOEFFS Number of coefficients.
%   NUMCOEFFS(FITTYPE) returns the number of coefficients of FITTYPE.
%   
%
%   See also FITTYPE/COEFF.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.2.2.1 $  $Date: 2004/02/01 21:41:54 $

num = size(model.coeff,1);
