function str = char(obj)
%CHAR Convert FITTYPE object to character array.
%   CHAR(FUN) returns the formula for the FITTYPE object FUN.
%   This is the same as FORMULA(FUN).
%
%   See also FITTYPE, FITTYPE/FORMULA.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.5.2.1 $  $Date: 2004/02/01 21:41:25 $

str = obj.defn;
