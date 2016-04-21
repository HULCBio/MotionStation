% HORZCAT は、IDPOLY モデルの水平連結を行います。
%
% MOD = HORZCAT(MOD1,MOD2,...) は、つぎの連結演算を実行します。
% 
%         MOD = [MOD1 , MOD2 , ...]
% 
% この演算は、モデル MOD1 の出力を MOD2 の入力に繋ぎ、MOD2 の出力を MOD3
% の入力に繋ぎ...を行います。
% 
% モデルは、まず、Output 誤差タイプに変換し、ノイズプロパティをカバーし
% ないようにします。また、共分散情報も失われます。
% 
% 参考： VERTCAT 



%   Copyright 1986-2001 The MathWorks, Inc.
