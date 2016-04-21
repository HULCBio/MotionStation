% MUSOL4 実数/複素数混合構造化特異値
%
% 概要： musol4(M), musol4(M,K), musol4(M,K,T), musol4(M,K,T,x).
%
% MUSOL4 は、以下のレポートの構造化特異値の上界を計算します。
%
% "Robustness in the Presence of Mixed Parametric Uncertainty and
% Unmodeled Dynamics," by M.K.H. Fan, A.L. Tits and J.C. Doyle, IEEE
% Transactions on Automatic Control, January 1991.
%
% MUSOL4 は、以下ノレポートの中の(改良された)内点法を使用します。
%
%     "An Interior Point Method for Solving Linear Matrix Inequality
%     Problems," by M.K.H. Fan and B. Nekooie, SIAM Journal on Control
%     and Optimization, to appear.
%
% 入力：
%  M  -  SSV の上界が計算される n 行 n 列の行列
%
% オプション入力：
%  K  -  m 行 1 列のブロック構造からなります。K(i), i = 1:m は、それぞれの
%        ブロックサイズであり、sum(K) は、n になります。デフォルトは、K = 
%        ones(n,1)です。
%  T  -  m 行 1 列のベクトルで、それぞれのブロックのタイプを示します。
%        i = 1:m に対して、
%           T(i)=1 は、対応するブロックが実数ブロックであることを示し、
%           そして、
%           T(i)=2 は、対応するブロックが複素数であることを示します。
% K(i) は、T(i) = 1 の場合、1です。デフォルトは、2*ones(length(K),1)です。
%  x  -  以前に読んだ muso14 からの情報を納めたベクトル
%
% 出力：
%     r   -  計算された上界を納めた実数スカラ
%     D,G -  n 行 n 列の以下のような、半負定の行列
%            M'*D^2*M + sqrt(-1)*(G*M-M'*G) - r^2*D^2
%            
%     x   -  行列を M に収束させるために、つぎの muso14 を呼ぶのみ使用でき
%            る情報を納めたベクトル

% Copyright 1988-2002 The MathWorks, Inc. 
