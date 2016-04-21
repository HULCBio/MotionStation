function n = ndims(sys)
%NDIMS  Number of dimensions for LTI objects.
%
%   N = NDIMS(SYS) returns the number of dimensions of
%   the LTI model SYS.  A single LTI model has two 
%   dimensions (outputs and inputs).  An array of LTI 
%   models has 2+p dimensions, where p>=2 is the number
%   of array dimensions.  For example, a 2-by-3-by-4
%   array of models has 2+3=5 dimensions.
%
%   See also SIZE.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 05:49:20 $

n = length(size(sys));