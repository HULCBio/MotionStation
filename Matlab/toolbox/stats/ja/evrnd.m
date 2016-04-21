% EVRND   極値分布のランダム行列
%
% R = EVRND(MU,SIGMA) は、位置パラメータ MUとスケールパラメータ SIGMA 
% をもつタイプ1の極値分布から抽出された乱数の行列を出力します。
%  
% R の大きさは、MU と SIGMA が共に行列の場合、それらに共通する大きさに
% なります。どちらかのパラメータがスカラの場合、R の大きさは、もう一方の
% パラメータと同じ大きさになります。また、R = EVRND(MU,SIGMA,M,N) は、
% M行N列の行列を出力します。
%
% タイプ1の極値分布は、別名Gumbel分布としても知られています。Y が 
% Weibull分布の場合、X=log(Y) は、タイプ1の極値分布になります。
%
% 参考 : EVCDF, EVFIT, EVINV, EVLIKE, EVPDF, EVSTAT.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2003/01/08 15:29:29 $
