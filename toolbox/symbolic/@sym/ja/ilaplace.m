% ILAPLACE   逆ラプラス変換
% F = ILAPLACE(L) は、デフォルトの独立変数sをもつスカラシンボリックオブ
% ジェクトLの逆ラプラス変換です。デフォルトの出力は、t の関数です。L = 
% L(t) ならば、ILAPLACE は、x の関数 F = F(x) を出力します。定義により、
% F(t) = int(L(s)*exp, (s*t), s, c-i*inf, c+i*inf) で、ここで、c は実数
% 値で、L(s) のすべての特異点がライン s = c の左側になるように選択し、
% i = sqrt(-1) で、積分は s について計算されます。
%
% F = ILAPLACE(L, y)は、デフォルトの t の代わりに、y の関数Fを計算します。
% 
%      ILAPLACE(L,y) <=> F(y) = int(L(y)*exp(s*y),s,c-i*inf,c+i*inf)
% 
% ここで、y はスカラシンボリックオブジェクトです。
%
% F = ILAPLACE(L, y, x) は、デフォルトのtの代わりに、x の関数Fを計算し、
% y について積分します。
%   
%    ILAPLACE(L,y,x) <=> F(y) = int(L(y)*exp(x*y),y,c-i*inf,c+i*inf)
%
% 例題 :
%      syms s t w x y
%      ilaplace(1/(s-1)) は、exp(t) を出力します。
%      ilaplace(1/(t^2+1)) は、sin(x) を出力します。
%      ilaplace(t^(-sym(5/2)),x) は、4/3/pi^(1/2)*x^(3/2) を出力します。
%      ilaplace(y/(y^2 + w^2),y,x) は、cos(w*x) を出力します。
%      ilaplace(sym('laplace(F(x),x,s)'),s,x) は、F(x) を出力します。
%
% 参考： LAPLACE, IFOURIER, IZTRANS.



%   Copyright 1993-2002 The MathWorks, Inc.
