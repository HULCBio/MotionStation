function [pg, t] = rspoly(n, k, tp)
%RSPOLY
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use RSGENPOLY instead.

%RSPOLY Produce Reed-Solomon code generator polynomial.
%   Pg = RSPOLY(N, K) outputs the generator polynomial of Reed-Solomon
%   code with codeword length N and message length K. N must be
%   2^M-1, where M is an integer no less than 3. K should be an odd
%   positive number. The error-correction capability is (N - K) / 2. The
%   output Pg is a polynomial in GF(2^M). Each element is represented in
%   exponential format. 
%
%   Pg = RSPOLY(N, K, M) is the same as Pg = RSPOLY(2^M-1, K), but faster. 
%
%   Pg = RSPOLY(N, K, TP) produces generator polynomials using the
%   specified list of GF(2^M) elements. TP is an (N+1)-by-M matrix that 
%   lists all the elements in GF(2^M), arranged relative to the same 
%   primitive element. TP can be generated using 
%   TP = gftuple([-1:2^M-2]', M, 2);
%   This syntax is faster than the first syntax listed.
%
%   [Pg, T] = RSPOLY(...) outputs the error-correction capability of the
%   Reed-Solomon code.
%
%   See also ENCODE, DECODE, RSENCO, RSDECO.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.15 $   $Date: 2002/03/27 00:17:40 $ 

error(nargchk(2,3,nargin));

if nargin < 3
    % find the m from n
    dim = 3;
    pow_dim = 2^dim -1;
    while pow_dim < n
        dim = dim + 1;
        pow_dim = 2^dim - 1;
    end;
    tp = gftuple([-1:n-1]',dim);
else
    if length(tp) == 1
        dim = tp;
        tp = gftuple([-1:n-1]',dim);
    end
    [n_tp, dim] = size(tp);
    if n_tp ~= n+1
        error('The input parameters N and TP are inconsistent.');
    end;
    pow_dim = 2^dim - 1;
end;

if n ~= pow_dim
    error('The code word length N must be 2^M-1, where M is an integer.');
end;

if (floor(n) ~= n) | (floor(k) ~= k)
    error('N and K must be integers.')
end;

t2 = n - k;

%%% find the generator polynomial by multiplying
% g(X) = (X + alpha)(X + alpha^2)(X + alpha^3)...(X + alpha^(2t-1))(X + alpha^(2t))
%      = g_0 + g_1 X + g_2 X^2 + ... + g_(2t - 1) X^(2t - 1) + X^2t
%
% using the algorithm used in poly
pg = [0, -ones(1, t2)];
alpha = [1 : t2];
for i = 1 : t2
    pg(2:(i+1)) = gfadd(pg(2:(i+1)), gfmul(pg(1:i), alpha(i)*ones(1,i), tp), tp);
end;
pg = fliplr(pg);
% finished building pg

% error-correction capability
t = floor(t2/2);
