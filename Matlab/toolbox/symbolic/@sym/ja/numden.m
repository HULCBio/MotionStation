% NUMDEN   シンボリック式の分子と分母
% [N, D] = NUMDEN(A) は、A の各要素を分子と分母が整数係数をもつ既約多項
% 式であるような有理数型に変換します。
%
% 例題 : 
%    [n,d] = numden(sym(4/5)) は、n = 4 と d = 5 を出力します。
%    [n,d] = numden(x/y + y/x) は、n = x^2+y^2 , d = y*x を出力します。



%   Copyright 1993-2002 The MathWorks, Inc.
