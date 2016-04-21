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
## @deftypefn {Function File} {} rleenco (@var{message})
##
## Returns  run-length encoded @var{message}. The
## rle form is built from @var{message}. The original @var{message}
## has to be in the form of a  row-vector. The encoded @var{message}
## format (encoded RLE) is like  [repetition factor]+, values.
##
## An example use of @code{rleenco} is
## @example
## @group
##          message=[    5   4   4   1   1   1]
##          rleenco(message) #gives
##          ans = [1 5 2 4 3 1];
## @end group
## @end example
## @end deftypefn
## @seealso{rleenco}

function rmsg=rleenco(message)
     if nargin < 1
       error('Usage: rleenco(message)')
     end
     rmsg=[];
     L=length(message);
     itr=1;
     while itr <= L
       times=0;
       val=message(itr);
       while(itr <= L && message(itr)==val)
	 itr=itr+1;
	 times=times+1;
       end
       rmsg=[rmsg times val];
     end
     return
end
%!
%!assert( rleenco([5 4 4 1 1 1]),[1 5 2 4 3 1])
%!
