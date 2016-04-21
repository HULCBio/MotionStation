%  [gopt,X1,X2,Y1,Y2] = dgoptric(P,r,gmin,gmax,tol)
%
% 正則な離散時間プラントP(z)に対して、Riccatiベースの特性式を利用し、最
% 適Hinf性能 GOPTを計算します。
%
% ユーザは、この関数を直接利用しません。
%
% 出力:
%  GOPT        間隔[GMIN,GMAX]での最適Hinf性能
%  X1,X2,..    gamma = GOPTに対する2つのHinfRiccati方程式の解
%              X = X2/X1とY = Y2/Y1。
%
% 参考：    DHINFRIC, DKCEN.

% Copyright 1995-2001 The MathWorks, Inc. 
