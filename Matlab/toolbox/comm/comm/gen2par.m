function h = gen2par(g);
%GEN2PAR Convert between parity-check and generator matrices.
%   H = GEN2PAR(G) computes parity-check matrix H from the standard form of a
%   generator matrix G. The function can also used to convert a parity-check
%   matrix to a generator matrix. The conversion is used in GF(2) only.
%
%   See also CYCLGEN, HAMMGEN.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.12 $   $Date: 2002/03/27 00:05:36 $

[n,m] = size(g);
if n >= m
    error('The input for GEN2PAR is not the standard form of a generator or parity-check matrix.')
end;

I = eye(n);
if isequal(g(:, 1:n), I)
    h = [g(:,n+1:m)' eye(m-n)];
elseif isequal(g(:, m-n+1:m), I)
    h = [eye(m-n) g(:,1:m-n)'];
else
    error('The input for GEN2PAR is not the standard form of a generator or parity-check matrix.')
end;

%--end of GEN2PAR
