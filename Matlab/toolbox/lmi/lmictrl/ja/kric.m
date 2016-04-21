% [K,gfin]=kric(P,r,gama,X1,X2,Y1,Y2,tolred)
%
% 標準の連続時間プラントP(s)を与え、GAMA > 0のときに、中心Hinfコントロー
% ラK(s)を計算します。このコントローラは、つぎを満足します。
% 
%   * プラントを内部的に安定化します。
%   * 閉ループゲインをGAMA以下にします。
% 
% K(s)は、2つのHinfRiccati方程式の安定化解X=X2/X1とY=Y2/Y1から計算されま
% す。
%
% 入力:
%  P           プラントのSYSTEM行列(LTISYSを参照)。
%  R           D22のサイズ、すなわち、R = [ NY , NU ]。ここで、
%                     NY = 観測量の数
%                     NU = 制御量の数
%  GAMA        要求されるHinf性能。
%  X1,X2,...   X = X2/X1とY = Y2/Y1は、2つのHinfRiccati方程式の安定化解
%              です。
%  TOLRED      オプション(デフォルト値= 1.0e-4)。
%              つぎの場合、低次元化が達成されます。
%              rho(X*Y) >=  (1 - TOLRED) * GAMA^2
% 出力:                                                              
%  K           SYSTEM行列形式の中心コントローラ
%                                        -1
%                   K(s) = DK + CK (sI-AK)  BK
%  GFIN        保証された閉ループ性能
%              (GAMAは、数値的安定性の理由により、GFIN > GAMAにリセット
%              されることがあります)
%
% 参考：    HINFRIC.



% Copyright 1995-2002 The MathWorks, Inc. 
