% KURTOSIS   標本の尖度
%
% ベクトルの場合、KURTOSIS(x) は、標本の尖度を出力します。
% 行列の場合、KURTOSIS(X) は、各列の標本の尖度を含む行ベクトルを出力します。
% 尖度は、4次の中心モーメントを標準偏差の4乗で割ったものです。
% 
% KURTOSIS(X,0) は、バイアスに対して尖度を調整します。KURTOSIS(X,1) は、
% KURTOSIS(X) と等価ですが、バイアスに対する調整は行いません。
% 
% 参考 : MEAN, MOMENT, STD, VAR, SKEWNESS.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:12:50 $
