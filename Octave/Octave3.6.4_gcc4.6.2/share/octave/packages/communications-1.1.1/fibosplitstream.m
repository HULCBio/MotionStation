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
## @deftypefn {Function File} { } fibosplitstream (@var{code})
##
## Returns the split data stream at the word boundaries.
## Assuming the stream was originally encoded using @code{fiboenco}
## and this routine splits the stream at the points where '11'
## occur together & gives us the code-words which
## can later be decoded from the @code{fibodeco} This however doesnt
## mean that we intend to verify if all the codewords are correct,
## and infact the last symbol in th return list can or can-not be
## a valid codeword.
##
## A example use of @code{fibosplitstream} would be
## @example
## @group
##
## fibodeco(fibosplitstream([fiboenco(randint(1,100,[0 255]))@{:@}]))
## fibodeco(fibosplitstream([fiboenco(1:10)@{:@}]))
##
## @end group
## @end example
## @seealso{fiboenco,fibodeco}
## @end deftypefn

function symbols=fibosplitstream(stream)
  if nargin < 1
     error('usage: fibosplitstream(stream); see help')
  end

  symbols={};
  itr=1;
  L=length(stream);

  %
  % Plain & Simple Algorithm. O(N)
  % Walk till marker '11' or find it.
  % Then split & save. A little tricky to
  % handle the edge case_ without tripping over.
  %
  idx=[];
  mark=1;
  prev_bit=stream(1);
  just_decoded=0;

  for i=2:L
    if(~just_decoded && (stream(i)+prev_bit)==2 )
	symbols{itr}=[stream(mark:i)];
	mark=i+1;
	prev_bit=0;
	just_decoded=1;
	itr=itr+1;
    else
      prev_bit=stream(i);
      just_decoded=0;
    end
    
  end
  if(mark < L)
    symbols{itr}=stream(mark:end);
  end
  
  return
end
%!
%!assert(fibodeco(fibosplitstream([fiboenco(1:10){:}])),[1:10])
%!
