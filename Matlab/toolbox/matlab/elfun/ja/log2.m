% LOG2   2を底とした対数と浮動小数値の分解
% 
% Y = LOG2(X)は、Xの要素の2を底とした対数を出力します。
%
% 実数配列Xの各要素に対して、 [F,E] = LOG2(X)は、通常0.5 < =  abs(F) < 1
% である実数配列Fと、整数の配列Eを出力し、これらの関係は、X = F .* 2.^E
% になります。Xの要素にゼロがあると、F = 0かつE = 0になります。これは、
% ANSI Cの関数frexp()や、IEEEの浮動小数点標準の関数logb()に相当します。
%
% 参考：LOG, LOG10, POW2, NEXTPOW2, REALMAX, REALMIN.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:50:31 $
%   Built-in function.
