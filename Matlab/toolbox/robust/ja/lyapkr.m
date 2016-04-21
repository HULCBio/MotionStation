% LYAPKR は、Lyapunov/Sylvester 方程式のソルバ (クロネッカ積を使ったアプロ
%        ーチ)
%
% [X] = LYAPKR(A,B,C) は、Lyapunov、または、Sylvester 方程式の解を算出しま
% す。
% 
% アルゴリズムは、特別な種類の単純なクロネッカ積を使います。
%
%        A1*X*B1 + A2*X*B2 + A3*X*B3 + ... = Ck
%
% 解は、つぎのようになります。
%
%        [KRON(A1,B1') + KRON(A2,B2') + ... ] * S[X] = S(Ck)
%
% Lyapunov、または、Sylvester 方程式に対して、つぎの型をしています。
%
%            A1 = A,  B1 = I,  A2 = I, B2 = B,  Ck = -C.
%
% ここで、つぎの関係が成り立っています。  A * X + X * B + C = 0
%

% Copyright 1988-2002 The MathWorks, Inc. 
