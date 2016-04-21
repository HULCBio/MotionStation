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
## @deftypefn {Function File} {@var{u_nod}} = bim3c_tri_to_nodes (@var{mesh}, @var{u_tri}) 
## @deftypefnx {Function File} {@var{u_nod}} = bim3c_tri_to_nodes (@var{m_tri}, @var{u_tri}) 
## @deftypefnx {Function File} {[@var{u_nod}, @var{m_tri}]} = bim3c_tri_to_nodes ( ... ) 
##
## Compute interpolated values at triangle nodes @var{u_nod} given values at tetrahedral centers of mass @var{u_tri}.
## If called with more than one output, also return the interpolation matrix @var{m_tri} such that
## @code{u_nod = m_tri * u_tri}.
## If repeatedly performing interpolation on the same mesh the matrix @var{m_tri} obtained by a previous call 
## to @code{bim2c_tri_to_nodes} may be passed as input to avoid unnecessary computations.
##
## @end deftypefn


## Author: Carlo de Falco <carlo@guglielmo.local>
## Created: 2011-03-07

function [u_nod, m_tri] = bim3c_tri_to_nodes (m, u_tri)

  if (nargout >1)
    if (isstruct (m))
      nel  = columns (m.t);
      nnod = columns (m.p);
      ii = m.t(1:4, :);
      jj = repmat (1:nel, 4, 1);
      vv = repmat (m.area(:)', 4, 1) / 4;
      m_tri = bim3a_reaction (m, 1, 1) \ sparse (ii, jj, vv, nnod, nel);     
    elseif (ismatrix (m))
      m_tri = m;
    else
      error ("bim3c_tri_to_nodes: first input parameter is of incorrect type");
    endif
    u_nod = m_tri * u_tri;
  else
    rhs  = bim3a_rhs (m, u_tri, 1);
    mass = bim3a_reaction (m, 1, 1);
    u_nod = full (mass \ rhs);
  endif


endfunction

%!test
%! msh = bim3c_mesh_properties (msh3m_structured_mesh (linspace (0, 1, 31), linspace (0, 1, 13), linspace (0, 1, 13), 1, 1:6));
%! nel  = columns (msh.t);
%! nnod = columns (msh.p);
%! u_tri = randn (nel, 1);
%! un1 = bim3c_tri_to_nodes (msh, u_tri);
%! [un2, m] = bim3c_tri_to_nodes (msh, u_tri);
%! assert (un1, un2, 1e-10)
