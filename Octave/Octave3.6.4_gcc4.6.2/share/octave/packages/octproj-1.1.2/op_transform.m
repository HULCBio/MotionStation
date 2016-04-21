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
## @deftypefn {Function File}{[@var{X2},@var{Y2},@var{Z2}] =}op_transform(@var{X1},@var{Y1},@var{Z1},@var{par1},@var{par2})
## @deftypefnx {Function File}{[@var{X2},@var{Y2}] =}op_transform(@var{X1},@var{Y1},@var{par1},@var{par2})
##
## This function transforms X/Y/Z, lon/lat/h points between two coordinate
## systems 1 and 2 using the PROJ.4 function pj_transform().
##
## @var{X1} contains the first coordinates in the source coordinate system. If
## @var{X1} is geodetic longitude, it must be expressed in radians.
## @var{Y1} contains the second coordinates in the source coordinate system. If
## @var{Y1} is geodetic latitude, it must be expressed in radians.
## @var{Z1} contains the third coordinates in the source coordinate system.
## @var{par1} is a text string containing the projection parameters for the
## source system, in PROJ.4 format.
## @var{par2} is a text string containing the projection parameters for the
## destination system, in PROJ.4 format.
##
## @var{X1}, @var{Y1} or @var{X1} can be scalars, vectors or matrices with
## equal dimensions.
##
## @var{X2} is the first coordinate in the destination coordinate system. If
## @var{X2} is geodetic longitude, it is output in radians.
## @var{Y2} is the second coordinate in the destination coordinate system. If
## @var{Y2} is geodetic longitude, it is output in radians.
## @var{Z2} is the third coordinate in the destination coordinate system. If
## argument @var{Z1} was omitted, this value is an empty matrix.
##
## @seealso{op_fwd, op_inv}
## @end deftypefn




function [X2,Y2,Z2] = op_transform(X1,Y1,Z1,par1,par2)

try
    functionName = 'op_transform';
    minArgNumber = 4;
    maxArgNumber = 5;

%*******************************************************************************
%NUMBER OF INPUT ARGUMENTS CHECKING
%*******************************************************************************

    %number of input arguments checking
    if (nargin<minArgNumber)||(nargin>maxArgNumber)
        error(['Incorrect number of input arguments (%d)\n\t         ',...
               'Correct number of input arguments = %d or %d'],...
              nargin,minArgNumber,maxArgNumber);
    end

%*******************************************************************************
%INPUT ARGUMENTS CHECKING
%*******************************************************************************

    %checking input arguments
    if nargin==minArgNumber
        par2 = par1;
        par1 = Z1;
        Z1 = [];
    end
    [X1,Y1,Z1,rowWork,colWork] = checkInputArguments(X1,Y1,Z1,par1,par2);
catch
    %error message
    error('\n\tIn function %s:\n\t -%s ',functionName,lasterr);
end

%*******************************************************************************
%COMPUTATION
%*******************************************************************************

try
    %calling oct function
    [X2,Y2,Z2] = _op_transform(X1,Y1,Z1,par1,par2);
    %convert output vectors in matrices of adequate size
    X2 = reshape(X2,rowWork,colWork);
    Y2 = reshape(Y2,rowWork,colWork);
    if nargin==maxArgNumber
        Z2 = reshape(Z2,rowWork,colWork);
    end
catch
    %error message
    error('\n\tIn function %s:\n\tIn function %s ',functionName,lasterr);
end




%*******************************************************************************
%AUXILIARY FUNCTION
%*******************************************************************************




function [a,b,c,rowWork,colWork] = checkInputArguments(a,b,c,par1,par2)

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
if isnumeric(c)
    %c dimensions
    if isempty(c)
        rowC = 0;
        colC = 0;
    else
        [rowC,colC] = size(c);
    end
else
    error('The third/fourth input argument is not numeric');
end
%checking a, b and c dimensions
if (max([rowA rowB])~=min([rowA rowB]))||(max([colA colB])~=min([colA colB]))
    error('The dimensions of input arguments are not the same');
else
    %working dimensions
    rowWork = rowA;
    colWork = colA;
    if (rowC~=0)&&(colC~=0)
        if (rowC==rowWork)&&(colC==colWork)
            c = reshape(c,rowWork*colWork,1);
        else
            error('The dimensions of input arguments are not the same');
        end
    else
        c = zeros(0,1);
    end
    %convert a and b in column vectors
    a = reshape(a,rowWork*colWork,1);
    b = reshape(b,rowWork*colWork,1);
end
%params must be a text string
if ~ischar(par1)
    error('The fourth/fifth input argument is not a text string');
end
if ~ischar(par2)
    error('The last input argument is not a text string');
end




%*****FUNCTION TESTS*****




%!test
%!  [x,y,h]=op_transform(-6*pi/180,43*pi/180,1000,...
%!                       '+proj=latlong +ellps=GRS80',...
%!                       '+proj=utm +lon_0=3w +ellps=GRS80');
%!  [lon,lat,H]=op_transform(x,y,h,'+proj=utm +lon_0=3w +ellps=GRS80',...
%!                           '+proj=latlong +ellps=GRS80');
%!  assert(x,255466.98,1e-2)
%!  assert(y,4765182.93,1e-2)
%!  assert(h,1000.0,1e-15)
%!  assert(lon*180/pi,-6,1e-8)
%!  assert(lat*180/pi,43,1e-8)
%!  assert(H,1000.0,1e-15)
%!test
%!  [x,y]=op_transform(-6*pi/180,43*pi/180,'+proj=latlong +ellps=GRS80',...
%!                     '+proj=utm +lon_0=3w +ellps=GRS80');
%!  [lon,lat]=op_transform(x,y,'+proj=utm +lon_0=3w +ellps=GRS80',...
%!                         '+proj=latlong +ellps=GRS80');
%!  assert(x,255466.98,1e-2)
%!  assert(y,4765182.93,1e-2)
%!  assert(lon*180/pi,-6,1e-8)
%!  assert(lat*180/pi,43,1e-8)
%!error(op_transform)
%!error(op_transform(1,2,3,4,5,6))
%!error(op_transform('string',2,3,4,5))
%!error(op_transform(1,'string',3,4,5))
%!error(op_transform(1,2,'string',4,5))
%!error(op_transform(1,2,3,'string',5))
%!error(op_transform(1,2,3,4,'string'))
%!error(op_transform([1 1;2 2],2,3,'+proj=latlong +ellps=GRS80',...
%!                   '+proj=utm +lon_0=3w +ellps=GRS80'))
%!error(op_transform(1,[2 2;3 3],3,'+proj=latlong +ellps=GRS80',...
%!                   '+proj=utm +lon_0=3w +ellps=GRS80'))
%!error(op_transform(1,2,[3 3;4 4],'+proj=latlong +ellps=GRS80',...
%!                   '+proj=utm +lon_0=3w +ellps=GRS80'))




%*****END OF TESTS*****
