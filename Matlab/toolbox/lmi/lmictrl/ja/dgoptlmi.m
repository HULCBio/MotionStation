%  [gopt,X1,X2,Y1,Y2] = dgoptlmi(P,r,gmin,tol,options)
%
% 離散時間プラントP(z)に対して、LMIに基づく準最適問題を利用し、最適Hinf
% 性能GOPTを計算します。
%
% USERは、この関数を直接利用しません。
%
% 出力:
%  GOPT        間隔[GMIN,GMAX]での最適Hinf性能
%　X1,X2,..    gamma = GOPTに対する2つのHinfRiccati不等式の解 X = X2/X1
%              とY = Y2/Y1。R = X1とS = Y1は、X2=Y2=GOPT*eyeとなる特性
%              LMIの解です。
%
% 参考：    DHINFLMI, DKCEN.

% Copyright 1995-2001 The MathWorks, Inc. 
