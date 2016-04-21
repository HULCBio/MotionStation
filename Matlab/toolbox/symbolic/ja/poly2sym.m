% POLY2SYM   多項式係数ベクトルのシンボリックな多項式への変換
% POLY2SYM(C) は、ベクトル C で定義される係数をもつ 'x' についてのシンボ
% リック多項式です。
% 
% POLY2SYM(C, 'V') と POLY2SYM(C, SYM('V'))は、2番目の引数で設定されたシ
% ンボリック変数を使います。
% 
% 例題:
% 
%      poly2sym([1 0 -2 -5])
% 
% は、つぎの結果を出力します。
% 
%       x^3-2*x-5
%       poly2sym([1 0 -2 -5],'t')
% 
% と
% 
%       t = sym('t')
%       poly2sym([1 0 -2 -5],t)
% 
% は、両方共、つぎの結果を出力します。
% 
%       t^3-2*t-5
%
% 参考： SYM2POLY, POLYVAL.



%   Copyright 1993-2002 The MathWorks, Inc. 
