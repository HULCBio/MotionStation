## Copyright (C) 2004 Josep Mones i Teixidor <jmones@puntbarra.com>
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
## @deftypefn {Function File} {@var{conn} = } conndef (@var{num_dims}, @var{type})
## Creates a connectivity array.
##
## @code{conn=conndef(num_dims,type)} creates a connectivity array
## (@var{CONN}) of @var{num_dims} dimensions and which type is defined
## by @var{type} as follows:
## @table @code
## @item minimal
## Neighbours touch the central element on a (@var{num_dims}-1)-dimensional
## surface.
## @item maximal
## Neighbours touch the central element in any way. Equivalent to
## @code{ones(repmat(3,1,@var{num_dims}))}.
## @end table
##
## @seealso{iptcheckconn}
## @end deftypefn

function conn = conndef (num_dims, conntype)

  if (nargin!=2)
    print_usage;
  elseif (!isnumeric (num_dims) || !isscalar (num_dims) || num_dims <= 0 || fix (num_dims) != num_dims)
    error ("number of dimensions must be a positive integer.");
  elseif (!ischar (conntype))
    error ("second argument must be a string with type of connectivity.")
  endif

  ## support for 1 dimension does not exist in Matlab where num_dims must be >= 2
  if (num_dims == 1)
    conn = [1; 1; 1];
  ## matlab is case insensitive when checking the type
  elseif (strcmpi (conntype, "minimal"))
    if (num_dims == 2)
      conn = [0 1 0
              1 1 1
              0 1 0];
    else
      conn   = zeros (repmat (3, 1, num_dims));
      idx    = {};
      idx{1} = 1:3;
      for i = 2:num_dims
        idx{i} = 2;
      endfor
      conn(idx{:}) = 1;
      for i = 2:num_dims
        idx{i-1}     = 2;
        idx{i}       = 1:3;
        conn(idx{:}) = 1;
      endfor
    endif

  elseif (strcmpi (conntype, "maximal"))
    conn = ones (repmat (3, 1, num_dims));
  else
    error("invalid type of connectivity '%s'.", conntype);
  endif

endfunction

%!demo
%! conndef(2,'minimal')
%! % Create a 2-D minimal connectivity array

%!assert(conndef(1,'minimal'), [1;1;1]);
%!assert(conndef(2,'minimal'), [0,1,0;1,1,1;0,1,0]);

%!test
%! C=zeros(3,3);
%! C(2,2,1)=1;
%! C(2,2,3)=1;
%! C(:,:,2)=[0,1,0;1,1,1;0,1,0];
%! assert(conndef(3,'minimal'), C);

%!assert(conndef(1,'maximal'), ones(3,1));
%!assert(conndef(2,'maximal'), ones(3,3));
%!assert(conndef(3,'maximal'), ones(3,3,3));
%!assert(conndef(4,'maximal'), ones(3,3,3,3));
