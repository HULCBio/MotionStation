function  [xz,y,z] = peaks(arg1,arg2)
%PEAKS  A sample function of two variables.
%   PEAKS is a function of two variables, obtained by translating and
%   scaling Gaussian distributions, which is useful for demonstrating
%   MESH, SURF, PCOLOR, CONTOUR, etc.
%   There are several variants of the calling sequence:
%
%       Z = PEAKS;
%       Z = PEAKS(N);
%       Z = PEAKS(V);
%       Z = PEAKS(X,Y);
%
%       PEAKS;
%       PEAKS(N);
%       PEAKS(V);
%       PEAKS(X,Y);
%
%       [X,Y,Z] = PEAKS;
%       [X,Y,Z] = PEAKS(N);
%       [X,Y,Z] = PEAKS(V);
%
%   The first variant produces a 49-by-49 matrix.
%   The second variant produces an N-by-N matrix.
%   The third variant produces an N-by-N matrix where N = length(V).
%   The fourth variant evaluates the function at the given X and Y,
%   which must be the same size.  The resulting Z is also that size.
%
%   The next four variants, with no output arguments, do a SURF
%   plot of the result.
%
%   The last three variants also produce two matrices, X and Y, for
%   use in commands such as PCOLOR(X,Y,Z) or SURF(X,Y,Z,DEL2(Z)).
%
%   If not given as input, the underlying matrices X and Y are
%       [X,Y] = MESHGRID(V,V) 
%   where V is a given vector, or V is a vector of length N with
%   elements equally spaced from -3 to 3.  If no input argument is
%   given, the default N is 49.

%   CBM, 2-1-92, 8-11-92, 4-30-94.
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.10.4.2 $  $Date: 2004/04/10 23:25:03 $

if nargin == 0
    dx = 1/8;
    [x,y] = meshgrid(-3:dx:3);
elseif nargin == 1
    if length(arg1) == 1
        [x,y] = meshgrid(-3:6/(arg1-1):3);
    else
        [x,y] = meshgrid(arg1,arg1);     
    end
else
    x = arg1; y = arg2;
end

z =  3*(1-x).^2.*exp(-(x.^2) - (y+1).^2) ...
   - 10*(x/5 - x.^3 - y.^5).*exp(-x.^2-y.^2) ...
   - 1/3*exp(-(x+1).^2 - y.^2);

if nargout > 1
    xz = x;
elseif nargout == 1
    xz = z;
else
    % Self demonstration
    disp(' ')
    disp('z =  3*(1-x).^2.*exp(-(x.^2) - (y+1).^2) ... ')
    disp('   - 10*(x/5 - x.^3 - y.^5).*exp(-x.^2-y.^2) ... ')
    disp('   - 1/3*exp(-(x+1).^2 - y.^2) ')
    disp(' ')
    surf(x,y,z)
    axis([min(min(x)) max(max(x)) min(min(y)) max(max(y)) ...
          min(min(z)) max(max(z))])
    xlabel('x'), ylabel('y'), title('Peaks')
end
