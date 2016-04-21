## Copyright (C) 2007 Gorka Lertxundi
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
## @deftypefn {Function File} {@var{m} =} lz77deco (@var{c}, @var{alph}, @var{la}, @var{n})
## Lempel-Ziv 77 source algorithm decoding implementation. Where
##
## @table @asis
## @item @var{m}
## message decoded (1xN).
## @item @var{c}
## encoded message (Mx3).
## @item @var{alph}
## size of alphabet.
## @item @var{la}
## lookahead buffer size.
## @item @var{n}
## sliding window buffer size.
## @end table
## @seealso{lz77enco}
## @end deftypefn

function m = lz77deco(c, alph, la, n)
  if (la <= 0 || n <= 0)
    error("lz77deco: Lookahead buffer size and window size must be higher than 0.");
  endif
  if n - la < la
    error("lz77deco: Unreachable configuration: n - la >= la.");
  endif
  if alph < 2
    error("lz77deco: Alphabet size within less than 2 symbols? Is that possible?.");
  endif
  if columns(c) != 3
    error("lz77deco: Encoded message must be a Nx3 matrix.");
  endif

  window = zeros(1,n);
  x = length(c);
  len = length(c);

  for x=1:len
    ## update window
    temp = n-la+c(x,2)-c(x,1);
    for y=1:temp
      window(n-la+y) = window(c(x,1)+y);
    endfor
    window(n-la+c(x,2)+1) = c(x,3);
	
    ## decoded message
    m_deco = window(n-la+1:n-la+c(x,2)+1);
    if x == 1
      m = m_deco;
    else
      m = [m m_deco];
    endif
	
    ## CCW shift
    temp = c(x,2)+1;
    window(1:n-la) = window(temp+1:n-la+temp);
  endfor

endfunction

%!demo
%! lz77deco([8 2 1 ; 7 3 2 ; 6 7 2 ; 2 8 0],3,9,18)
