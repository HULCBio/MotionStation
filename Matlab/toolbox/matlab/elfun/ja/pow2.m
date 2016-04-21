% POW2   底を2とした指数関数、浮動小数点数のスケーリング
% 
% X = POW2(Y)は、Yの各要素について、2.^Yである配列を出力します。
%
% X = POW2(F,E)は、実数配列Fと整数配列Eの各要素について、X = F .* (2 .^ 
% E)を計算します。その結果は、Eの浮動小数点指数にFを単に加えることで、高
% 速に計算されます。この関数は、ANSI Cの関数ldexp()と、IEEE浮動小数点標
% 準関数scalbn()に相当します。
%
% 参考：LOG2, REALMAX, REALMIN.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:50:35 $
%   Built-in function.
