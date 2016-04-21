## Copyright (C) 2011, 2012 Carlo de Falco
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##
## @deftypefn {Function File} {@var{data}} = bim2c_intrp (@var{msh}, @var{n_data}, @var{e_data}, @var{points}) 
##
## Compute interpolated values of node centered multicomponent node centered field @var{n_data} and 
## cell centered field @var{n_data} at an arbitrary set of points whos coordinates are given in the 
## n_by_2 matrix  @var{points}. 
##
## @end deftypefn


## Author: Carlo de Falco <carlo@guglielmo.local>
## Created: 2012-10-01

function data = bim2c_intrp (msh, n_data, e_data, p)

  %% for each point, find the enclosing tetrahedron
  [t_list, b_list] = tsearchn (msh.p.', msh.t(1:3, :)', p);
    
  %% only keep points within tetrahedra
  invalid = isnan (t_list);
  t_list = t_list (! invalid);
  ntl = numel (t_list);
  b_list = b_list(! invalid, :);
  points(invalid,:) = [];

  data = [];
  if (! isempty (n_data))
    data = cat (1, data, squeeze (
                sum (reshape (n_data(msh.t(1:3, t_list), :),
                              [3, ntl, (columns (n_data))]) .* 
                     repmat (b_list.', [1, 1, (columns (n_data))]), 1)));
  endif

  if (! isempty (e_data))
    data = cat (1, data, e_data(t_list, :));
  endif

endfunction

%!test
%! msh = bim2c_mesh_properties (msh2m_structured_mesh (linspace (0, 1, 11), linspace (0, 1, 13), 1, 1:4));
%! x = y = linspace (0, 1, 100).';
%! u = msh.p(1, :).';
%! ui = bim2c_intrp (msh, u, [], [x, y]); 
%! assert (ui, linspace (0, 1, 100), 10*eps);