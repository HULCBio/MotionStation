% LYAPCHOL  連続時間の Lyapunov 方程式に対する平方根ソルバ
%
%
% R = LYAPCHOL(A,B) は、Lyapunov 行列方程式に対する解 X のコレスキー分解 
% X = R'*R を計算します。
%
%   A*X + X*A' + B*B' = 0
%
% A のすべての固有値は、R の開左半平面になければなりません。
%
% R = LYAPCHOL(A,B,E) は、一般化された Lyapunov方程式を解く、X のコレスキー
% 分解 X = R'*R を計算します。
%
%    A*X*E' + E*X*A' + B*B' = 0
%
% (A,E) のすべての一般化された固有値は、R の開左半平面になければなりません。
%
% 参考 : LYAP, DLYAPCHOL.


% Copyright 1986-2002 The MathWorks, Inc.
