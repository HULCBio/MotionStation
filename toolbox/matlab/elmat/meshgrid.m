function [xx,yy,zz] = meshgrid(x,y,z)
%MESHGRID   X and Y arrays for 3-D plots.
%   [X,Y] = MESHGRID(x,y) transforms the domain specified by vectors
%   x and y into arrays X and Y that can be used for the evaluation
%   of functions of two variables and 3-D surface plots.
%   The rows of the output array X are copies of the vector x and
%   the columns of the output array Y are copies of the vector y.
%
%   [X,Y] = MESHGRID(x) is an abbreviation for [X,Y] = MESHGRID(x,x).
%   [X,Y,Z] = MESHGRID(x,y,z) produces 3-D arrays that can be used to
%   evaluate functions of three variables and 3-D volumetric plots.
%
%   For example, to evaluate the function  x*exp(-x^2-y^2) over the 
%   range  -2 < x < 2,  -2 < y < 2,
%
%       [X,Y] = meshgrid(-2:.2:2, -2:.2:2);
%       Z = X .* exp(-X.^2 - Y.^2);
%       mesh(Z)
%
%   MESHGRID is like NDGRID except that the order of the first two input
%   and output arguments are switched (i.e., [X,Y,Z] = MESHGRID(x,y,z)
%   produces the same result as [Y,X,Z] = NDGRID(y,x,z)).  Because of
%   this, MESHGRID is better suited to problems in cartesian space,
%   while NDGRID is better suited to N-D problems that aren't spatially
%   based.  MESHGRID is also limited to 2-D or 3-D.
%
%   Class support for inputs x, y, z:
%      float: double, single
%
%   See also SURF, SLICE, NDGRID.

%   J.N. Little 1-30-92, CBM 2-11-92.
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.14.4.2 $  $Date: 2004/03/02 21:47:07 $

if nargout<3, % 2-D array case
  if nargin == 1, y = x; end
  if isempty(x) || isempty(y)
    xx = zeros(0,0,class(x)); yy = zeros(0,0,class(y));
  else
    xx = full(x(:)).'; % Make sure x is a full row vector.
    yy = full(y(:));   % Make sure y is a full column vector.
    nx = length(xx); ny = length(yy);
    xx = xx(ones(ny, 1),:);
    yy = yy(:,ones(1, nx));
  end

else  % 3-D array case
  if nargin == 1, y = x; z = x; end
  if nargin ==2 
    error('MATLAB:meshgrid:NotEnoughInputs', 'Not enough input arguments.'); 
  end
  if isempty(x) || isempty(y) || isempty(z)
    xx = zeros(0,0,class(x)); yy = zeros(0,0,class(y)); zz = zeros(0,0,class(z));
  else
    nx = numel(x); ny = numel(y); nz = numel(z);
    xx = reshape(full(x(:)),[1 nx 1]); % Make sure x is a full row vector.
    yy = reshape(full(y(:)),[ny 1 1]); % Make sure y is a full column vector.
    zz = reshape(full(z(:)),[1 1 nz]); % Make sure z is a full page vector.
    xx = xx(ones(ny,1),:,ones(nz,1));
    yy = yy(:,ones(1,nx),ones(nz,1));
    zz = zz(ones(ny,1),ones(nx,1),:);
  end
end
