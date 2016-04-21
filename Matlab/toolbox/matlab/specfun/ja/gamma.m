% GAMMA   ガンマ関数
% 
% Y = GAMMA(X) は、X の各要素に対するガンマ関数です。X は、実数でなけ
% ればなりません。ガンマ関数は、つぎのように定義されます。
%
%  gamma(x) = t^(x-1) exp(-t) dt の0からinfまでの積分
%
% ガンマ関数は、階乗関数を内挿します。整数 n に対して、gamma(n+1) = n! 
% (n の階乗) = prod(1:n)となります。
%
% 参考：GAMMALN, GAMMAINC, PSI.


%   C. B. Moler, 5-7-91, 11-4-92.
%   Ref: Abramowitz & Stegun, Handbook of Mathematical Functions, sec. 6.1.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:15 $
