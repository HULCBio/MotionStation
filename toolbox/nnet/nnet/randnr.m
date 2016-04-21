function w = randnr(s,pr)
%RANDNR Normalized row weight initialization function.
%
%  Syntax
%
%     W = randnr(S,PR)
%     W = randnr(S,R)
%
%  Description
%
%    RANDNR is a weight initialization function.
%
%    RANDNR(S,P) takes these inputs,
%      S  - Number of rows (neurons).
%      PR - Rx2 matrix of input value ranges = [Pmin Pmax].
%    and returns an SxR random matrix with normalized rows.
%  
%    Can also be called as RANDNR(S,R).
%  
%  See also RANDNC.

% Mark Beale, 1-31-92
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 2002/04/14 21:31:44 $

if nargin ~= 2, error('Wrong number of arguments.'); end

if size(pr,2) == 1
  r = pr;
else
  r = size(pr,1);
end
w = normr(rands(s,r));
