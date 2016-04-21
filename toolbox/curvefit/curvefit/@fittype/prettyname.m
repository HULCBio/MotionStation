function type = prettyname(fittype)
%PRETTYNAME Typename of FITTYPE.
%   PRETTYNAME(F) returns the nicely formatted name of the 
%   FITTYPE object F.
%
%   See also FITTYPE/ARGNAMES, FITTYPE/CHAR.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.5.2.1 $  $Date: 2004/02/01 21:41:55 $

type = fittype.typename;
