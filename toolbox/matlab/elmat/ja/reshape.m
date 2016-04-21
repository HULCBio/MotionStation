% RESHAPE   配列のサイズの変更
% 
% RESHAPE(X,M,N)は、Xから列方向に要素を使ってM行N列の行列を出力します。
% XがM*N個の要素をもっていなければ、エラーとなります。
%
% RESHAPE(X,M,N,P,...)は、Xと同じ要素をもち、サイズがM*N*P*..である多次
% 元配列を出力します。M*N*P*...は、PROD(SIZE(X))と同じでなければなりませ
% ん。
%
% RESHAPE(X,[M N P ...])は、RESHAPE(X,M,N,P,...)と同じです。
%
% RESHAPE(X,...,[],...) は、[]で表わされる次元の長さを、次元数の積が、
% PROD(SIZE(X)) と等しくなるように計算します。PROD(SIZE(X))は、既知の次元
% 数の積で割り切れる必要があります。引数としては、[]は1回のみ使うことがで
% きます。
%
% 一般に、RESHAPE(X,SIZ)はXと同じ要素をもち、サイズがSIZであるN次元配列
% を出力します。PROD(SIZ)は、PROD(SIZE(X))と同じでなければなりません。 
%
% 参考：SQUEEZE, SHIFTDIM, COLON.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:51:46 $
%   Built-in function.
