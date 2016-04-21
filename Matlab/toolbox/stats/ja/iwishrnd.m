% IWISHRND   Wishartランダム逆行列を作成
%
% W=IWISHRND(SIGMA,DF) は、ランダム行列 W を作成します。この逆行列は、
% 共分散行列 SIGMA と自由度 DFをもつ Wishart分布をもちます。
%
% W=IWISHRND(SIGMA,DF,DI) は、DIがSIGMAの逆行列のCholesky factor であると
% 見なします。同じ値のSIGMAを使用して、IWISHRND を複数回、呼び出す場合、
% 毎回、計算する代わりに、DIを与える方が、より効果的です。
%
% [W,DI]=IWISHRND(SIGMA,DF) は、DIを出力するので、IWISHRNDの将来の
% 呼び出しで、再び使用されます。
%
% 参考 : WISHRND..


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:12:37 $
