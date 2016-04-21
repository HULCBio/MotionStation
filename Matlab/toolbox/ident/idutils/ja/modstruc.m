% MODSTRUC は、MS2TH の中で使われるモデル構造を作成します。
% 
%   MS = MODSTRUC(A,B,C,D,K,X0)
%
%   MS = 結果として出力するモデル構造
%   A,B,C,D,K,X0 は、状態空間モデルの行列です。
%
%   xnew = A x(t) + B u(t) + K e(t)
%   y(t) = C x(t) + D u(t) + e(t)
%
% ここで、xnew は、x(t+T)、または、dx(t)/dt です。X0 は、初期状態です。
%
% これらの行列の要素の中で固定するものは数値で設定し、推定するものは NaN
% で設定します。
% 
% 例題： A=[0 1;NaN NaN].
%        X0 のデフォルト値は、ゼロです。
%  
% 参考： CANFORM, MS2TH.

%   Copyright 1986-2001 The MathWorks, Inc.
