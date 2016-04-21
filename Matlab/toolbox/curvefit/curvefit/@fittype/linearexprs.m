function cella = linearexprs(model)
%LINEAREXPRS Vectorized expressions for linear coefficient matrix.
%   LINEAREXPRS(FITTYPE) returns the cell array of linear terms of FITTYPE after
%   they have been "vectorized".
%
%   See also FITTYPE/COEFF.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.2.2.1 $  $Date: 2004/02/01 21:41:47 $

cella = model.Aexpr;
