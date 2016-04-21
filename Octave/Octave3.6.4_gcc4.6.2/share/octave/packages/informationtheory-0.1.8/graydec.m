## Copyright (C) 2008 Muthiah Annamalai <muthiah.annamalai@uta.edu>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.
##

## -*- texinfo -*-
## @deftypefn {Function File} {}  graydec (@var{p})
##
## Decodes the binary gray code @var{p} to the original
## binary code.
## 
## @end deftypefn
## @seealso{grayenc}

function v_c=graydec(v_a)

  if ( nargin < 1 )
    print_usage();
  end

  L=length(v_a);
  v_c=zeros(1,L);
  v_c(1)=v_a(1);

  for x=2:L
    v_c(x)=xor(v_a(x),v_c(x-1));
  end

  return;

end
%!assert(graydec([0 1 0]),[0 1 1])
