%  [gopt,X1,X2,Y1,Y2] = goptlmi(P,r,gmin,tol,options)
%
% 連続時間(アナログ)プラントPに対して、LMIに基づく準最適問題を利用して、
% 最適Hinf性能GOPTを計算します。
%
% ユーザは、この関数を直接利用しません。
%
%　出力:
%  GOPT       区間[GMIN,GMAX]での最適Hinf性能
%  X1,X2,..   gamma = GOPTに対する2つのHinfRiccati不等式の解X = X2/X1と
%             Y = Y2/Y1。等価的に、R = X1とS = Y1は、X2=Y2=GOPT*eyeとな
%             る特性LMIの解です。
%
% 参考：    HINFLMI, KLMI.

% Copyright 1995-2001 The MathWorks, Inc. 
