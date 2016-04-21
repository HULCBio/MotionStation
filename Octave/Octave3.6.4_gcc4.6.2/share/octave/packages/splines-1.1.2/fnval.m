## Author: Paul Kienzle <pkienzle@users.sf.net>
## This program is granted to the public domain.

## r = fnval(pp,x) or r = fnval(x,pp)
## Compute the value of the piece-wise polynomial pp at points x.

function r = fnval(a,b,left)
  if nargin == 2 || (nargin == 3 && left == 'l' && left == 'r')
    # XXX FIXME XXX ignoring left continuous vs. right continuous option
    if isstruct(a), r=ppval(a,b); else r=ppval(b,a); end
  else
    print_usage;
  end
end

