% LEVINSON  Levinson-Durbin 帰納法
%
% A = LEVINSON(R,N)は、Yule-Walker AR方程式として知られる Hermition To-
% eplitz システム
%
%     [  R(1)   R(2)* ...  R(N)* ] [  A(2)  ]  = [  -R(2)  ]
%     [  R(2)   R(1)  ... R(N-1)*] [  A(3)  ]  = [  -R(3)  ]
%     [   .        .         .   ] [   .    ]  = [    .    ]
%     [ R(N-1) R(N-2) ...  R(2)* ] [  A(N)  ]  = [  -R(N)  ]
%     [  R(N)  R(N-1) ...  R(1)  ] [ A(N+1) ]  = [ -R(N+1) ]
%
% を、Levinson-Durbin 帰納法を使って解きます。入力 R は、最初の要素がゼ
% ロラグをもつ自己相関列係数(ベクトル)です。
%
% N は、自己回帰線形過程の係数です。N を省略すると、N は、N = LENGTH(R)-1
% に設定されます。A は、A(1) = 1.0をもつ長さ N+1 の行ベクトルです。
%
% [A,E] = LEVINSON(...) は、次数 N の予測誤差Eを出力します。
%
% [A,E,K] = LEVINSON(...) は、長さ N の列ベクトルをもつ反射係数 K を出力
% します。係数 A を計算する間に、K が内部で計算されるので、K を同時に出
% 力され、そのため、TF2LATC を使って、A を K に変換するよりも効率的に計
% 算されます。
%
% R が行列の場合、LEVINSON は、R の各列に対して係数を求め、Aの行ベクトル
% に出力します。
%
% 参考：   LPC, PRONY, STMCB.



%   Copyright 1988-2002 The MathWorks, Inc.
