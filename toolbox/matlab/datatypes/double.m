%DOUBLE Convert to double precision.
%   DOUBLE(X) returns the double precision value for X.
%   If X is already a double precision array, DOUBLE has
%   no effect.
%
%   DOUBLE is called for the expressions in FOR, IF, and WHILE loops
%   if the expression isn't already double precision.  DOUBLE should
%   be overloaded for all objects where it makes sense to convert it
%   into a double precision value.
%
%   See also SINGLE, DATATYPES, ISFLOAT, ISNUMERIC.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.2 $ $Date: 2004/03/08 02:01:31 $
