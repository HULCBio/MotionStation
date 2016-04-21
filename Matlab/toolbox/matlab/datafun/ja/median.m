% MEDIAN   配列の中央値
% 
% Xがベクトルの場合、MEDIAN(X)はXの要素の中央値を出力します。
% Xが行列の場合、MEDIAN(X)は各列の中央値を含む行ベクトルを出力します。
% XがN次元配列の場合、MEDIAN(X)はXの最初に1でない次元の要素について中
% 央値を出力します。
%
% MEDIAN(X,DIM)は、Xの次元DIMについて中央値を計算します。
%
% 例題: X = [0 1 2
%            3 4 5]
%
% の場合、median(X,1)は[1.5 2.5 3.5]で、median(X,2)は[1  です。
%                                                     4]
%
% 参考：MEAN, STD, MIN, MAX, COV.


%   Copyright 1984-2004 The MathWorks, Inc. 
