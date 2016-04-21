% CUMSUM   累積和
% 
% Xがベクトルの場合、CUMSUM(X)はXの要素の累積和を含むベクトルを出力しま
% す。
% Xが行列の場合、CUMSUM(X)は各列に対する累積和を含む、Xと同じサイズの行
% 列を出力します。XがN次元配列の場合、CUMSUM(X)は最初に1でない次元につい
% て機能します。
%
% CUMSUM(X,DIM)は、次元DIMについて機能します。
%
% 例題:
% 
% X = [0 1 2
%      3 4 5]
%
% の場合、cumsum(X,1) は [0 1 2  で cumsum(X,2) は [0 1  3  です。
%                         3 5 7]                    3 7 12]
% 
% 参考：CUMPROD, SUM, PROD.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:46:35 $
