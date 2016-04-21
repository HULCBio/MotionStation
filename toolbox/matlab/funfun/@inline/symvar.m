function vars = symvar(s)
%SYMVAR Determine the symbolic variables for an INLINE.
%   SYMVAR returns the variables for the INLINE object.
%
%   See also ARGNAMES.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/15 04:21:29 $

vars = argnames(s);
