% BETALN   beta関数の対数
% 
% Y = BETALN(Z,W) は、Z と W の 対応する要素に対して、beta関数の自然対数
% を計算します。配列 Z とW  は、同じサイズでなければなりません(または、
% いずれかがスカラでも構いません)。BETALN は、つぎのように定義されます。
%
%     BETALN = LOG(BETA(Z,W)) 
%
% 実際には、BETALN は BETA(Z,W) を計算せずに得られます。beta関数は非常に
% 大きい値から小さい値までを変動できるので、関数の対数が非常に有効となる
% ことがあります。
% 
% 参考：BETAINC, BETA.


%   Reference: Abramowitz & Stegun, sec. 6.2.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:00 $
