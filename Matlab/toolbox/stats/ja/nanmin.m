% NANMIN   NaN を無視した最小値
%
% M = NANMIN(A) は、NaN を欠測値として最小値を求めます。
% ベクトルに対して、NANMIN(A) は、A の中の NaN でない要素の最小値を
% 求めます。行列に対して、NANMIN(A) は、各列の中の NaN でない要素の
% 最小値を求め、それを要素とする行ベクトルを出力します。
% 
% [M, NDX] = NANMIN(A) は、ベクトル NDX に最小値のインデックスを出力
% します。
% 
% M = NANMIN(A,B) は、A と B は同じサイズである必要があります。
% 
% 参考 : NANMAX, NANMEAN, NANMEDIAN, NANSTD, NANSUM.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:13:28 $
