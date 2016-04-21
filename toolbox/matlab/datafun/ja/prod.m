% PROD   配列の要素の積
% 
% Xがベクトルの場合、PROD(X)はXの要素の積を出力します。Xが行列の場合、
% PROD(X)は各列の積を行ベクトルとして出力します。XがN次元配列の場合、
% PROD(X)は最初に1でない次元について積を出力します。 
%
% PROD(X,DIM)は、次元DIMについて積を出力します。 
%
% 例題: X = [0 1 2
%           3 4 5]
%
% の場合、prod(X,1) は[0 4 10]で、prod(X,2)は [0  です。
%                                              60]
%
% 参考：SUM, CUMPROD, DIFF.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:46:58 $
