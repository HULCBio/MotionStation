## Copyright (C) 2003 David Bateman
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
## @deftypefn {Function File} {@var{par} =} gen2par (@var{gen})
## @deftypefnx {Function File} {@var{gen} =} gen2par (@var{par})
##
## Converts binary generator matrix @var{gen} to the parity chack matrix
## @var{par} and visa-versa. The input matrix must be in standard form.
## That is a generator matrix must be k-by-n and in the form [eye(k) P]
## or [P eye(k)], and the parity matrix must be (n-k)-by-n and of the
## form [eye(n-k) P'] or [P' eye(n-k)].
##
## @end deftypefn
## @seealso{cyclgen,hammgen}

function par = gen2par (gen)

  if (nargin != 1)
    usage (" par = gen2par (gen)");
  endif

  [gr, gc] = size(gen);

  if (gr > gc)
    error ("gen2par: input matrix must be in standard form");
  endif

  ## Identify where is the identity matrix
  if (isequal(gen(:,1:gr),eye(gr)))
    par = [gen(:,gr+1:gc)', eye(gc-gr)];
  elseif (isequal(gen(:,gc-gr+1:gc),eye(gr)))
    par = [eye(gc-gr), gen(:,1:gc-gr)'];
  else
    error ("gen2par: input matrix must be in standard form");
  endif

endfunction
