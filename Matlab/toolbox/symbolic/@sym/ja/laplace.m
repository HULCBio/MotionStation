% LAPLACE   ラプラス変換
% L = LAPLACE(F) は、デフォルトの独立変数 t をもつスカラシンボリックオブ
% ジェクトF のラプラス変換です。デフォルトの出力は、s の関数です。F = F
% (s) ならば、LAPLACE は、t の関数 L = L(t) を出力します。
% 
% 定義により、L(s) = int(F(t)*exp(-s*t),0,inf) で、t について積分されま
% す。
%
% L = LAPLACE(F, t) は、デフォルトの s の代わりに、t の関数Lを計算します。
% 
%      LAPLACE(F,t) <=> L(t) = int(F(x)*exp(-t*x),0,inf)
%
% L = LAPLACE(F, w, z) は、デフォルトの s の代わりに、z の関数Lを計算し
% ます(w について積分します)。
%   
%     LAPLACE(F,w,z) <=> L(z) = int(F(w)*exp(-z*w),0,inf)
%
% 例題 :
%      syms a s t w x
%      laplace(t^5) は、120/s^6 を出力します。
%      laplace(exp(a*s)) は、1/(t-a) を出力します。
%      laplace(sin(w*x),t) は、w/(t^2+w^2) を出力します。
%      laplace(cos(x*w),w,t) は、t/(t^2+x^2) を出力します。
%      laplace(x^sym(3/2),t) は、3/4*pi^(1/2)/t^(5/2) を出力します。
%      laplace(diff(sym('F(t)'))) は、laplace(F(t),t,s)*s-F(0) を出力し
%      ます。
%
% 参考： ILAPLACE, FOURIER, ZTRANS.



%   Copyright 1993-2002 The MathWorks, Inc.
