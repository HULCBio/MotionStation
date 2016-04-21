## Copyright (C) 2006,2007,2008,2009,2010  Carlo de Falco, Massimiliano Culpo
##
## This file is part of:
##     MSH - Meshing Software Package for Octave
##
##  MSH is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  MSH is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with MSH; If not, see <http://www.gnu.org/licenses/>.
##
##  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>
##  author: Massimiliano Culpo <culpo _AT_ users.sourceforge.net>

## -*- texinfo -*-
## @deftypefn {Function File} msh2p_mesh(@var{mesh}, @var{linespec})
##
## Plot @var{mesh} with the line specification in @var{linespec} using
## @code{triplot}.
##
## @seealso{triplot}
##
## @end deftypefn

function msh2p_mesh(mesh,linespec)

  ## Check input
  if nargin > 2
    error("msh2p_mesh: wrong number of input parameters.");
  elseif !(isstruct(mesh)     && isfield(mesh,"p") &&
	   isfield (mesh,"t") && isfield(mesh,"e"))
    error("msh2p_mesh: first input is not a valid mesh structure.");
  endif

  tri = mesh.t(1:3,:)';
  x   = mesh.p(1,:)';
  y   = mesh.p(2,:)';
  
  if ~exist("linespec")
    linespec = "r";
  endif

  triplot(tri,x,y,linespec);
  
endfunction