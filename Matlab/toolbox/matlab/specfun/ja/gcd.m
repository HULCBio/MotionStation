% GCD   最大公約数
% 
% G = GCD(A,B) は、A と B の対応する要素同士の最大公約数です。配列 A と B
% は、負でない整数要素をもち、同じサイズでなければなりません(または、いずれ
% かがスカラでも構いません)。GCD(0,0) は、便宜上0を出力します。それ以外は、
% GCD は正の整数を出力します。
%
% [G,C,D] = GCD(A,B) は、G = A.*C + B.*D であるような C と D を出力します。
% これは、Diophantine方程式を解いたり、エルミート変換を計算するために便利
% です。
%
% 参考：LCM.



%   Algorithm: See Knuth Volume 2, Section 4.5.2, Algorithm X.
%   Author:    John Gilbert, Xerox PARC
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:04:18 $
