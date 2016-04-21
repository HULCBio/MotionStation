function num = numargs(model)
%NUMARGS Number of argument.
%   NUMARGS(FITTYPE) returns the number of arguments of FITTYPE.
%   
%
%   See also FITTYPE/ARGNAMES.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:41:53 $

num = model.numArgs;
