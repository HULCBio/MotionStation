function flag = islinear(model)
%ISLINEAR Returns 1 for linear models and 0 for nonlinear.
%
%   See also FITTYPE.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.2.2.1 $  $Date: 2004/02/01 21:41:44 $

flag = model.linear;
