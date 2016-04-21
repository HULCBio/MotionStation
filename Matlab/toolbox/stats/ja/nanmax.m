% NANMAX   NaN を無視した最大値
%
% M = NANMAX(A) は、NaN を欠測値として扱って、最大値を求めます。
% ベクトルに対して、NANMAX(A) は、A の中の NaN でない要素の中の最大値を
% 出力します。また、行列に対しては、NANMAX(A) は、各列毎に NaN でない
% 要素に対して最大値を要素とする行ベクトルを出力します。
% 
% [M,NDX] = NANMAX(A) は、ベクトル NDX に最大値のインデックスも出力します。
% 
% M = NANMAX(A,B) は、A と B の各要素を比較して、大きいほうの要素を出力
% します。A と B は、同じ大きさでなければなりません。
% 
% 参考 : NANMIN, NANMEAN, NANMEDIAN, NANMIN, NANSTD.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:13:20 $
