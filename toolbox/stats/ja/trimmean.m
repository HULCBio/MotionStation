% TRIMMEAN   標本の位置のロバストな推定である X のトリム平均(trimmed mean)
%
% M = TRIMMEAN(X,PERCENT) は、データの大きい方、および、小さい方を 
% PERCENT/2 だけ取り除いたものに対する平均を計算します。行列の場合、
% TRIMMEAN(X) は、各列に対するトリム平均(trimmed mean)を計算し、それを
% 要素とするベクトルを出力します。スカラー PERCENT は、0から100の間の
% 値を設定することができます。
%
% 行列 X の場合、M = TRIMMEAN(X,PERCENT) は、X の各列に対するトリム平均
% (trimmed mean)を含む行ベクトルを出力します。 


%   B.A. Jones 3-04-93
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:08:25 $
