% INTERP1Q   高速1次元線形補間
% 
% F = INTERP1Q(X,Y,XI) は、線形補間を使って点 XI での1次元関数 Y の値を
% 出力します。Length(F) = length(XI) です。ベクトル X は、区間の座標を
% 指定します。
% 
% Y が行列の場合は、補間は Y の各列に対して実行され、F は length(XI)行
% size(Y,2)列になります。
%
% X の座標外の XI の値に対しては、NaNが出力されます。
%
% INTERP1Q は入力チェックを行わないので、等間隔でないデータに対しては、
% INTERP1 よりも高速です。INTERP1Q が適切に機能するためには、
% X は、単調増加の列ベクトルでなければなりません。
% Y は、列ベクトルまたは length(x) 行の行列でなければなりません。 
%
% 入力 x, y, xi のサポートクラス
%   float: double, single
%
% 参考 INTERP1.

%   Copyright 1984-2004 The MathWorks, Inc.
