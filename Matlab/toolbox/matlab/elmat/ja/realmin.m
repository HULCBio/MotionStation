%REALMIN 正の最小浮動小数点数
% x = realmin は、稼動しているコンピュータで表現できる正の最小の正規化された
% 倍精度浮動小数点数を出力します。これより小さい値は、アンダーフロー、または、
% IEEE "denormal(異常値)" となります。
%
% REALMIN('double') は、引数なしの REALMIN と同じです。
%
% REALMIN('single') は、稼動しているコンピュータで表現できる正の最小の正規化
% された単精度浮動小数点数を出力します。
%
% 参考 EPS, REALMAX, INTMIN.

%   C. Moler, 7-26-91, 6-10-92.
%   Copyright 1984-2004 The MathWorks, Inc. 
