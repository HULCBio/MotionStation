% WBLCDF   Weibull分布の累積分布関数(cdf)
%
% P = WBLCDF(X,A,B) は、スケールパラメータ A と形状パラメータ B をもつ
% X の値で評価されたWeibull分布の累積分布関数を出力します。P の大きさは、
% 入力引数と同じ大きさです。スカラ入力は、他の入力と同じ大きさの定数
% 行列として機能します。
%
% A と B に対するデフォルト値は、それぞれ0と1です。
%
% [P,PLO,PUP] = WBLCDF(X,A,B,PCOV,ALPHA) は、入力パラメータ A と B が
% 推定されるとき、P に対する信頼区間を生成します。PCOV は、推定された
% パラメータの共分散行列を含んだ2行2列の行列です。ALPHA は、0.05の
% デフォルト値で、100*(1-ALPHA)% の信頼区間を指定します。PLO と PUP は、
% 信頼区間の下限と上限を含む P と同じ大きさの配列です。
%
% 参考 : CDF, WBLFIT, WBLINV, WBLLIKE, WBLPDF, WBLRND, WBLSTAT.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2003/01/09 21:47:34 $
