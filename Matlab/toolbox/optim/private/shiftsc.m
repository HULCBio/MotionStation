function[xstart,l,u,ds,DS,c] = shiftsc(xstart,l,u,typx,caller,mtxmpy,c,H,varargin);
%SHIFTSC Shift and scale
%
% [xstart,l,u,ds,DS,c] = shiftsc(xstart,l,u,typx,caller,mtxmpy,c,H) shift
% and scale vectors u,l, and xstart so that finite value of u map to
% unity and finite values of l map to zero.
%
%

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2004/02/07 19:13:42 $

n = length(xstart);
ds = ones(n,1); DS = sparse(1:n,1:n,ds);
ll = l; vshift = zeros(n,1);
arg1 = (l== -inf) & (u == inf);
arg2 = (l== -inf) & (u < inf); 
arg3 = (l> -inf) & (u == inf);
arg4 = (l > -inf) & (u < inf);
if nnz(arg1) == n, return; end

% SHIFT
xstart(arg2) = xstart(arg2) + ones(size(arg2(arg2 > 0))) - u(arg2);
vshift(arg2) = u(arg2) - ones(size(arg2(arg2 > 0)));
u(arg2) = ones(size(arg2(arg2 > 0)));

xstart(arg3) = xstart(arg3) - l(arg3);
vshift(arg3) = l(arg3);
l(arg3) = zeros(size(arg3(arg3 > 0)));

xstart(arg4) = xstart(arg4) - l(arg4);
vshift(arg4) = l(arg4);
u(arg4) = u(arg4) - l(arg4);
l(arg4) = zeros(size(arg4(arg4 > 0)));

if isequal(caller,'sqpbox')
    w = feval(mtxmpy,H,vshift,varargin{:});
else % sllsbox
    w = feval(mtxmpy,H,vshift,0,varargin{:});
end
c = c + w;

% SCALE
ds = ones(n,1);
ds(arg1) = max(abs(typx(arg1)),ds(arg1));
ds(arg4) = abs(u(arg4));
DS = sparse(1:n,1:n,ds); 
if nargin > 5,  c = DS*c; end
u = u./ds;
xstart = xstart./ds;
xstart = full(xstart); l = full(l); u = full(u); ds = full(ds);
c = full(c);



