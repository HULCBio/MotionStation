function empty = isempty(x)
%ISEMPTY True for empty Galois arrays.
%
%   ISEMPTY(X) returns 1 (true) if the Galois array X has 
%   no data elements and 0 otherwise.  An empty Galois array is one where
%   prod(size(X))==0.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.1 $  $Date: 2002/01/04 19:04:09 $ 

empty = isempty(x.x);