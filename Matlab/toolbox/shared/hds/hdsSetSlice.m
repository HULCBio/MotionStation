function A = hdsSetSlice(A,Section,B)
%HDSSETSLICE  Modifies array slice.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:59 $
A(Section{:}) = B;