% COLLECT   係数をまとめます。
% COLLECT(S,v)は、シンボリック行列Sの各々の要素を、vの多項式とみなし、S
% をvのベキ乗の形式で書き直します。
% COLLECT(S)は、FINDSYMで決定されるデフォルト変数を使います。
%
% 例題:
%   collect(x^2*y + y*x - x^2 - 2*x)は、(y-1)*x^2+(y-2)*xを出力します。
%
%   f = -1/4*x*exp(-2*x)+3/16*exp(-2*x)
%   collect(f,exp(-2*x))は、(-1/4*x+3/16)*exp(-2*x)を出力します。
%
% 参考   SIMPLIFY, SIMPLE, FACTOR, EXPAND, FINDSYM.



%   Copyright 1993-2002 The MathWorks, Inc.
