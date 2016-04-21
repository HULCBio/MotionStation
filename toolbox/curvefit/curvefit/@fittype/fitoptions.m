function fitoptions = fitoptions(fun)
%FITOPTIONS Get FitOptions field of the fittype.
%   FITOPTIONS(FUN) returns the FitOptions of the FITTYPE object FUN.
%
%   See also FITTYPE/FORMULA.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:41:36 $

if isempty(fun.fitoptions)
   fitoptions = {};
else
   fitoptions = copy(fun.fitoptions);
end
