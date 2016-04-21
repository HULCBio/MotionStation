## Copyright (C) 2009, 2010, José Luis García Pallero, <jgpallero@gmail.com>
##
## This file is part of OctPROJ.
##
## OctPROJ is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File}{[@var{lon},@var{lat},@var{h}] =}op_geoc2geod(@var{X},@var{Y},@var{Z},@var{a},@var{f})
##
## This function converts cartesian tridimensional geocentric coordinates into
## geodetic coordinates using the PROJ.4 function pj_geocentric_to_geodetic().
##
## @var{X} contains the X geocentric coordinate.
## @var{Y} contains the Y geocentric coordinate.
## @var{Z} contains the Z geocentric coordinate.
## @var{a} is a scalar containing the semi-major axis of the ellipsoid.
## @var{f} is a scalar containing the flattening of the ellipsoid.
##
## @var{X}, @var{Y} or @var{Z} can be scalars, vectors or matrices with equal
## dimensions.
## The units of @var{X}, @var{Y}, @var{Z} and @var{a} must be the same.
##
## @var{lon} is the geodetic longitude, in radians.
## @var{lat} is the geodetic latitude, in radians.
## @var{h} is the ellipsoidal height, in the same units of @var{a}.
##
## @seealso{op_geod2geoc}
## @end deftypefn




function [lon,lat,h] = op_geoc2geod(X,Y,Z,a,f)

try
    functionName = 'op_geoc2geod';
    argumentNumber = 5;

%*******************************************************************************
%NUMBER OF INPUT ARGUMENTS CHECKING
%*******************************************************************************

    %number of input arguments checking
    if nargin~=argumentNumber
        error(['Incorrect number of input arguments (%d)\n\t         ',...
               'Correct number of input arguments = %d'],...
              nargin,argumentNumber);
    end

%*******************************************************************************
%INPUT ARGUMENTS CHECKING
%*******************************************************************************

    %checking input arguments
    [X,Y,Z,rowWork,colWork] = checkInputArguments(X,Y,Z,a,f);
catch
    %error message
    error('\n\tIn function %s:\n\t -%s ',functionName,lasterr);
end

%*******************************************************************************
%COMPUTATION
%*******************************************************************************

try
    %first squared eccentricity of the ellipsoid
    e2 = 2.0*f-f^2;
    %calling oct function
    [lon,lat,h] = _op_geoc2geod(X,Y,Z,a,e2);
    %convert output vectors in matrices of adequate size
    lon = reshape(lon,rowWork,colWork);
    lat = reshape(lat,rowWork,colWork);
    h = reshape(h,rowWork,colWork);
catch
    %error message
    error('\n\tIn function %s:\n\tIn function %s ',functionName,lasterr);
end




%*******************************************************************************
%AUXILIARY FUNCTION
%*******************************************************************************




function [a,b,c,rowWork,colWork] = checkInputArguments(a,b,c,d,e)

%a must be matrix type
if ismatrix(a)
    %a dimensions
    [rowA,colA] = size(a);
else
    error('The first input argument is not numeric');
end
%b must be matrix type
if ismatrix(b)
    %b dimensions
    [rowB,colB] = size(b);
else
    error('The second input argument is not numeric');
end
%c must be matrix type
if ismatrix(c)
    %b dimensions
    [rowC,colC] = size(c);
else
    error('The third input argument is not numeric');
end
%d must be scalar
if ~isscalar(d)
    error('The fourth input argument is not a scalar');
end
%e must be scalar
if ~isscalar(e)
    error('The fifth input argument is not a scalar');
end
%checking a, b and c dimensions
if (max([rowA rowB rowC])~=min([rowA rowB rowC]))||...
   (max([colA colB colC])~=min([colA colB colC]))
    error('The dimensions of input arguments are not the same');
else
    %working dimensions
    rowWork = rowA;
    colWork = colA;
    %convert a, b and c in column vectors
    a = reshape(a,rowWork*colWork,1);
    b = reshape(b,rowWork*colWork,1);
    c = reshape(c,rowWork*colWork,1);
end




%*****END OF FUNCIONS*****




%*****FUNCTION TESTS*****




%!test
%!  [lon,lat,h]=op_geoc2geod(2587045.819,1879598.809,5501461.606,6378388,1/297);
%!  assert(lon,0.628318530616265,1e-11)
%!  assert(lat,1.04719755124682,1e-11)
%!  assert(h,999.999401183799,1e-5)
%!error(op_geoc2geod)
%!error(op_geoc2geod(1,2,3,4,5,6))
%!error(op_geoc2geod('string',2,3,4,5))
%!error(op_geoc2geod(1,'string',3,4,5))
%!error(op_geoc2geod(1,2,'string',4,5))
%!error(op_geoc2geod(1,2,3,[4 4],5))
%!error(op_geoc2geod(1,2,3,4,[5 5]))
%!error(op_geoc2geod([1 1;2 2],2,3,4,5))
%!error(op_geoc2geod(1,[2 2;3 3],3,4,5))
%!error(op_geoc2geod(1,2,[3 3;4 4],4,5))
%!error(op_geoc2geod([1;1],[2 2 2],3,4,5))




%*****END OF TESTS*****
