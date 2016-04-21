function cella = linearterms(model)
%LINEARTERMS Cell array of linear terms to form linear coefficient matrix.
%   LINEARTERMS(FITTYPE) returns the cellarray of linear terms of FITTYPE.
%
%   See also FITTYPE/COEFF.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.3.2.1 $  $Date: 2004/02/01 21:41:48 $

cella = model.Adefn;
