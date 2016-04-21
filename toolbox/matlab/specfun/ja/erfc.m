% ERFC  相補誤差関数
%
% Y = ERFC(X) は、X の各要素の相補誤差関数を出力します。相補誤差関数は、
% つぎのように定義されます。
%
%  erfc(x) = 2/sqrt(pi) * dtの x からexp(-t^2)までの積分
%             = 1 - erf(x).
%
% 参考：ERF, ERFCX, ERFINV.


%   Ref: Abramowitz & Stegun, Handbook of Mathematical Functions, sec. 7.1.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:08 $
