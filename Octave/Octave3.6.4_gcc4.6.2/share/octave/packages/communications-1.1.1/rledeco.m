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
## @deftypefn {Function File} {} rledeco (@var{message})
##
## Returns decoded run-length @var{message}. 
## The RLE encoded @var{message} has to be in the form of a 
## row-vector. The message format (encoded RLE) is like  repetition 
## [factor, value]+.
##
## An example use of @code{rledeco} is
## @example
## @group
##          message=[1 5 2 4 3 1];
##          rledeco(message) #gives
##          ans = [    5   4   4   1   1   1]
## @end group
## @end example
## @end deftypefn
## @seealso{rledeco}

function rmsg=rledeco(message)
     if nargin < 1
       error('Usage: rledeco(message)')
     end
     rmsg=[];
     L=length(message);
     itr=1;
     while itr < L
       times=message(itr);
       val=message(itr+1);
       rmsg=[rmsg val*(ones(1,times))];
       itr=itr+2;
     end
     return
end
%!
%!assert( rledeco([1 5 2 4 3 1]),[5 4 4 1 1 1])
%!
