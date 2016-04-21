% CDFCALC   経験的な累積分布関数を計算
%
% [YCDF,XCDF] = CDFCALC(X) は、観測値を表すデータサンプルベクトル Xの 
% 経験的な累積分布関数 (CDF)を計算します。X は、行ベクトルでも列ベクトル 
% でも構いません。そして、ある分布のもとで、観測されたランダムなサンプル
% を表しているとします。出力 XCDF は、CDFが増加する点のX 値の集合です。
% XCDF(i)で、関数は、YCDF(i)からYCDF(i+1)の間で増加していることを示します。
%
% [YCDF,XCDF,N] = CDFCALC(X) は、標本の大きさ N も出力します。
%
% [YCDF,XCDF,N,EMSG] = CDFCALC(X) は、X がベクトルでない場合、または、
% NaN しか含んでいない場合、エラーメッセージも出力します。
%
% 参考 : CDFPLOT.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:10:49 $
