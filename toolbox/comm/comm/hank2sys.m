function [a, b, c, d, sv] = hank2sys(han, ini, tol)
%HANK2SYS Convert a Hankel matrix to a linear system model.
%   [NUM, DEN] = HANK2SYS(H, INI, TOL) converts a Hankel matrix H to a
%   linear system transfer function with numerator NUM and denominator DEN.
%   INI is the system impulse at time zero. When TOL > 1, TOL indicates
%   the order of the conversion. When TOL < 1, TOL indicates the tolerance
%   in selecting the order based on the singular values. The default value
%   of TOL is 0.01. This conversion uses the singular value decomposition
%   (SVD) method.
%
%   [NUM, DEN, SV] = HANK2SYS(...) outputs the transfer function and the
%   SVD values.
%
%   [A, B, C, D] = HANK2SYS(...) outputs A, B, C, D matrices of the linear
%   system state-space model.
%
%   [A, B, C, D, SVD ] = HANK2SYS(...) outputs the state-space model and
%   the SVD values.
%
%   See also RCOSFLT, HANKEL.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $
%

if nargin < 1
    error('Too few inputs for HANK2SYS');
elseif nargin < 2
    ini = 0; tol = 0.01;
elseif nargin < 3
    tol = 0.01;
end;
[ini, tol] = checkinp(ini, tol, 0, 0.01);

sz = length(han);
%svd for the Hankel matrix
[u, sv, v] = svd(han);
sv = diag(sv);
if tol < 1
    ind = find(sv/sv(1) < tol);
    if isempty(ind)
        ord = sz;
    else
        ord = ind(1)-1;
    end;
else
    ord = ceil(tol);
end;
d = ini;

%partition the matrices:
u1 = u(1 : sz-1, 1 : ord);
v1 = v(1 : sz-1, 1 : ord);
u2 = u(2 : sz,   1 : ord);

ss = sqrt(sv(1:ord));
vss = 1 ./ ss;

uu = u1' * u2;
a = uu .* (vss * ss');
b = ss .* v1(1, :)';
c = u1(1, :) .* ss';

if nargout < 4
    [a, b] = ss2tf(a, b, c, d, 1);
    c = sv;
end;
% ---end of hank2sys.m---
