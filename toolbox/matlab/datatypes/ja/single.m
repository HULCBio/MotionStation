%SINGLE 単精度への変換
% Y = SINGLE(X) は、ベクトル X を単精度に変換します。X は、(DOUBLE の
% ような)任意の数値オブジェクトです。X がすでに単精度である場合は、
% SINGLE は影響を与えません。単精度は、倍精度よりも小さいストレージを
% 要求しますが、精度は悪く、レンジも小さくなります。REALMAX('single') は、
% SINGLE に上限を与え、REALMIN('single') は、最小の正規化された正の値
% SINGLE です。
%
% DOUBLE 配列に定義されている大部分の操作は、SINGLE 配列にも
% 定義されています。SINGLE と DOUBLE 配列が計算で影響する場合、
% 結果のタイプは、SINGLE です。
%
% ユーザのパス上のディレクトリ内の @single ディレクトリに適切な名称の
% メソッドを用意することで、(任意のオブジェクトに対して) SINGLE に
% 対するユーザ自身の手法を定義することができます。
% オーバーロードできるメソッド名については DATATYPES を参照してください。
%
% つぎの方法は、大きい SINGLE 配列を初期化するのに特に効率的です。
%
%       S = zeros(1000,1000,'single')
%
% これは、1000x1000 要素の SINGLE 配列を作成し、その要素はすべてゼロです。
% 同様の方法で、ONES や EYE を使用することもできます。
%
% 例題:
%      X = pi * ones(5,6,'single')
%
% 参考 DOUBLE, DATATYPES, UINT8, UINT16, UINT32, UINT64, INT8, INT16,
%      INT32, INT64, REALMIN, REALMAX, EYE, ONES, ZEROS, ISFLOAT, ISNUMERIC.

%   Copyright 1984-2004 The MathWorks, Inc. 
