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
## @deftypefn {Function File} {[@var{varargout}]} = @
## msh3m_geometrical_properties(@var{mesh},[@var{string1},@var{string2},...])
## 
##
## Compute @var{mesh} geometrical properties identified by input strings.
##
## Valid properties are:
## @itemize @bullet
## @item @code{"wjacdet"}: return the weigthed Jacobian determinant used
## for the numerical integration with trapezoidal rule over an element.
## @item @code{"shg"}: return a matrix of size 3 times the number of
## elements matrix containing the gradient of P1 shape functions.
## @item @code{"shp"}: return a matrix containing the the value of P1 shape
## functions. 
## @end itemize
##
## The output will contain the geometrical properties requested in the
## input in the same order specified in the function call.
##
## If an unexpected string is given as input, an empty vector is
## returned in output.
##
## @seealso{msh2m_topological_properties, msh2m_geometrical_properties}
## @end deftypefn


function [varargout] = msh3m_geometrical_properties(imesh,varargin)

  ## Check input
  if nargin < 2 # Number of input parameters
    error("msh3m_geometrical_properties: wrong number of input parameters.");
  elseif !(isstruct(imesh)    && isfield(imesh,"p") &&
	   isfield(imesh,"t") && isfield(imesh,"e"))
    error("msh3m_geometrical_properties: first input is not a valid mesh structure.");
  elseif !iscellstr(varargin)
    error("msh3m_geometrical_properties: only string value admitted for properties.");
  endif
  
  ## Compute properties

  ## Extract tetrahedra node coordinates
  x1 = imesh.p(1,imesh.t(1,:));
  y1 = imesh.p(2,imesh.t(1,:));
  z1 = imesh.p(3,imesh.t(1,:));
  x2 = imesh.p(1,imesh.t(2,:));
  y2 = imesh.p(2,imesh.t(2,:));
  z2 = imesh.p(3,imesh.t(2,:));
  x3 = imesh.p(1,imesh.t(3,:));
  y3 = imesh.p(2,imesh.t(3,:));
  z3 = imesh.p(3,imesh.t(3,:));
  x4 = imesh.p(1,imesh.t(4,:));
  y4 = imesh.p(2,imesh.t(4,:));
  z4 = imesh.p(3,imesh.t(4,:));

  for nn = 1:length(varargin)
    
    request = varargin{nn};
    switch request
      case "wjacdet" # Weighted Jacobian determinant
	b = wjacdet(x1,y1,z1,\
		    x2,y2,z2,\
		    x3,y3,z3,\
		    x4,y4,z4);
	varargout{nn} = b;
        clear b
      case "area" # Element area
	tmp = wjacdet(x1,y1,z1,\
		      x2,y2,z2,\
		      x3,y3,z3,\
		      x4,y4,z4);
	b   = sum(tmp,1);
	varargout{nn} = b;
      case "shg" # Gradient of shape functions
	b = shg(x1,y1,z1,\
		x2,y2,z2,\
		x3,y3,z3,\
		x4,y4,z4);
	varargout{nn} = b;
        clear b
      case "shp" # Value of shape functions
	varargout{nn} = eye(4);
      otherwise
	warning("msh3m_geometrical_properties: unexpected value in property string. Empty vector passed as output.")
	varargout{nn} = [];
    endswitch
    
  endfor

endfunction

function [b] = wjacdet(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4)
  
  ## Compute weighted yacobian determinant
  
  weight = [1/4 1/4 1/4 1/4]';

  Nb2 = y1.*(z3-z4) + y3.*(z4-z1) + y4.*(z1-z3);
  Nb3 = y1.*(z4-z2) + y2.*(z1-z4) + y4.*(z2-z1);
  Nb4 = y1.*(z2-z3) + y2.*(z3-z1) + y3.*(z1-z2);
  
  ## Determinant of the Jacobian of the 
  ## transformation from the base tetrahedron
  ## to the tetrahedron K  
  detJ = (x2-x1).*Nb2 +(x3-x1).*Nb3 +(x4-x1).*Nb4;
  ## Volume of the reference tetrahedron
  Kkvolume = 1/6;
  
  b(:,:) = Kkvolume * weight * detJ;
  
endfunction

function [b] = shg(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4)

  ## Compute gradient of shape functions

  Nb2 = y1.*(z3-z4) + y3.*(z4-z1) + y4.*(z1-z3);
  Nb3 = y1.*(z4-z2) + y2.*(z1-z4) + y4.*(z2-z1);
  Nb4 = y1.*(z2-z3) + y2.*(z3-z1) + y3.*(z1-z2);
  
  ## Determinant of the Jacobian of the 
  ## transformation from the base tetrahedron
  ## to the tetrahedron K  
  detJ = (x2-x1).*Nb2 +(x3-x1).*Nb3 +(x4-x1).*Nb4;
 
  ## Shape  function gradients follow
  ## First  index represents space direction
  ## Second index represents the shape function
  ## Third  index represents the tetrahedron number
  b(1,1,:) = (y2.*(z4-z3) + y3.*(z2-z4) + y4.*(z3-z2))./ detJ;
  b(2,1,:) = (x2.*(z3-z4) + x3.*(z4-z2) + x4.*(z2-z3))./ detJ;
  b(3,1,:) = (x2.*(y4-y3) + x3.*(y2-y4) + x4.*(y3-y2))./ detJ;
  
  b(1,2,:) = ( Nb2 ) ./ detJ;
  b(2,2,:) = (x1.*(z4-z3) + x3.*(z1-z4) + x4.*(z3-z1)) ./ detJ;
  b(3,2,:) = (x1.*(y3-y4) + x3.*(y4-y1) + x4.*(y1-y3)) ./ detJ;
  
  b(1,3,:) = ( Nb3 ) ./ detJ;
  b(2,3,:) = (x1.*(z2-z4) + x2.*(z4-z1) + x4.*(z1-z2)) ./ detJ;
  b(3,3,:) = (x1.*(y4-y2) + x2.*(y1-y4) + x4.*(y2-y1)) ./ detJ;
  
  b(1,4,:) = ( Nb4) ./ detJ;
  b(2,4,:) = (x1.*(z3-z2) + x2.*(z1-z3) + x3.*(z2-z1)) ./ detJ;
  b(3,4,:) = (x1.*(y2-y3) + x2.*(y3-y1) + x3.*(y1-y2)) ./ detJ;
endfunction

%!shared mesh,wjacdet,shg,shp
% x = y = z = linspace(0,1,2);
% [mesh] = msh3m_structured_mesh(x,y,z,1,1:6)
% [wjacdet] =  msh3m_geometrical_properties(mesh,"wjacdet")
% [shg] =  msh3m_geometrical_properties(mesh,"shg")
% [shp] =  msh3m_geometrical_properties(mesh,"shp")
%!test
% assert(columns(mesh.t),columns(wjacdet))
%!test
% assert(size(shg),[3 4 6])
%!test
% assert(shp,eye(4))
%!test
% fail(msh3m_geometrical_properties(mesh,"samanafattababbudoiu"),"warning","Unexpected value in passed string. Empty vector passed as output.")