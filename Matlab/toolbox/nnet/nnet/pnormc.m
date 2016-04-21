function n=pnormc(m,r)
%PNORMC Pseudo-normalize columns of a matrix.
%
%  Syntax
%
%    pnormc(x,r)
%
%  Description
%  
%    PNORMC(M,R) takes these arguments,
%      X - MxN matrix.
%      R - (optional) radius to normalize columns to, default = 1.
%    returns X with an additional row of elements which results
%      in new column vector lengths of R.
%  
%    WARNING: For this function to work properly, the columns of X must
%      originally have vector lengths less than R.
%
%  Examples
%
%    x = [0.1 0.6; 0.3 0.1];
%    y = pnormc(x)
%  
%  See also NORMC, NORMR.

% Mark Beale, 1-31-92
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 2002/04/14 21:31:14 $

if nargin < 1,error('Not enough input arguments.'); end

if nargin == 1
  r = 1;
end

[mr mc] = size(m);
if mr == 1
  n = [m sqrt(r.*r-m.*m)];
else
  n = [m; sqrt(r.*r-sum(m.*m))];
end
