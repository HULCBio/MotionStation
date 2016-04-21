% [gopt,K,X1,X2,Y1,Y2] = dhinfric(P,r,gmin,gmax,tol,options)
%
% 離散時間プラントP(z)に対して、区間[GMIN,GMAX]での最適Hinf性能GOPTと、
% つぎを満足するHinf中心コントローラK(s)を計算します。
% 
%    * プラントを内部的に安定化します。
%    * 閉ループゲインをGOPT以下にします。
% 
% DHINFRICは、Riccatiベースのアプローチを実現します。
%
% GOPTのみを計算するためには、出力引数を1つだけ設定してDHINFRICを実行し
% ます。入力引数GMIN, GMAX, TOL, OPTIONSは、まとめて省略することができま
% す。
%
% P(z)に関する前提:  可安定/可検出、D12とD21はフルランク。
%
% 入力:
%  P          プラントのSYSTEM行列(LTISSを参照)。
%  R          D22の次元を設定する1行2列のベクトル。すなわち、
% 
%                      R(1) = 観測量の数
%                      R(2) = 制御量の数
% 
% GMIN,GMAX  GOPTの境界。そのような境界を設定しないためには、GMIN = GMAX
%            = 0と設定します。値GAMAが可解であるかどうかをテストするため
%            には、GMIN = GMAX = GAMAと設定します。
%  TOL        GOPTの目標相対精度(デフォルト = 1e-2)。
%  OPTIONS    数値計算用の制御パラメータのオプションの3要素ベクトル
%             OPTIONS(1): 未使用。
%             OPTIONS(2): 区間[0,1]の値で、デフォルト=0です。値が大きい
%             ほど、単位円のゼロの面での閉ループ減衰が良くなります。
%             OPTIONS(3): デフォルト=1e-3。
%                         つぎの場合、低次元化が実行されます。
%                             rho(X*Y) >=  ( 1 - OPTIONS(3) ) * GOPT^2
% 出力:
%  GOPT       区間[GMIN,GMAX]での最適Hinf性能。
%  K          gamma = GOPTに対するHinf中心コントローラ。
%  X1,X2,..   X = X2/X1とY = Y2/Y1は、gamma = GOPTに対する2つのHinfRic-
%             cati方程式の解です。
%
% 参考：    DHINFLMI.



% Copyright 1995-2002 The MathWorks, Inc. 
