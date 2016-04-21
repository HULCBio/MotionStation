% WISHRND   Wishartランダム行列の生成
%
% W=WISHRND(SIGMA,DF) は、共分散行列 SIGMA と自由度 DF としてWishart分布
% をもつランダム行列 W を生成します。 
%
% W=WISHRND(SIGMA,DF,D) は、D が、SIGMA のCholesky factorであることを
% 期待します。SIGMA の同じ値を用いて、WISHRND を複数回呼び出す場合、
% 各時刻で計算する代わりに、D を提供するのがより効果的です。
%
% [W,D]=WISHRND(SIGMA,DF) は、WISHRND を将来、呼び出すときに使用できる
% ように、Dを出力します。
%
% 参考 : IWISHRND.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:16:29 $
