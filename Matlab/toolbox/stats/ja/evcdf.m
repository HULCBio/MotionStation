% EVCDF   極値分布の累積分布関数(cdf)
%
% P = EVCDF(X,MU,SIGMA) は、位置パラメータ MU とスケールパラメータ SIGMA 
% をもつ X の値で評価されたタイプ1の極値分布の累積分布関数を出力します。
% P の大きさは、入力引数と同じ大きさです。スカラ入力は、他の入力と同じ
% 大きさの定数行列として機能します。
%
% MU と SIGMA に対するデフォルト値は、それぞれ0と1です。
%
% [P,PLO,PUP] = EVCDF(X,MU,SIGMA,PCOV,ALPHA) は、入力パラメータ MU と 
% SIGMA が推定されるとき、P に対する信頼区間を生成します。PCOV は、推定
% されたパラメータの共分散行列を含んだ2行2列の行列です。ALPHA は、0.05の
% デフォルト値で、100*(1-ALPHA)% の信頼区間を指定します。PLO と PUP は、
% 信頼区間の下限と上限を含む P と同じ大きさの配列です。
%
% タイプ1の極値分布は、別名Gumbel分布としても知られています。Y が 
% Weibull分布の場合、X=log(Y) は、タイプ1の極値分布になります。
%
% 参考 : CDF, EVFIT, EVINV, EVLIKE, EVPDF, EVRND, EVSTAT.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2003/01/08 15:29:35 $
