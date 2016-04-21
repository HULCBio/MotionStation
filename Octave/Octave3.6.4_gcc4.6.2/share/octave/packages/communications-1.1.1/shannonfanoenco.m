## Copyright (C) 2006 Muthiah Annamalai <muthiah.annamalai@uta.edu>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} shannonfanoenco (@var{hcode},@var{dict})
## 
## Returns the Shannon Fano encoded signal using @var{dict}.
## This function uses a @var{dict} built from the @code{shannonfanodict}
## and uses it to encode a signal list into a shannon fano code.
## Restrictions include a signal set that strictly belongs  in the
## @code{range [1,N]} with @code{N=length(dict)}. Also dict can only be
## from the @code{shannonfanodict()} routine.
## An example use of @code{shannonfanoenco} is
##
## @example
## @group
##          hd=shannonfanodict(1:4,[0.5 0.25 0.15 0.10])
##          shannonfanoenco(1:4,hd) #  [   0   1   0   1   1   0   1   1   1   0]
## @end group
## @end example
## @end deftypefn
## @seealso{shannonfanodeco, shannonfanodict}
##

function sf_code=shannonfanoenco(sig,dict)
  if nargin < 2
    error('usage: huffmanenco(sig,dict)');
  end
  if (max(sig) > length(dict)) || ( min(sig) < 1)
    error("signal has elements that are outside alphabet set ...
	Cannot encode.");
  end
  sf_code=[dict{sig}];
  return
end
%! 
%! assert(shannonfanoenco(1:4, shannonfanodict(1:4,[0.5 0.25 0.15 0.10])),[   0   1   0   1   1   0   1   1   1   0],0)
%!
