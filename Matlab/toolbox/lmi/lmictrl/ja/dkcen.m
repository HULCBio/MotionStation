%  [K,gfin]=dkcen(P,r,gama,X1,X2,Y1,Y2,tolred)
%
% 離散時間プラントPを与え、GAMA > 0のとき、DKCENは、つぎのような中心Hinf
% ディジタルコントローラK(s)を計算します。
% 
%   * プラントを内部的に安定化します。
%   * 閉ループゲインを GAMA 以下にします。
% 
% このコントローラは、2つのHinfRiccati方程式の安定化解X,Y(古典的なアプロ
% ーチ)、または、Ricati不等式の解X,Y(LMIアプローチ)を使って計算されます。
%
% 入力:
%  P         プラントのSYSTEM行列(LTISYSを参照)。
%  R         D22のサイズ、すなわち、R = [ NY , NU ]です。ここで、
%                   NY = 観測量の数
%                   NU = 制御量の数
%  GAMA      要求されるHinf性能。
%  X1,X2,..  Riccatiアプローチ: X = X2/X1とY = Y2/Y1は、2つのRiccati方程
%            式の安定化解です。
%            LMIアプローチ    : X = X2/X1とY = Y2/Y1は、2つのHinfRicca-
%                               ti不等式の解です。
%  TOLRED    オプション(デフォルト値=1.0e-4)。
%            つぎの場合、低次元化が実行されます。
%                    rho(X*Y) >=  (1 - TOLRED) * GAMA^2
% 出力:                                                              -1
%  K         パックされた形式の中心コントローラK(s) = DK + CK (zI-AK)  BK
%  GFIN      保証された閉ループ性能(GAMAは、数値の安定の理由により、
%            GFIN > GAMA にリセットされます)。
%
% 参考：    DHINFRIC.



% Copyright 1995-2002 The MathWorks, Inc. 
