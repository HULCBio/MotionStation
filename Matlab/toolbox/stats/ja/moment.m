% MOMENT   すべての次数の中心モーメント
%
% MOMENT(DATA,ORDER) は、正の整数 ORDER で設定される次数の DATA の中心
% モーメントを計算します。行列 DATA の場合、MOMENT は、各列に対して設定
% された次数の中心モーメントを出力します。中心一次モーメントはゼロである
% ことに注意してください。また、2次の中心モーメントは、標本のサイズを N 
% とすると、N-1 の代わりに N で割ることで、分散を求めています。
% 
% 参考 : MEAN, STD, VAR, SKEWNESS, KURTOSIS


%   B.A. Jones 1/20/95
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:13:10 $
