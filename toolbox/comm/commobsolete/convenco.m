function code = convenco(msg, tran_func);
%CONVENCO Encodes convolution code.
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use CONVENC instead.

%       CODE = CONVENCO(MSG, TRAN_FUNC) encodes the K-column message MSG to
%       N-column code word CODE by using the convolution code method. The
%       transfer function matrix is provided in state system form.
%
%       The column number of the input MSG should be K. The column number of
%       the output CODE is N. The row number of CODE is row_number_of_MSG+M,
%       where M is the memory length.
%       
%       See also ENCODE, DECODE.

%       Wes Wang 10/2/95.
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.14 $

% routine check
if nargin < 2
    error('Not enough input parameters.')
end;

if isstr(tran_func)
    tran_func = sim2tran(tran_func);
end;

[A, B, C, D, N, K, M] = gen2abcd(tran_func);

[n_msg, m_msg] = size(msg);
state = zeros(M, 1);

if m_msg ~= K
    error('The message dimension does not match CODE_PARAM');
end;

code = zeros(n_msg+M, N);
if isempty(C)
    msg_i = bi2de(msg);
    state = 0;
    K2 = 2^M;
    for i = 1 : n_msg
        tran_indx = state +1 + K2 * msg_i(i);
        code(i, :) = B(tran_indx, :);
        state = tran_func(tran_indx+2, 1);
    end;
    for i = 1 : M
        tran_indx = state + 1;
        code(n_msg+i, :) = B(tran_indx, :);
        state = tran_func(tran_indx+2, 1);
    end;
else
    for i = 1:n_msg
        code(i, :) = (C * state + D * msg(i, :)')';
        state = rem(A * state + B * msg(i, :)', 2);
    end;
    for i = 1 : M
        code(n_msg+i, :) = (C * state)';
        state = rem(A * state, 2);
    end;
end;
code = rem(code,2);

