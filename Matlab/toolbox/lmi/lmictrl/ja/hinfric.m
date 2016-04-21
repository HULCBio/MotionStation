% [gopt,K] = hinfric(P,r)
% [gopt,K,X1,X2,Y1,Y2,Preg] = hinfric(P,r,gmin,gmax,tol,options)
%
% 連続時間プラントP(s)に対して、区間[GMIN,GMAX]での最適Hinf性能GOPTと、
% つぎを満足するHinf中心コントローラK(s)を計算します。
% 
%    * プラントを内部的に安定化します。
%    * 閉ループゲインをGOPT以下にします。
% 
% HINFRICは、Riccatiベースのアプローチを実現します。プラントは、必要なら
% ば正規化されます。
%
% GOPTのみを計算するためには、出力引数を1つだけ設定してHINFRICを実行しま
% す。入力引数GMIN, GMAX, TOL, OPTIONSは、まとめて省略することができます。
%
% 入力:
%  P          プラントのSYSTEM行列(LTISYSを参照)。
%  R          D22の次元を設定する1行2列ベクトル。すなわち、
%                   R(1) = 観測量の数(Kの入力)
%                   R(2) = 制御量の数(Kの出力)
%  GMIN,GMAX  GOPTの境界。この境界を設定しないためには、GMIN = GMAX = 0
%             と設定します。値GAMAが可解であるかどうかをテストするには、
%             GMIN = GMAX = GAMAと設定します。
%  TOL        GOPTの目標相対精度(デフォルト = 1e-2)。
%  OPTIONS    数値計算用の制御パラメータのオプションの3要素ベクトル。
%             OPTIONS(1): 区間[0,1]内の値で、デフォルト=0です。値が大き
%                         いほど、コントローラの状態空間行列のノルムは小
%                         さくなります。
%             OPTIONS(2): 区間[0,1]内の値で、デフォルト=0です。値が大き
%                         いほど、jw軸の面のゼロにおける閉ループの減衰は
%                         良くなります。
%             OPTIONS(3): デフォルト=1e-3。
%                         つぎの場合、低次元化が実行されます。
%                         rho(X*Y) >=  ( 1 - OPTIONS(3) ) * GOPT^2
% 出力:
%  GOPT       区間[GMIN,GMAX]での最適Hinf性能。
%  K          gamma = GOPTに対するHinf中心コントローラ。
%  X1,X2,..   X = X2/X1とY = Y2/Y1は、gamma = GOPTに対する2つのHinfRic-
%             cati方程式の解です。
%  PREG       P(s)が特異ならば、正規化されたプラント
%
% 参考：    HINFLMI, DHINFRIC.



% Copyright 1995-2002 The MathWorks, Inc. 
