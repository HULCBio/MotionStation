% EVPDF   極値分布確率密度関数(pdf)
%
% Y = EVPDF(X,MU,SIGMA) は、位置パラメータ MU とスケールパラメータ SIGMA 
% をもつ X の値で評価されたタイプ1の極値分布確率密度関数を出力します。
% Y の大きさは、入力引数と同じ大きさです。スカラの入力は、もう一方の
% 入力と同じ大きさの定数行列として機能します。
%   
% MU と SIGMA に対するデフォルト値は、それぞれ0と1です。
%
% タイプ1の極値分布は、別名Gumbel分布としても知られています。Y が 
% Weibull分布の場合、X=log(Y) は、タイプ1の極値分布になります。
%
% 参考 : EVCDF, EVFIT, EVINV, EVLIKE, EVRND, EVSTAT, PDF.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2003/01/08 15:29:30 $
