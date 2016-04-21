% LOGNRND   対数正規分布のランダム行列
%
% R = LOGNRND(MU,SIGMA) は、対数平均 MU と 対数標準偏差 SIGMA をもつ
% 対数正規分布から抽出された乱数行列を出力します。R の大きさは、MU と 
% SIGMA が共に行列の場合、それらに共通する大きさになります。どちらかの
% パラメータがスカラの場合、R の大きさは、もう一方のパラメータと同じ
% 大きさになります。また、R = LOGRND(MU,SIGMA,M,N) は、M行N列の行列を
% 出力します。
%
% 参考 : LOGNCDF, LOGNFIT, LOGNINV, LOGNLIKE, LOGNPDF, LOGNSTAT, RANDN.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:07:51 $
