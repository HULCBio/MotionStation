% BETA   beta関数
% 
% Y = BETA(Z,W)は、Z と W の 対応する要素に対して、beta関数を計算します。
% beta関数は、つぎのように定義されます。
%
%   beta(z,w) = t.^(z-1) .* (1-t).^(w-1) dtの0から1までの積分
%
% 配列 Z と W は、同じサイズでなければなりません(または、いずれかが
% スカラでも構いません)。
%
% 参考：BETAINC, BETALN.


%   C. Moler, 2-1-91.
%   Ref: Abramowitz & Stegun, sec. 6.2.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:03:57 $
