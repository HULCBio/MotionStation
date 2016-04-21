% SKEWNESS   標本の歪度
%
% ベクトルに対して、SKEWNESS(x) は、標本の歪度を計算します。
% 行列に対して、SKEWNESS(X) は、各列の標本の歪度を要素とする行ベクトルを
% 出力します。歪度は、3次の中心モーメントを標準偏差の3乗したもので割り算
% したものです。
%
% SKEWNESS(X,0) は、バイアスに対して、歪度を調整したものです。
% SKEWNESS(X,1) は、SKEWNESS(X) と等価で、バイアスに対して調整を行いません。
%
% 参考 : MEAN, MOMENT, STD, VAR, KURTOSIS.


%   B.A. Jones 2-6-96
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:15:43 $
