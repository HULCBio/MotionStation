function [a, b, c, d, N, K, M] = gen2abcd(gen, code_param)
%GEN2ABCD Convert a convolution generator function into [A, B, C, D] form.
%
%WARNING: This is an obsolete function and may be removed in the future.

%   [A, B, C, D] = GEN2ABCD(GEN) converts the generator function provided
%   in GEN, either the binary form of output from SIM2GEN2 or the OCT form
%   output from SIM2GEN into the binary state form [A, B, C, D]. The state
%   form of the generating function is
%       x(k+1) = A x(k) + B u(k)
%       y(k)   = C x(k) + D u(k)
%   For the octal form GEN, the realization may not be the minimum degree
%   realization.
%
%   [A, B, C, D] = GEN2ABCD(TRAN_FUNC, CODE_PARAM) converts the binary
%   transfer function TRAN_FUNC with CODE_PARAM=[N,K,M] into [A,B,C,D]
%   format. N is the output codeword length, K is the input messsage
%   length, and M is the state vector length. The output of this function
%   is a K-by-N*(M+1) binary matrix.
%   TRAN_FUNC has the following form:
%                     | G11   G12  ... G1N |
%         TRAN_FUNC = | ...                |
%                     | GK1   GK2  ... GKN |
%   where Gij is a length M row vector, which is the transfer from the Ith
%   input to Jth output. 
%
%   [A, B, C, D, N, K, M] = GEN2ABCD(....) outputs the codeword length N,
%   message length K, and memory length M.
%
%
%   See also OCT2GEN, SIM2GEN, SIM2GEN2.

%       Wes Wang 12/5/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.16 $

if nargin < 1
    error('Not enough input variables.')
end;

if nargin < 2
    if isstr(gen)
        gen = sim2tran(gen);
    end;
    [len_m, len_n] = size(gen);
    if gen(len_m, len_n) < 0
        N = gen(1, len_n);
        K = gen(2, len_n);
        M = gen(3, len_n);
        if (M+K > len_n) | (M+N > len_m)
            error('The Transfer function is invalid.');
        end;
        a = gen(1:M, 1:M);
        b = gen(1:M, M+1:M+K);
        c = gen(M+1:M+N, 1:M);
        d = gen(M+1:M+N, M+1:M+K);
    elseif max(max(gen)) == Inf
        if nargout == 1
            a = gen;
        elseif nargout > 1
            M = gen(2, 1);
            N = gen(1, 2);
            K = gen(2, 2);
            a = de2bi(gen(3:len_m, 1), M);
            b = de2bi(gen(3:len_m, 2), N);
            c = [];
            d = [];
        end;
        return;
    else
        [gen, code_param] = oct2gen(gen);
        [a, b, c, d, N, K, M] = gen2abcd(gen, code_param);
    end;
else
    N = code_param(1);
    K = code_param(2);
    M = code_param(3);
    G = [];
    for i = 1 : M+1
        G = [G ; gen(:, i:M+1:N*(M+1))];
    end;

    a = eye(K * (M-1));
    a = [zeros(K, K), zeros(K, length(a)); a, zeros(length(a), K)]; 

    % B matrix:
    b = [eye(K); zeros(length(a)-K, K)];

    % C matrix
    c = [];
    for i = 1 : M
        c = [ c, G(i*K + 1 : (i + 1) * K, :)'];
    end;
    
    % D matrix
    d = G(1:K, :)';
%    end;
    M = length(a);
end;

if nargout == 1
    tran_func = [a b; c d];
    [len_m, len_n] = size(tran_func);
    if len_m < 4
        tran_func = [tran_func; zeros(4-len_m, len_n)];
        [len_m, len_n] = size(tran_func);
    end;
    tran_func = [tran_func zeros(len_m, 1)];
    len_n = len_n + 1;
    tran_func(1, len_n) = N;
    tran_func(2, len_n) = K;
    tran_func(3, len_n) = M;
    tran_func(len_m, len_n) = -Inf;
    a = tran_func;
end;
