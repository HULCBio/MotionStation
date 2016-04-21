% EVSTAT   極値分布の平均値と分散
%
% [M,V] = EVSTAT(MU,SIGMA) は、位置パラメータ MU とスケールパラメータ 
% SIGMA をもつタイプ1の極値分布の平均値と分散を出力します。
%
% M と V の大きさは、入力引数と同じ大きさです。スカラ入力は、他の入力と
% 同じ大きさの定数行列として機能します。
%
% タイプ1の極値分布は、別名Gumbel分布としても知られています。Y が 
% Weibull分布の場合、X=log(Y) は、タイプ1の極値分布になります。
%
% 参考 : EVCDF, EVFIT, EVINV, EVLIKE, EVPDF, EVRND.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2003/01/08 15:29:28 $
