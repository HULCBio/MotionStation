%SUBSINDEX Subscript index.
%   I = SUBSINDEX(A) is called for the syntax 'X(A)' when A is an
%   object and X is one of the built-in types (most commonly
%   'double').  SUBSINDEX must return the value of the object as a
%   zero-based integer index (I must contain integer values in the
%   range 0 to prod(size(X))-1).  SUBSINDEX is called by the default
%   SUBSREF and SUBSASGN functions and you may call it yourself if you
%   overload these functions.
%
%   SUBSINDEX is invoked separately on all the subscripts in an
%   expression such as X(A,B). 
%
%   See also SUBSREF, SUBSASGN.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/15 04:10:19 $
