function [h, g, k] = cyclgen(n, p, opt)
%CYCLGEN Produce parity-check and generator matrices for cyclic code.
%   H = CYCLGEN(N, P) produces the parity-check matrix for a given codeword
%   length N and generator polynomial P. The vector P gives the binary
%   coefficients of the generator polynomial in order of ascending powers. A
%   polynomial can generate a cyclic code if and only if it is a factor of
%   X^N-1. The message length of the code is K = N - M, where M is the degree
%   of P. The parity-check matrix is an M-by-N matrix.
%
%   H = CYCLGEN(N, P, OPT) produces the parity-check matrix based on the
%   instruction given in OPT. When OPT = 'nonsys', the function produces a
%   nonsystematic cyclic parity-check matrix; OPT = 'system', the function
%   produces a systematic cyclic parity-check matrix.  This option is the
%   default.
%
%   [H, G] = CYCLGEN(...) produces the parity-check matrix H as well as the
%   generator matrix G. The generator matrix is a K-by-N matrix, where
%   K = N - M;
%
%   [H, G, K] = CYCLGEN(...) produces the message length K.
%
%   See also ENCODE, DECODE, CYCLPOLY.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.3 $

error(nargchk(2,3,nargin));

if nargin < 3
    opt = 'system';
else
    opt = lower(opt);
end;

p = p(:)';
m = length(p) - 1;
k = n - m;

% Check the P paramter. P cannot be zero if it is not a polynomial.
if(length(p)==1&p==0)
    error('Invalid generator polynomial specified.');
end

% Verify that the polynomial is irreducible.
[pc, r] = gfdeconv([1 zeros(1, n-1) 1], p);
if max(r) ~= 0
    error('The generator polynomial P cannot produce a cyclic code generator matrix.');
end;

if ~isempty(findstr(opt, 'no'))
    % generate the regular cyclic code matrices

    % parity-check matrix
    tmp = [fliplr(pc), zeros(1, n-k-1)];
    h = [];
    for i = 1 : n-k
        h = [h; tmp];
        tmp = [tmp(n), tmp(1:n-1)];
    end;

    % generator matrix
    if nargin > 1
        tmp = [p(:)', zeros(1,n-m-1)];
        g = [];
        for i=1:k
            g = [g; tmp];
            tmp = [tmp(n), tmp(1:n-1)];
        end;
    end;

else
    % generate systematic cyclic code matrices

    % parity-check matrix
    b = [];
    for i = 0 : k-1
        [q, tmp] = gfdeconv([zeros(1, n-k+i), 1], p);
        tmp = [tmp zeros(1, m-length(tmp))];
        b = [b; tmp];
    end;
    h = [eye(n-k), b'];

    % generator matrix
    g = [b eye(k)];

end

%--end of cyclgen--
