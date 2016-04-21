% [gopt,K,X1,X2,Y1,Y2] = dhinflmi(P,r,gmin,tol,options)
%
% 離散時間プラントP(z)が与えられたとき、区間[GMIN,GMAX]での最適Hinf性能
% GOPTとつぎを満足するHinfコントローラK(z)を計算します。
% 
%    * プラントを内部的に安定化します。
%    * 閉ループゲインをGOPT以下にします。
% 
% DHINFLMIは、LMIベースのアプローチを実現します。
%
% GOPTのみを計算するためには、出力引数を1つだけ設定してDHINFLMIを実行し
% ます。入力引数GMIN, TOL, OPTIONSは、オプションです。
%
% P(z)に関する前提:  可安定 + 可検出
%
% 入力:
%  P          プラントのSYSTEM行列(LTISYSを参照)。
%  R          D22の次元を設定する1行2列のベクトル。すなわち、
%                      R(1) = 観測量の数
%                      R(2) = 制御量の数
%  GMIN       閉ループ性能に対してユーザが設定したターゲット。
%             GOPTを計算するには、GMIN=0と設定し、性能GAMAが達成可能かど
%             うかを調べるには、GMIN = GAMAを設定します。
%  TOL        GOPTの目標相対精度(デフォルト = 1e-2)。
%  OPTIONS    数値計算用の制御パラメータのオプションの3要素ベクトル。
%             OPTIONS(1:2): 未使用。
%             OPTIONS(3): デフォルト = 1e-3。
%                         つぎの場合、低次元化が実行されます。
%                             rho(X*Y) >=  ( 1 - OPTIONS(3) ) * GOPT^2
% 出力:
%  GOPT       最適Hinf性能。
%  K          gamma = GOPTに対するHinf中心コントローラ。
%  X1,X2,..   X = X2/X1とY = Y2/Y1は、gamma = GOPTに対する2つのHinfRic-
%             cati不等式の解です。また、R = X1とS = Y1は、X2=Y2=GOPT*eye
%             なので、特性LMIの解です。
%
% 参考：    DHINFRIC.



% Copyright 1995-2002 The MathWorks, Inc. 
