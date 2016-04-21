% COVAR   LTIモデルの白色ノイズ入力に対する応答の共分散
%
% P = COVAR(SYS,W) は、LTIモデル SYS がガウス分布する白色ノイズ入力に
% よって励起されとき、出力共分散 P = E[yy'] を計算します。ノイズの大きさ 
% W は、連続系のとき、
% 
%   E[w(t)w(tau)'] = W delta(t-tau)  (delta(t) = Dirac delta)
%
% で、離散系のときは、
%
%   E[w(k)w(n)'] = W delta(k,n)  (delta(k,n) = Kronecker delta)
%
% で定義されます。不安定なシステムやゼロでない直達項をもつ連続時間モデル
% は、無限大の出力共分散になることに注意してください。
%
% [P,Q] = COVAR(SYS,W) は、SYS が状態空間モデルの場合、状態共分散 
% Q = E[xx'] も出力します。
%
% SYS が、[NY NU S1 ... Sp] の次元をもつLTIモデルの配列の場合、配列 P 
% は、[NY NY S1 ... Sp] の次元をもち
% 
%   P(:,:,k1,...,kp) = COVAR(SYS(:,:,k1,...,kp))
% 
% です。
%
% 参考 : LTIMODELS, LYAP, DLYAP.


%   Clay M. Thompson  7-3-90
%       Revised by Wes Wang 8-5-92
%       P. Gahinet  7-22-96
%   Copyright 1986-2002 The MathWorks, Inc. 
