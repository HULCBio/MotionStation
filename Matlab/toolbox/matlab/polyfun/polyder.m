function [a,b] = polyder(u,v)
%POLYDER Differentiate polynomial.
%   POLYDER(P) returns the derivative of the polynomial whose
%   coefficients are the elements of vector P.
%
%   POLYDER(A,B) returns the derivative of polynomial A*B.
%
%   [Q,D] = POLYDER(B,A) returns the derivative of the
%   polynomial ratio B/A, represented as Q/D.
%
%   Class support for inputs u, v:
%      float: double, single
%
%   See also POLYINT, CONV, DECONV.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.11.4.2 $  $Date: 2004/03/02 21:47:56 $

if nargin < 2, v = 1; end

u = u(:).'; v = v(:).';
nu = length(u); nv = length(v);
if nu < 2, up = 0; else up = u(1:nu-1) .* (nu-1:-1:1); end
if nv < 2, vp = 0; else vp = v(1:nv-1) .* (nv-1:-1:1); end
a1 = conv(up,v); a2 = conv(u,vp);
i = length(a1); j = length(a2); z = zeros(1,abs(i-j));
if i > j, a2 = [z a2]; elseif i < j, a1 = [z a1]; end
if nargout < 2, a = a1 + a2; else a = a1 - a2; end
f = find(a ~= 0);
if ~isempty(f), a = a(f(1):end); else a = zeros(superiorfloat(u,v)); end
b = conv(v,v);
f = find(b ~= 0);
if ~isempty(f), b = b(f(1):end); else b = zeros(class(v)); end
