### Copyright (c) 2007, Tyzx Corporation. All rights reserved.

## c = csplice (c,p,l,c2) - Splice a cell (p starts at 0)
##
## TODO: Make p start at 1, check code that uses csplice
## Author <etienne@tyzx.com>
function c = csplice (c,p,l,c2)

N = length (c);
if p < 0, p = N + p + 1; end

if nargin == 3
  c2 = l;
  l = N - p + 1;
end
if nargin == 2
  c2 = {};
  l = N - p + 1;
end

if l < 0, l = N + l; end

c = {c{1:p},c2{:},c{p+l+1:length(c)}};
end
