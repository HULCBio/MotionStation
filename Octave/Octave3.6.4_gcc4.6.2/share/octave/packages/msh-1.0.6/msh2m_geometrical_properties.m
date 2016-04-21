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
## msh2m_geometrical_properties(@var{mesh},[@var{string1},@var{string2},...])
##
## Compute @var{mesh} geometrical properties identified by input strings.
##
## Valid properties are:
## @itemize @bullet
## @item @code{"bar"}: return a matrix with size 2 times the number of mesh
## elements containing the center of mass coordinates. 
## @item @code{"cir"}: return a matrix with size 2 times the number of
## mesh elements containing the circumcenter coordinates.
## @item @code{"emidp"}: return a matrix with size 2 times the number of
## side edges containing their midpoint coordinates.
## @item @code{"slength"}: return a matrix with size 3 times the number
## of mesh elements containing the length of each element side.
## @item @code{"cdist"}: return a matrix of size 3 times the number of
## mesh elements containing  the distance among circumcenters of
## neighbouring elements. If the corresponding side lies on the edge,
## the distance between circumcenter and border edge is returned in the
## matrix.
## @item @code{"wjacdet"}: return the weigthed Jacobian determinant used
## for the numerical integration with trapezoidal rule over an element.
## @item @code{"shg"}: return a matrix of size 3 times the number of
## elements matrix containing the gradient of P1 shape functions.
## @item @code{"area"}: return a row vector containing the area of every
## element.
## @item @code{"midedge"}: return a multi-dimensional array with size 2
## times 3 times the number of elements containing the coordinates of
## the midpoint of every edge. 
## @end itemize 
##
## The output will contain the geometrical properties requested in the
## input in the same order specified in the function call.
##
## If an unexpected string is given as input, an empty vector is
## returned in output.
##
## @seealso{msh2m_topological_properties, msh3m_geometrical_properties}
## @end deftypefn

function [varargout] = msh2m_geometrical_properties(mesh,varargin)

  ## Check input
  if nargin < 2 # Number of input parameters
    error("msh2m_geometrical_properties: wrong number of input parameters.");
  elseif !(isstruct(mesh)    && isfield(mesh,"p") &&
	   isfield(mesh,"t") && isfield(mesh,"e"))
    error("msh2m_geometrical_properties: first input is not a valid mesh structure.");
  elseif !iscellstr(varargin)
    error("msh2m_geometrical_properties: only string value admitted for properties.");
  endif
  
  ## Compute properties
  p = mesh.p;
  e = mesh.e;
  t = mesh.t;
  nelem = columns(t); # Number of elements in the mesh
  
  [k,j,w] = coeflines(p,t,nelem); # Edges coefficients

  for nn = 1:length(varargin)
    
    request = varargin{nn};
    switch request
	
      case "bar" # Center of mass coordinates
	if isfield(mesh,"bar")
          varargout{nn} = mesh.bar;
	else
          [b] = coordinates(p,t,nelem,j,w,k,"bar");
          varargout{nn} = b;
          clear b;
	endif
	
      case "cir" # Circum center coordinates
	if isfield(mesh,"cir")
          varargout{nn} = mesh.cir;
	else
          [b] = coordinates(p,t,nelem,j,w,k,"cir");
          varargout{nn} = b;
          clear b;
	endif

      case "emidp" # Boundary edges midpoint coordinates
	if isfield(mesh,"emidp")
          varargout{nn} = mesh.emidp;
	else
          [b] = midpoint(p,e);
          varargout{nn} = b;
          clear b;
	endif

      case "slength" # Length of every side
	if isfield(mesh,"slength")
          varargout{nn} = mesh.slength;
	else
          [b] = sidelength(p,t,nelem);
          varargout{nn} = b;
          clear b;
	endif

      case "cdist" # Distance among circumcenters of neighbouring elements
	if isfield(mesh,"cdist")
          varargout{nn} = mesh.cdist;
	else

          if isfield(mesh,"cir")
            cir = mesh.cir;
          else
            [cir] = coordinates(p,t,nelem,j,w,k,"cir");
          endif

          if isfield(mesh,"n")
            n = mesh.n;
          else      
            [n] = msh2m_topological_properties(mesh,"n");
          endif

          [b] = distance(cir,n,nelem);
          [semib] = semidistance(cir,nelem,j,w,k);
          border = isnan(n);
          [index1] = find( border(1,:) );
          [index2] = find( border(2,:) );
          [index3] = find( border(3,:) );
          b(1,index1) = semib(1,index1);
          b(2,index2) = semib(2,index2);
          b(3,index3) = semib(3,index3);
          varargout{nn} = b;
          clear b semib index1 index2 index3 border;
	endif

      case "wjacdet" # Weighted Jacobian determinant
	if isfield(mesh,"wjacdet")
          varargout{nn} = mesh.wjacdet;
	else
          [b] = computearea(p,e,t,"wjac");
          varargout{nn} = b;
          clear b
	endif
	
      case "area" # Area of the elements
	if isfield(mesh,"area")
          varargout{nn} = mesh.area;
	else
          [b] = computearea(p,e,t,"area");
          varargout{nn} = b;
          clear b
	endif
	
      case "shg" # Gradient of hat functions
	if isfield(mesh,"shg")
          varargout{nn} = mesh.shg;
	else
          [b] = shapegrad(p,t);
          varargout{nn} = b;
          clear b
	endif

      case "midedge" # Mid-edge coordinates
	if isfield(mesh,"midedge")
          varargout{nn} = mesh.midedge;
	else
          [b] = midedge(p,t,nelem);
          varargout{nn} = b;
          clear b;
	endif

      otherwise
	warning("msh2m_geometrical_properties: unexpected value in property string. Empty vector passed as output.")
	varargout{nn} = [];
    endswitch

  endfor

endfunction

function [k,j,w] = coeflines(p,t,nelem)

  ## Edges are described by the analytical expression:
  ##
  ## k*x + j*y + w = 0
  ##
  ## Coefficients k,j,w are stored in matrixes
  
  ## i-th edge list, i =1,2,3
  s1 = sort(t(2:3,:),1);
  s2 = sort(t([3,1],:),1);
  s3 = sort(t(1:2,:),1);  
  ## Initialization of the matrix data-structure
  k = ones(3,nelem);
  j = ones(3,nelem);
  w = ones(3,nelem);
  ## Searching for lines parallel to x axis
  [i1] = find( (p(2,s1(2,:)) - p(2,s1(1,:))) != 0 );
  noti1 = setdiff([1:nelem], i1);
  [i2] = find( (p(2,s2(2,:)) - p(2,s2(1,:))) != 0 );
  noti2 = setdiff([1:nelem], i2);
  [i3] = find( (p(2,s3(2,:)) - p(2,s3(1,:))) != 0 );
  noti3 = setdiff([1:nelem], i3);
  ## Computation of the coefficients
  ## Edge 1
  j(1,i1) = (p(1,s1(1,i1)) - p(1,s1(2,i1)))./(p(2,s1(2,i1)) - p(2,s1(1,i1)));
  w(1,i1) = -(p(1,s1(1,i1)) + p(2,s1(1,i1)).*j(1,i1));
  k(1,noti1) = 0;
  j(1,noti1) = 1;
  w(1,noti1) = - p(2,s1(1,noti1));
  ## Edge 2
  j(2,i2) = (p(1,s2(1,i2)) - p(1,s2(2,i2)))./(p(2,s2(2,i2)) - p(2,s2(1,i2)));
  w(2,i2) = -(p(1,s2(1,i2)) + p(2,s2(1,i2)).*j(2,i2));
  k(2,noti2) = 0;
  j(2,noti2) = 1;
  w(2,noti2) = - p(2,s2(1,noti2));
  ## Edge 3
  j(3,i3) = (p(1,s3(1,i3)) - p(1,s3(2,i3)))./(p(2,s3(2,i3)) - p(2,s3(1,i3)));
  w(3,i3) = -(p(1,s3(1,i3)) + p(2,s3(1,i3)).*j(3,i3));
  k(3,noti3) = 0;
  j(3,noti3) = 1;
  w(3,noti3) = - p(2,s3(1,noti3));
endfunction

function [b] = coordinates(p,t,nelem,j,w,k,string)

  ## Compute the coordinates of the geometrical entity specified by string

  ## Initialization of the output vectors
  b = zeros(2, nelem);
  switch string
    case "bar"
      b(1,:) = ( p(1,t(1,:)) + p(1,t(2,:)) + p(1,t(3,:)) )/3;
      b(2,:) = ( p(2,t(1,:)) + p(2,t(2,:)) + p(2,t(3,:)) )/3;
    case "cir"
      ## Computation of the midpoint of the first two edges
      mid1 = zeros(2,nelem);
      mid2 = zeros(2,nelem);
      ## X coordinate
      mid1(1,:) = ( p(1,t(2,:)) + p(1,t(3,:)) )/2;
      mid2(1,:) = ( p(1,t(3,:)) + p(1,t(1,:)) )/2;
      ## Y coordinate
      mid1(2,:) = ( p(2,t(2,:)) + p(2,t(3,:)) )/2;
      mid2(2,:) = ( p(2,t(3,:)) + p(2,t(1,:)) )/2;
      ## Computation of the intersect between axis 1 and axis 2
      ## Searching for element with edge 1 parallel to x-axes
      [parx] = find( j(1,:) == 0);
      [notparx] = setdiff(1:nelem, parx);
      coefy = zeros(1,nelem);
      ## If it is not parallel
      coefy(notparx) = ((j(2,notparx)./j(1,notparx)).*k(1,notparx) - k(2,notparx)).^(-1);
      b(2,notparx) = coefy(1,notparx).*( j(2,notparx).*mid2(1,notparx) - k(2,notparx).*mid2(2,notparx) + k(1,notparx)./j(1,notparx).*j(2,notparx).*mid1(2,notparx) - j(2,notparx).*mid1(1,notparx) );
      b(1,notparx) =( k(1,notparx).*b(2,notparx) + j(1,notparx).*mid1(1,notparx) - k(1,notparx).*mid1(2,notparx) )./j(1,notparx);
      ## If it is parallel
      b(2,parx) = mid1(2,parx);
      b(1,parx) = k(2,parx)./j(2,parx).*( b(2,parx) - mid2(2,parx) ) + mid2(1,parx);
  endswitch
endfunction

function [b] = midpoint(p,e)

  ## Compute the coordinates of the midpoint on the boundary edges

  b = zeros(2,columns(e));
  b(1,:) = ( p(1,e(1,:)) + p(1,e(2,:)) )./2;
  b(2,:) = ( p(2,e(1,:)) + p(2,e(2,:)) )./2;
endfunction

function [l] = sidelength(p,t,nelem)

  ## Compute the length of every side
  
  l = zeros(3, nelem);
  ## i-th edge list, i =1,2,3
  s1 = sort(t(2:3,:),1);
  s2 = sort(t([3,1],:),1);
  s3 = sort(t(1:2,:),1);
  ## First side length
  l(1,:) = sqrt( (p(1,s1(1,:)) - p(1,s1(2,:))).^2 + (p(2,s1(1,:)) - p(2,s1(2,:))).^2 );
  ## Second side length
  l(2,:) = sqrt( (p(1,s2(1,:)) - p(1,s2(2,:))).^2 + (p(2,s2(1,:)) - p(2,s2(2,:))).^2 );
  ## Third side length
  l(3,:) = sqrt( (p(1,s3(1,:)) - p(1,s3(2,:))).^2 + (p(2,s3(1,:)) - p(2,s3(2,:))).^2 );
endfunction

function [d] = semidistance(b,nelem,j,w,k)

  ## Compute the distance to the sides of the nodes with coordinates b
  ## The edges are described by the analytical expression:
  ##
  ## k*x + j*y + w = 0
  ##
  ## The coefficients k,j,w are stored in matrixes
  
  ## Initialization of the distance output vector
  d = zeros(3, nelem);
  ## Computation of the distances from the geometrical entity to the edges
  d(1,:) = abs( k(1,:).*b(1,:) + j(1,:).*b(2,:) + w(1,:))./(sqrt( k(1,:).^2 + j(1,:).^2));
  d(2,:) = abs( k(2,:).*b(1,:) + j(2,:).*b(2,:) + w(2,:))./(sqrt( k(2,:).^2 + j(2,:).^2));
  d(3,:) = abs( k(3,:).*b(1,:) + j(3,:).*b(2,:) + w(3,:))./(sqrt( k(3,:).^2 + j(3,:).^2));
endfunction

function [d] = distance(b,n,nelem)
  
  ## Compute the distance between two neighbouring entities
  
  ## Initialization of the distance output vector
  d = NaN(3, nelem);
  ## Trg not on the geometrical border
  border = isnan(n);
  [index1] = find( border(1,:) == 0 );
  [index2] = find( border(2,:) == 0 );
  [index3] = find( border(3,:) == 0 );
  ## Computation of the distances between two neighboring geometrical entities
  d(1,index1) = sqrt( ( b(1,index1) - b(1,n(1,index1)) ).^2 + ( b(2,index1) - b(2,n(1,index1)) ).^2 );
  d(2,index2) = sqrt( ( b(1,index2) - b(1,n(2,index2)) ).^2 + ( b(2,index2) - b(2,n(2,index2)) ).^2 );
  d(3,index3) = sqrt( ( b(1,index3) - b(1,n(3,index3)) ).^2 + ( b(2,index3) - b(2,n(3,index3)) ).^2 );
endfunction

function [b] = computearea(p,e,t,string)

  ## Compute the area of every element in the mesh

  weight = [1/3 1/3 1/3];
  areakk = 1/2;
  Nelements = columns(t);

  jac([1,2],:) = [p(1,t(2,:))-p(1,t(1,:));
		  p(1,t(3,:))-p(1,t(1,:))];
  jac([3,4],:) = [p(2,t(2,:))-p(2,t(1,:));
		  p(2,t(3,:))-p(2,t(1,:))];
  jacdet = jac(1,:).*jac(4,:)-jac(2,:).*jac(3,:);

  degen=find(jacdet <= 0);
  if ~isempty(degen)
    ## XXX FIXME: there should be a -verbose option to allow to see this
    ## fprintf(1,"invalid mesh element:  %d  fixing...\n",degen);
    t(1:3,degen) = t([2,1,3],degen);
    jac([1,2],degen) = [p(1,t(2,degen))-p(1,t(1,degen));
	  		p(1,t(3,degen))-p(1,t(1,degen))];
    jac([3,4],degen) = [p(2,t(2,degen))-p(2,t(1,degen));
			p(2,t(3,degen))-p(2,t(1,degen))];
    jacdet(degen) = jac(1,degen).*jac(4,degen)-jac(2,degen).*jac(3,degen);
  endif

  for inode = 1:3
    wjacdet(inode,:) = areakk .* jacdet .* weight(inode);
  endfor

  if string == "wjac"
    b = wjacdet();
  elseif string == "area"
    b = sum(wjacdet)';
  endif
  
endfunction

function [d] = midedge(p,t,nelem)
  ## Compute the midpoint coordinates for every edge
  s1 = t(2:3,:); s2 = t([3,1],:); s3 = t(1:2,:);
  edge = cell(3,1);
  edge(1) = s1; edge(2) = s2; edge(3) = s3;
  d = zeros(2,3,nelem); #Lati * Coordinate * Elementi
  for jj = 1:3
    tempx = (p(1,edge{jj}(1,:)) + p(1,edge{jj}(2,:)))/2;
    tempy = (p(2,edge{jj}(1,:)) + p(2,edge{jj}(2,:)))/2;
    temp = [tempx; tempy];
    d(:,jj,:) = temp;
  endfor
endfunction

function [shg] = shapegrad(p,t)
  
  ## Compute  the gradient of the hat functions
  
  x0 = p(1,t(1,:));
  y0 = p(2,t(1,:));
  x1 = p(1,t(2,:));
  y1 = p(2,t(2,:));
  x2 = p(1,t(3,:));
  y2 = p(2,t(3,:));

  denom = (-(x1.*y0) + x2.*y0 + x0.*y1 - x2.*y1 - x0.*y2 + x1.*y2);
  shg(1,1,:)  =  (y1 - y2)./denom;
  shg(2,1,:)  = -(x1 - x2)./denom;
  shg(1,2,:)  = -(y0 - y2)./denom;
  shg(2,2,:)  =  (x0 - x2)./denom;
  shg(1,3,:)  =  (y0 - y1)./denom;
  shg(2,3,:)  = -(x0 - x1)./denom;
endfunction

%!test
%! [mesh] = msh2m_structured_mesh(0:.5:1, 0:.5:1, 1, 1:4, "left");
%! [mesh.bar, mesh.cir, mesh.emidp, mesh.slength, mesh.cdist, mesh.area,mesh.midedge] = msh2m_geometrical_properties(mesh,"bar","cir","emidp","slength","cdist","area","midedge");
%! bar = [0.16667   0.16667   0.66667   0.66667   0.33333   0.33333   0.83333   0.83333
%!        0.16667   0.66667   0.16667   0.66667   0.33333   0.83333   0.33333   0.83333];
%! cir = [0.25000   0.25000   0.75000   0.75000   0.25000   0.25000   0.75000   0.75000
%!        0.25000   0.75000   0.25000   0.75000   0.25000   0.75000   0.25000   0.75000];
%! emidp =[0.25000   0.75000   1.00000   1.00000   0.25000   0.75000   0.00000   0.00000
%!         0.00000   0.00000   0.25000   0.75000   1.00000   1.00000   0.25000   0.75000];
%! slength =[0.70711   0.70711   0.70711   0.70711   0.50000   0.50000   0.50000   0.50000
%!           0.50000   0.50000   0.50000   0.50000   0.50000   0.50000   0.50000   0.50000
%!           0.50000   0.50000   0.50000   0.50000   0.70711   0.70711   0.70711   0.70711];
%! cdist = [0.00000   0.00000   0.00000   0.00000   0.50000   0.50000   0.25000   0.25000
%!          0.25000   0.25000   0.50000   0.50000   0.50000   0.25000   0.50000   0.25000
%!          0.25000   0.50000   0.25000   0.50000   0.00000   0.00000   0.00000   0.00000];
%! area = [ 0.12500 ;  0.12500 ;  0.12500 ;  0.12500 ;  0.12500 ;  0.12500 ;  0.12500 ;  0.12500];
%! midedge = zeros(2,3,8);
%! midedge(:,:,1) = [0.25000   0.00000   0.25000
%!                   0.25000   0.25000   0.00000];
%! midedge(:,:,2) = [0.25000   0.00000   0.25000
%!                   0.75000   0.75000   0.50000];
%! midedge(:,:,3) = [0.75000   0.50000   0.75000
%!                   0.25000   0.25000   0.00000];
%! midedge(:,:,4) = [0.75000   0.50000   0.75000
%!                   0.75000   0.75000   0.50000];
%! midedge(:,:,5) = [0.50000   0.25000   0.25000
%!                   0.25000   0.50000   0.25000];
%! midedge(:,:,6) = [0.50000   0.25000   0.25000
%!                   0.75000   1.00000   0.75000];
%! midedge(:,:,7) = [1.00000   0.75000   0.75000
%!                   0.25000   0.50000   0.25000];
%! midedge(:,:,8) = [1.00000   0.75000   0.75000
%!                   0.75000   1.00000   0.75000];
%! toll = 1e-4;
%! assert(mesh.bar,bar,toll);
%! assert(mesh.cir,cir,toll);
%! assert(mesh.emidp,emidp,toll);
%! assert(mesh.slength,slength,toll);
%! assert(mesh.cdist,cdist,toll);
%! assert(mesh.area,area,toll);
%! assert(mesh.midedge,midedge,toll);
