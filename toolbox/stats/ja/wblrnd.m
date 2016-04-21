% WBLRND   Weibull分布のランダム行列
%
% R = WBLRND(A,B) は、スケールパラメータ A と形状パラメータ B をもつ
% Weibull分布から抽出された乱数の行列を出力します。
%  
% R の大きさは A と B が共に行列の場合、それらに共通する大きさになります。
% どちらかのパラメータがスカラの場合、R の大きさは、もう一方のパラメータと
% 同じ大きさになります。また、R = WBLRND(A,B,M,N) は、M行N列の行列を出力
% します。
%
% 参考 : WBLCDF, WBLFIT, WBLINV, WBLLIKE, WBLPDF, WBLSTAT.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2003/01/09 21:47:45 $
