% EVINV   極値分布の逆累積分布関数(cdf)
%
% X = EVINV(P,MU,SIGMA) は、位置パラメータ MU とスケールパラメータ SIGMA
% をもつ P の値で評価されたタイプ1の極値分布に対する逆累積分布関数を
% 出力します。X の大きさは、入力引数と同じ大きさです。スカラの入力は、
% もう一方の入力と同じ大きさの定数行列として機能します。
%   
% MU と SIGMA に対するデフォルト値は、それぞれ0と1です。
%
% [X,XLO,XUP] = EVINV(P,MU,SIGMA,PCOV,ALPHA) は、入力パラメータ MUと 
% SIGMA が推定されたとき、X に対する信頼区間を生成します。PCOV は、推定
% されたパラメータの共分散行列を含んだ2行2列の行列です。ALPHA は、0.05の
% デフォルト値で、100*(1-ALPHA)% の信頼区間を指定します。XLO と XUP は、
% 信頼区間の下限と上限を含む X と同じ大きさの配列です。
%
% タイプ1の極値分布は、別名Gumbel分布としても知られています。Y が 
% Weibull分布の場合、X=log(Y) は、タイプ1の極値分布になります。
%
% 参考 : EVCDF, EVFIT, EVLIKE, EVPDF, EVRND, EVSTAT, ICDF.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2003/01/08 15:29:33 $
