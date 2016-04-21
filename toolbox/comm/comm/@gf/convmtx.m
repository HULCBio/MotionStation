function out = convmtx(v,n);
%CONVMTX Convolution matrix of GF vector.
%   CONVMTX(C,N) returns the convolution matrix for GF vector C.
%   If C is a column vector and X is a column vector of length N,
%   then CONVMTX(C,N)*X is the same as CONV(C,X).
%   If R is a row vector and X is a row vector of length N,
%   then X*CONVMTX(R,N) is the same as CONV(R,X).
%
%   See also CONV.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/27 00:15:16 $ 

[mv,nv] = size(v.x);
lv = max(mv,nv);
v.x = v.x(:);		% make v a column vector
mn = lv + n - 1;	% mn == number of rows of M; n == number of columns

%  t = toeplitz([v; zeros(n-1,1)],zeros(n,1));  put Toeplitz code inline
c = [v.x; zeros(n-1,1)];
r = zeros(n,1);
m = length(c);
x = [r(n:-1:2) ; c(:)];                 % build vector of user data
%
cidx = (0:m-1)';
ridx = n:-1:1;
t = cidx(:,ones(n,1)) + ridx(ones(m,1),:);    % Toeplitz subscripts
t(:) = x(t);                             % actual data
out = v;
out.x = uint16(t);
% end of toeplitz code

if mv < nv
	out.x = out.x.';
end

