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
## @deftypefn {Function File}{[@var{lon},@var{lat}] =}op_inv(@var{X},@var{Y},@var{params})
##
## This function unprojects cartesian projected coordinates (in a defined
## cartographic projection) into geodetic coordinates using the PROJ.4 function
## pj_inv().
##
## @var{X} contains the X projected coordinates.
## @var{Y} contains the Y projected coordinates.
## @var{params} is a text string containing the projection parameters in PROJ.4
## format.
##
## @var{X} or @var{Y} can be scalars, vectors or matrices with equal dimensions.
##
## @var{lon} is the geodetic longitude, in radians.
## @var{lat} is the geodetic latitude, in radians.
##
## If a projection error occurs, the resultant coordinates for the affected
## points have both Inf value and a warning message is emitted (one for each
## erroneous point).
## @seealso{op_fwd, op_transform}
## @end deftypefn




function [lon,lat] = op_inv(X,Y,params)

try
    functionName = 'op_inv';
    argumentNumber = 3;

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
    [X,Y,rowWork,colWork] = checkInputArguments(X,Y,params);
catch
    %error message
    error('\n\tIn function %s:\n\t -%s ',functionName,lasterr);
end

%*******************************************************************************
%COMPUTATION
%*******************************************************************************

try
    %calling oct function
    [lon,lat] = _op_inv(X,Y,params);
    %convert output vectors in matrices of adequate size
    lon = reshape(lon,rowWork,colWork);
    lat = reshape(lat,rowWork,colWork);
catch
    %error message
    error('\n\tIn function %s:\n\tIn function %s ',functionName,lasterr);
end




%*******************************************************************************
%AUXILIARY FUNCTION
%*******************************************************************************




function [a,b,rowWork,colWork] = checkInputArguments(a,b,params)

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
%checking a and b dimensions
if (rowA~=rowB)||(colA~=colB)
    error('The dimensions of input arguments are not the same');
else
    %working dimensions
    rowWork = rowA;
    colWork = colA;
    %convert a and b in column vectors
    a = reshape(a,rowWork*colWork,1);
    b = reshape(b,rowWork*colWork,1);
end
%params must be a text string
if ~ischar(params)
    error('The third input argument is not a text string');
end




%*****END OF FUNCIONS*****




%*****FUNCTION TESTS*****




%!test
%!  [lon,lat]=op_inv(255466.98,4765182.93,'+proj=utm +lon_0=3w +ellps=GRS80');
%!  assert(lon*180/pi,-6,1e-7)
%!  assert(lat*180/pi,43,1e-7)
%!error(op_inv)
%!error(op_inv(1,2,3,4))
%!error(op_inv('string',2,3))
%!error(op_inv(1,'string',3))
%!error(op_inv(1,2,3))
%!error(op_inv([1 1;2 2],2,'+proj=utm +lon_0=3w +ellps=GRS80'))
%!error(op_inv(1,[2 2;3 3],'+proj=utm +lon_0=3w +ellps=GRS80'))




%*****END OF TESTS*****
