function w = randnc(s,pr)
%RANDNC Normalized column weight initialization function.
%
%  Syntax
%
%     W = randnc(S,PR)
%     W = randnc(S,R)
%
%  Description
%
%    RANDNC is a weight initialization function.
%
%    RANDNC(S,P) takes these inputs,
%      S  - Number of rows (neurons).
%      PR - Rx2 matrix of input value ranges = [Pmin Pmax].
%    and returns an SxR random matrix with normalized columns.
%  
%    Can also be called as RANDNC(S,R).
%  
%  See also RANDNR.

% Mark Beale, 1-31-92
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 2002/04/14 21:34:23 $

if nargin ~= 2, error('Wrong number of arguments.'); end

if size(pr,2) == 1
  r = pr;
else
  r = size(pr,1);
end
w = normc(2*rand(s,r)-1);
