% GAMMALN   ガンマ関数の対数
% 
% Y = GAMMALN(X) は、X の各要素に対するガンマ関数の自然対数を計算します。
% GAMMALN は、つぎのように定義されます。
%
%    LOG(GAMMA(X))
%
% GAMMALN は、GAMMA(X) を計算せずに得られます。ガンマ関数は、非常に
% 大きい値から小さい値までを変動できるので、関数の対数は非常に有効となる
% ことがあります。
%
% 参考：GAMMA, GAMMAINC, PSI.


%   C. Moler, 2-1-91.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:17 $
