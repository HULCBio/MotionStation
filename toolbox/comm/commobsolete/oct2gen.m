function [tran_func, code_param] = oct2gen(gen, code_param);
%OCT2GEN Convert an octal form of transfer function into a binary one.
%      
%WARNING: This is an obsolete function and may be removed in the future.

%       [TRAN_FUNC, CODE_PARAM] = OCT2GEN(GEN) converts an octal form of
%       transfer function matrix GEN into a binary form of transfer function
%       TRAN_FUNC. This function is designed to convert the convolution coding
%       transfer function. The input GEN is an octal form transfer function,
%       which has the structure of
%                   | g11  g12 ... g1N |
%             GEN = | ......           |
%                   | gK1  gK2 ... gKN |
%       in which gIJ is the Ith input Jth output octal form transfer function.
%       The function converts GEN into convolution code parameter CODE_PARAM =
%       [N, K, M], and convolution code transfer function TRAN_FUNC.
%       N is the output codeword length and is the number of columns of GEN. K is the
%       input message length and is the number of rows of GEN. M is the memory
%       length. The output of this function TRAN_FUNC is a K-by-N*(M+1) binary
%       matrix. TRAN_FUNC has the following form:
%                     | G11   G12  ... G1N |
%         TRAN_FUNC = | ...                |
%                     | GK1   GK2  ... GKN |
%       where Gij is a length M row vector, which is the transfer from the Ith
%       input to Jth output. 
%
%       TRAN_FUNC = OCT2GEN(GEN, CODE_PARAM) converts a binary form transfer
%       function matrix GEN into an octal form of transfer function TRAN_FUNC.
%
%       See also SIM2GEN.

%       Wes Wang 9/6/94, 10/10/95.
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.11 $

table = [0 0 0; 0 0 1; 0 1 0; 0 1 1; 1 0 0; 1 0 1; 1 1 0; 1 1 1];
if nargin < 2
    % octal to binary
    mx = max(max(gen));
    [K, N] = size(gen);

    % find the maximum size
    tmp = sprintf('%d',mx);
    tmp_size = length(tmp);

    M = tmp_size * 3;

    tran_func = zeros(K, N*M);
    for i = 1 : K
        for j = 1 : N
            tmp = sprintf('%d', gen(i, j));
            if length(tmp) < tmp_size
                tmp = [setstr(ones(1,tmp_size-length(tmp))*48), tmp];
            end;
            tt = [];
            for jj = 1 : length(tmp)
                tt = [tt, table(abs(tmp(jj)) - 47, :)];
            end;
            tran_func(i, (j - 1) * M + [1:length(tt)]) = tt;
        end;
    end;
    
    % eliminate the unnecessary length
    if K > 1
        max_tran = max(tran_func);
    else
        max_tran = tran_func;
    end;
    G = [];
    for i = 1 : M
        G = [G max_tran(i : M : M*N)];
    end;

    % the last digit
    if max(G(N * (M - 1) + 1 : N*M)) <= 0
        for i = N : -1 : 1
            tran_func(:, M*i) = [];
        end;
        M = M - 1;

        % the second last digit
        if max(G(N * (M - 1) + 1 : N*M)) <= 0
            for i = N : -1 : 1
                tran_func(:, M*i) = [];
            end;
            M = M - 1;
        end;
    end;
    M = M - 1;
    code_param = [N, K, M];
else
    % binary to octal
    N = code_param(1);
    K = code_param(2);
    M = code_param(3) + 1;
    [n_gen, m_gen] = size(gen);
    if (n_gen ~= K) | (m_gen ~= N*M)
        error('The Code parameter provided for OCT2GEN is incorrect.');
    end;
    tran_func = zeros(K, N);
    
    for i = 1 : K
        for j = 1 : N
            tmp = gen(i, (j-1)*M+1:j*M);
            tmp_rm = rem(length(tmp), 3);
            if tmp_rm > 0
                tmp = [tmp, zeros(1, 3-tmp_rm)];
            end;

            % convert binary tmp to octal number.
            tmp_oct = [];
            while length(tmp) > 0
                tmp_3 = tmp(1:3);
                tmp(1:3) = [];
                tmp_oct = [tmp_oct, setstr(tmp_3(1)*4+tmp_3(2)*2+tmp_3(3) + 48)];
            end;
            tran_func(i, j) = str2num(tmp_oct);
        end;
    end;
end;

%---end OCT2GEN.M---
