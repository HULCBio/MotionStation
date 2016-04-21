% ERFCX   スケーリングされた相補誤差関数
% 
% Y = ERFCX(X) は、X の各要素に対する、スケーリングされた相補誤差関数で
% す。X は、実数でなければなりません。スケーリングされた相補誤差関数は、
% つぎのように定義されます。
%
%   erfcx(x) = exp(x^2) * erfc(x)
%
% これは、x が大きければ、ほぼ (1/sqrt(pi)) * 1/x になります。
%
% 参考：ERF, ERFC, ERFINV.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:10 $
