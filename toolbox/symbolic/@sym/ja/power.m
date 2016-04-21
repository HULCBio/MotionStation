% POWER   シンボリックな配列のベキ乗
% POWER(A, p) は、シンボリックな A.^p をオーバロードします。
%
% 例題 :
%    A = [x 10 y; alpha 2 5];
%    A .^ 2 は、[x^2 100 y^2; alpha^2 4 25] を出力します。
%    A .^ x は、[x^x 10^x y^x; alpha^x 2^x 5^x] を出力します。
%    A .^ A は、[x^x 1.0000e+10 y^y; alpha^alpha 4 3125] を出力します。
%    A .^ [1 2 3; 4 5 6] は、[x 100 y^3; alpha^4 32 15625] を出力します。
%    A .^ magic(3) は、エラーです。



%   Copyright 1993-2002 The MathWorks, Inc.
