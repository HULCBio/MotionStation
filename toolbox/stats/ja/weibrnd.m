% WEIBRND   Weibull分布のランダム行列
%
% R = WEIBRND(A,B) は、パラメータ A と B をもつWeibull分布からランダム
% 行列を作成します。
% 
% R の大きさは、A と B が共に行列の場合、それらに共通する大きさになり
% ます。どちらかのパラメータがスカラの場合、R の大きさは、もう一方の
% パラメータと同じ大きさになります。R = WEIBRND(A,B,M,N) は、M行N列の
% 行列を出力します。 
% 
% A == B の場合、WEIBRND は、EXPRND をコールします。 
% A ~= B の場合、WEIBRND は、反転法(inversion method)を使います。 


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:16:25 $
