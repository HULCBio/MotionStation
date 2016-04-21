% DETREND は、FFT処理で一般に使う方法で、ベクトルからトレンドを除去する
% ものです。
% 
% Y = DETREND(X)は、ベクトルXの中のデータを直線近似を行い、その量を取り
% 除き、その結果をベクトルYに出力します。Xが行列の場合、DETRENDは、各列
% についてトレンドの除去を行います。
% 
% Y = DETREND(X,'constant')は､ベクトルXから平均値を除去し、または、Xが行
% 列の場合、各列から平均値を取り除きます。
% 
% Y = DETREND(X,'linear',BP)は、連続的な、区分的線形トレンドを取り除きま
% す。線形トレンドに対するブレークポイントのインデックスは、ベクトルBPで
% 設定します。デフォルトでは、ブレークポイントは存在しません。それで、
% 単独の直線がXの各列から取り除かれます。
%
% 参考：MEAN


%   Author(s): J.N. Little, 6-08-86
%   	   J.N. Little, 2-29-88, revised
%   	   G. Wolodkin, 2-02-98, added piecewise linear fit of L. Ljung
%   Copyright 1984-2004 The MathWorks, Inc. 
