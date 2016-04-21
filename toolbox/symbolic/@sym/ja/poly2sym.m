% POLY2SYM   多項式係数ベクトルのシンボリック多項式への変換
% POLY2SYM(C, V) は、ベクトル C で定義される係数をもつシンボリック変数 V
% の多項式を出力します。
% 
% 例題:
%       x = sym('x');
%       poly2sym([1 0 -2 -5],x)
% 
% は、つぎの結果を出力します。
% 
%       x^3-2*x-5
%
% 参考： SYM2POLY, POLYVAL.



%   Copyright 1993-2002 The MathWorks, Inc.
