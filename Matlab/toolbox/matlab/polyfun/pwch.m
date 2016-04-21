function pc = pwch(x,y,s,dx,divdif)
%PWCH Piecewise cubic Hermite interpolation
%
%   PC = PWCH(X,Y,S) returns the ppform of the piecewise cubic Hermite
%   interpolant f to the given data values Y and the given slopes S
%   at the given data sites X. X must be a vector, and S must be of the same
%   size as Y.
%   If Y is a vector, then it must be of the same length as X and will be
%   resized if necessary to be a row vector.
%   If Y is a matrix, then size(Y,2) must equal length(X).
%
%   With d equal to size(Y,1), the piecewise cubic Hermite interpolant f to
%   these data is the d-valued piecewise cubic function with breaks at the
%   data sites X that satisfies
%
%          f(X(j)) = Y(:,j),  Df(X(j)) = S(:,j),  j=1:length(X) .
%
%   PC = PWCH(X,Y,S,DX,DIVDIF) also asks for DX := diff(X) and DIVDIF := 
%   diff(Y,1,2)./DX .
%
%   Class support for inputs X,Y,S,DX,DIVDIF:
%      float: double, single
%
%   See also SPLINE, INTERP1, PCHIP, PPVAL, UNMKPP, SPLINES (The Spline Toolbox).

%   cb 1997
%   Copyright 1984-2004 The MathWorks, Inc.

if nargin<4, dx = diff(x(:).'); end
d = size(y,1); dxd = repmat(dx,d,1); 
if nargin<5, divdif = diff(y,1,2)./dxd; end

n = numel(x);
dzzdx = (divdif-s(:,1:n-1))./dxd; dzdxdx = (s(:,2:n)-divdif)./dxd;
dnm1 = d*(n-1);
pc = mkpp(x,[reshape((dzdxdx-dzzdx)./dxd,dnm1,1) ...
             reshape(2*dzzdx-dzdxdx,dnm1,1) ...
             reshape(s(:,1:n-1),dnm1,1) ...
             reshape(y(:,1:n-1),dnm1,1)],d);
