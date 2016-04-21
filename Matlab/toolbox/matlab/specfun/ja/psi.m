% PSI    Psi (polygamma)関数
% Y = PSI(X) は、X の各要素に対するpsi関数を計算します。X は、実数で非負
% でなければなりません。psi関数は、digamma関数としても知られ、gamma関数
% の対数微係数です。
%
%    psi(x) = digamma(x) = d(log(gamma(x)))/dx = (d(gamma(x))/dx)/gamma(x).
%
% Y = PSI(K,X) は、X の要素でpsiのK次微係数を計算します。
% PSI(0,X) はdigamma関数で、PSI(1,X) はtrigamma関数で、PSI(2,X) は
% tetragamma関数、等になります。
%
% Y = PSI(K0:K1,X) は、X において、微係数の次数 K0 から K1を計算します。
% Y(K,J) は、X(J) で計算されたpsiの (K-1+K0) 番目の微係数です。
%
% 例題:
%
%    -psi(1) = -psi(0,1) は、Eulerの定数、0.5772156649015323です。
%
%    psi(1,2) = pi^2/6 - 1.
%
%    x = (1:.005:1.250)';  [x gamma(x) gammaln(x) psi(0:1,x)' x-1]
%    は、Abramowitz and Stegunのtable 5.1の1ページを生成します。.
%
%    psi(2:3,1:.01:2)' は、table 6.2 の一部です。
%
% 参考文献: Abramowitz & Stegun, Handbook of Mathematical Functions,
%   sections 6.3 and 6.4.
%
% 参考 ： GAMMA, GAMMALN, GAMMAINC.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 02:04:27 $


