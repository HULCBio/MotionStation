function s = sumsqr(a)
%SUMSQR Sum squared elements of a matrix.
%
%  Synopsis
%
%    sumsqr(m)
%
%  Description
%
%    SUMSQR(M) returns the sum of the squared elements in M.
%
%  Examples
%
%    s = sumsqr([1 2;3 4])

% Mark Beale, 1-31-92
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 2002/04/14 21:36:05 $

if nargin < 1,error('Not enough input arguments.');end

s = sum(sum(a.*a));
