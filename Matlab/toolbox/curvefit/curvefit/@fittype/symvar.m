function vars = symvar(s)
%SYMVAR Determine the symbolic variables for an FITTYPE.
%   SYMVAR returns the variables for the FITTYPE object.
%
%   See also ARGNAMES.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:43:00 $

vars = argnames(s);
