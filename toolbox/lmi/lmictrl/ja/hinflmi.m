% [gopt,K] = hinflmi(P,r)
% [gopt,K,X1,X2,Y1,Y2] = hinflmi(P,r,g,tol,options)
%
% 連続時間プラントP(s)が与えられたとき、最適Hinf性能GOPTと、つぎを満足す
% るHinfコントローラK(s)を計算します。
% 
%    * プラントを内部的に安定化します。
%    * 閉ループゲインをGOPT以下にします。
% 
% HINFLMIは、LMIベースのアプローチを実現します。
%
% GOPTのみを計算するためには、出力引数を1つだけ設定してHINFLMIを実行しま
% す。入力引数G, TOL, OPTIONSは、オプションです。
%
% 入力:
%  P          プラントのSYSTEM行列(LTISYSを参照)。
%  R          D22の次元を設定する1行2列ベクトル。すなわち、
%                      R(1) = 観測量の数
%                      R(2) = 制御量の数
%  G          閉ループ性能に対してユーザが設定したターゲット。
%             GOPTを計算するには、G=0と設定し、性能GAMMAが達成可能かどう
%             かを調べるには、G=GAMMAと設定します。
%  TOL        GOPTの目標相対精度(デフォルト=1e-2)。
%  OPTIONS    数値計算用の制御パラメータのオプションの3要素ベクトル。
%             OPTIONS(1): [0,1]内の値(デフォルト=0)。この値を大きくする
%             と、Rのノルムは小さくなり、応答の遅いダイナミクスをもつコ
%             ントローラになります。
%             OPTIONS(2): Sと同じ。
%             OPTIONS(3): デフォルト = 1e-3。
%                         つぎの場合、低次元化が実行されます。
%                             rho(X*Y) >=  ( 1 - OPTIONS(3) ) * GOPT^2
% 出力:
%  GOPT       最適Hinf性能。
%  K          gamma = GOPTに対するHinf中心コントローラ。
%  X1,X2,..   X = X2/X1とY = Y2/Y1は、gamma = GOPTに対する2つのHinfRic-
%             cati 不等式の解です。また、R = X1とS = Y1は、X2=Y2=GOPT*eye
%             なので、特性LMIの解です。
%
% 参考：    HINFRIC, HINFMIX, HINFGS.



% Copyright 1995-2002 The MathWorks, Inc. 
