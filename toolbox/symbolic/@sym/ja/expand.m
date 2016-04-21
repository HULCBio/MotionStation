% EXPAND   シンボリックな展開
% EXPAND(S)は、シンボリック式Sの各々の要素を因数の積として書き出します。
% EXPANDは、主に多項式を展開しますが、三角関数や指数関数、対数関数のよう
% な数学関数も展開します。
%
% 例題 :
% 
%      expand((x+1)^3)は、x^3+3*x^2+3*x+1を出力します。
%      expand(sin(x+y))は、sin(x)*cos(y)+cos(x)*sin(y)を出力します。
%      expand(exp(x+y))は、exp(x)*exp(y)を出力します。
%
% 参考   SIMPLIFY, SIMPLE, FACTOR, COLLECT.



%   Copyright 1993-2002 The MathWorks, Inc.
