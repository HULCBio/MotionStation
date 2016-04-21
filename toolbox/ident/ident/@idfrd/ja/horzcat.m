% HORZCAT は、IDFRD モデルの水平連結を行います。
%
%   M = HORZCAT(M1,M2,...) は、つぎの連結演算を実行します。
%         M = [M1 , M2 , ...]
% 
% この演算は、IDFRD モデル M1 の出力を M2 の入力に繋ぎ、M2 の出力を M3
% の入力に繋ぎ...を行います。このモデルは、各出力が同じサイズである必要
% があり、同じ周波数で定義されている必要があります。
% 
% SpectrumData は無視され、M は、SpectrumData を含んでいません。
% 
% 参考： IDFRD/VERTCAT



%   Copyright 1986-2001 The MathWorks, Inc.
