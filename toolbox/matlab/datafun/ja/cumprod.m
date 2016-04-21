% CUMPROD   累積積
% 
% Xがベクトルの場合、CUMPROD(X)はXの要素の累積積を含むベクトルを出力しま
% す。Xが行列の場合、CUMPROD(X)は、各列に対する累積積を含む、Xと同じサイ
% ズの行列を出力します。XがN次元配列の場合、CUMPROD(X)は最初に1でない次
% 元について機能します。
%
% CUMPROD(X,DIM)は、次元DIMについて機能します。
%
% 例題: 
%    X = [0 1 2
%     　  3 4 5]
%
% の場合、cumprod(X,1)は、[0 1  2 で、cumprod(X,2)は、[0  0  0
%                          0 4 10]                     3 12 60]です。
%
% 参考：CUMSUM, SUM, PROD.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:46:34 $
