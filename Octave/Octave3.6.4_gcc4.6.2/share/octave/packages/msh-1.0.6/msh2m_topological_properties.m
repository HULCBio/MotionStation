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
## msh2m_topological_properties(@var{mesh},[@var{string1},@var{string2},...])
## 
## Compute @var{mesh} topological properties identified by input strings.
##
## Valid properties are:
## @itemize @bullet
## @item @code{"n"}: return a matrix with size 3 times the number of
## mesh elements containing the list of its neighbours. The entry
## @code{M(i,j)} in this matrix is the mesh element sharing the side
## @code{i} of triangle @code{j}. If no such element exists (i.e. for
## boundary edges) a value of @code{NaN} is set. 
## @item @code{"sides"}: return a matrix with size 2 times number of
## sides.The entry @code{M(i,j)} is the index of the i-th vertex of j-th
## side.
## @item @code{"ts"}: return a matrix with size 3 times the number of
## mesh elements containing the sides associated with each element.
## @item @code{"tws"}:return a matrix with size 2 times the number of
## mesh sides containing the elements associated with each side. For a
## side belonging to one triangle only a value of @code{NaN} is set.
## @item @code{"coinc"}: return a matrix with 2 rows. Each column
## contains the indices of two triangles sharing the same circumcenter. 
## @item @code{"boundary"}: return a matrix with size 2 times the number
## of side edges. The first row contains the mesh element to which the
## side belongs, the second row is the local index of this edge.
## @end itemize 
##
## The output will contain the geometrical properties requested in the
## input in the same order specified in the function call.
##
## If an unexpected string is given as input, an empty vector is
## returned in output.
##
## @seealso{mshm2m_geometrical_properties, msh3m_geometrical_properties}
## @end deftypefn

function [varargout] = msh2m_topological_properties(mesh,varargin)

  ## Check input
  if nargin < 2 # Number of input parameters
    error("msh2m_topological_properties: wrong number of input parameters.");
  elseif !(isstruct(mesh)    && isfield(mesh,"p") &&
	   isfield(mesh,"t") && isfield(mesh,"e"))
    error("msh2m_topological_properties: first input is not a valid mesh structure.");
  elseif !iscellstr(varargin)
    error("msh2m_topological_properties: only string value admitted for properties.");
  endif
  
  ## Compute properties
  p = mesh.p;
  e = mesh.e;
  t = mesh.t;
  
  nelem = columns(t); # Number of elements in the mesh
  [n,ts,tws,sides] = neigh(t,nelem);

  for nn = 1:length(varargin)
    request = varargin{nn};
    switch request
	
      case "n" # Neighbouring triangles
	if isfield(mesh,"n")
          varargout{nn} = mesh.n;
	else
          varargout{nn} = n;
	endif

      case "sides" # Global edge matrix
	if isfield(mesh,"sides")
          varargout{nn} = mesh.sides;
	else
          varargout{nn} = sides;
	endif

      case "ts" # Triangle sides matrix
	if isfield(mesh,"ts")
          varargout{nn} = mesh.ts;
	else
          varargout{nn} = ts;
	endif

      case "tws" # Trg with sides matrix
	if isfield(mesh,"tws")
          varargout{nn} = mesh.tws;
	else
          varargout{nn} = tws;
	endif

      case "coinc" # Coincident circumcenter matrix
	if isfield(mesh,"coinc")
          varargout{nn} = mesh.coinc;
	else
          if isfield(mesh,"cdist")
            d = mesh.cdist;
          else
            [d] = msh2m_geometrical_properties(mesh,"cdist");
          endif        
          [b] = coinc(n,d);
          varargout{nn} = b;
          clear b
	endif

      case "boundary" # Boundary edge matrix
	if isfield(mesh,"boundary")
          varargout{nn} = mesh.boundary;
	else
          [b] = borderline(e,t);
          varargout{nn} = b;
          clear b
	endif

      otherwise
	warning("msh2m_topological_properties: unexpected value in property string. Empty vector passed as output.")
	varargout{nn} = [];
    endswitch

  endfor

endfunction

function [n,ts,triwside,sides] = neigh(t,nelem)

  n  = nan*ones(3,nelem);
  t  = t(1:3,:);

  s3 = sort(t(1:2,:),1);
  s1 = sort(t(2:3,:),1);
  s2 = sort(t([3,1],:),1);

  allsides = [s1 s2 s3]';
  [sides, ii, jj] = unique( allsides,"rows");
  sides = sides';

  ts = reshape(jj,[],3)';

  triwside = zeros(2,columns(sides));
  for kk =1:3
    triwside(1,ts(kk,1:end)) = 1:nelem;
    triwside(2,ts(4-kk,end:-1:1)) = nelem:-1:1;
  endfor

  triwside(2,triwside(1,:)==triwside(2,:)) = NaN;

  n(1,:) = triwside(1,ts(1,:));
  n(1,n(1,:)==1:nelem) = triwside(2,ts(1,:))(n(1,:)==1:nelem);
  n(2,:) = triwside(1,ts(2,:));
  n(2,n(2,:)==1:nelem) = triwside(2,ts(2,:))(n(2,:)==1:nelem);
  n(3,:) = triwside(1,ts(3,:));
  n(3,n(3,:)==1:nelem) = triwside(2,ts(3,:))(n(3,:)==1:nelem);

endfunction

function [output] = coinc(n,d);
  
  ## Tolerance value for considering two point to be coincident
  toll = 1e-10;
  ## Check the presence of more than two trgs sharing the same circum centre
  degen = d < toll; res = sum(degen);
  [check] = find(res > 1);
  ## Index of the sharing pairs
  [ii, jj] = find(degen >= 1);
  if isempty(jj) == 0
    temp = zeros(2,length(jj));
    temp(1,:) = jj';
    temp(2,:) = diag(n(ii,jj))';
    temp = sort(temp);
    temp = temp';
    [output] = unique(temp,"rows");
    output = output';
    if isempty(check) == 0
      warning("More than two trgs sharing the same circum-centre.")
      ## FIXME if more than two trgs shares the same circen ---> construct a cell array
    endif
  else
    output = [];
  endif
endfunction

function [output] = borderline(e,t)

  nelem = columns(e);
  t = t(1:3,:);
  output = zeros(4,nelem);
  for ii = 1:nelem

    point = ( e(1,ii) == t );
    point += ( e(2,ii) == t );

    [jj1] = find( sum(point(2:3,:)) == 2);
    [jj2] = find( sum(point([3 1],:)) == 2);
    [jj3] = find( sum(point(1:2,:)) == 2);

    assert( (length(jj1) + length(jj2) + length(jj3)) <= 2 );

    numtrg = 0;
    for jj=1:length(jj1)
      output(2*numtrg+1,ii) = jj1(jj);
      output(2*numtrg+2,ii) = 1;
      numtrg += 1;
    endfor
    for jj=1:length(jj2)
      output(2*numtrg+1,ii) = jj2(jj);
      output(2*numtrg+2,ii) = 2;
      numtrg += 1;
    endfor
    for jj=1:length(jj3)
      output(2*numtrg+1,ii) = jj3(jj);
      output(2*numtrg+2,ii) = 3;
      numtrg += 1;
    endfor

  endfor
endfunction

%!test
%! [mesh] = msh2m_structured_mesh(0:.5:1, 0:.5:1, 1, 1:4, "left");
%! [mesh.n,mesh.sides,mesh.ts,mesh.tws,mesh.coinc,mesh.boundary] = msh2m_topological_properties(mesh,"n","sides","ts","tws","coinc","boundary");
%! n = [5     6     7     8     3     4   NaN   NaN
%!    NaN   NaN     5     6     2   NaN     4   NaN
%!    NaN     5   NaN     7     1     2     3     4];
%! sides = [1   1   2   2   2   3   3   4   4   5   5   5   6   6   7   8
%!          2   4   3   4   5   5   6   5   7   6   7   8   8   9   8   9];
%! ts = [4    6   11   13    8   10   15   16
%!       1    3    8   10    5    7   12   14
%!       2    5    9   12    4    6   11   13];
%! tws = [ 1     1     2     5     2     6     6     3     3     4     7     4     8     8     7     8
%!       NaN   NaN   NaN     1     5     2   NaN     5   NaN     6     3     7     4   NaN   NaN   NaN];
%! coinc = [1   2   3   4
%!          5   6   7   8];
%! boundary =[ 1   3   7   8   6   8   1   2
%!             3   3   1   1   2   2   2   2
%!             0   0   0   0   0   0   0   0
%!             0   0   0   0   0   0   0   0];
%! assert(mesh.n,n);
%! assert(mesh.sides,sides);
%! assert(mesh.ts,ts);
%! assert(mesh.tws,tws);
%! assert(mesh.coinc,coinc);
%! assert(mesh.boundary,boundary);

%!test
%! mesh.p = []; mesh.e = [];
%! mesh.t = [3    9   10    1    6    9   10    9    8    9
%!           9    3    1   10   10   10    7    5    9    8
%!           6    5    7    8    2    6    2    4    4   10
%!           6    6    6    6    6    6    6    6    6    6];
%! [mesh.n] = msh2m_topological_properties(mesh,"n");
%! n = [6   NaN   NaN    10     7     5   NaN   NaN     8     4
%!      NaN   8     7   NaN   NaN     1     5     9   NaN     6
%!      2     1     4     3     6    10     3     2    10     9];
%! assert(mesh.n,n);


%!test
%! mesh.p = []; mesh.e = [];
%! mesh.t =[
%!   10    3    6   11   10    3    6   11    1    7    5    9    2    5   11    9   13    6
%!   14    7   10   15   15    8   11   16    5   11    9   13    6    6   12   10   14    7
%!   15    8   11   16   11    4    7   12    2    8    6   10    3    2    8    6   10    3
%!    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1];
%! [mesh.n] = msh2m_topological_properties(mesh,"n");
%! n =[
%!   NaN    10     5   NaN     4   NaN    10   NaN    14    15    16    17    18    13   NaN     3     1     2
%!     5     6     7     8     3   NaN    18    15   NaN     2    14    16   NaN     9    10    11    12    13
%!    17    18    16     5     1     2     3     4   NaN     7   NaN   NaN    14    11     8    12   NaN     7];
%! assert(mesh.n,n);
