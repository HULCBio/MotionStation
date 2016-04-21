% LYAP   連続時間の Lyapunov 方程式を解きます
%
%
% X = LYAP(A,Q)は、つぎの Lyapunov 行列方程式を解きます。
%
%   A*X + X*A' + Q = 0
%
% X = LYAP(A,B,C) は、Sylvester 方程式を解きます。
%
%   A*X + X*B + C = 0
%
% X = LYAP(A,Q,[],E) は、一般化された Lyapunov 方程式を解きます。
%
%   A*X*E' + E*X*A' + Q = 0    ここで、 Q は、対称です。
%
% 参考 : LYAPCHOL, DLYAP.


% Copyright 1986-2002 The MathWorks, Inc.
