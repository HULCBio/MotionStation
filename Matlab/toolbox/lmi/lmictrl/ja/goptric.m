%  [gopt,X1,X2,Y1,Y2] = goptric(P,r,gmin,gmax,tol)
%
% 連続時間プラントPに対して、Riccatiベースの特性式を利用し、最適Hinf性能
% GOPTを計算します。
%
% ユーザは、この関数を直接利用しません。
%
%　出力:
%  GOPT       区間[GMIN,GMAX]での最適Hinf性能
%  X1,X2,..   gamma = GOPTに対する2つのHinfRiccati方程式の解X = X2/X1と
%             Y = Y2/Y1。(非正則問題の場合、低次元化Riccati方程式を利用)
% 
% 参考：    HINFRIC, HINFLMI.

% Copyright 1995-2001 The MathWorks, Inc. 
