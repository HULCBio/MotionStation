% WBLINV   Weibull分布の逆累積分布関数(cdf)
%
% X = WBLINV(P,A,B) は、スケールパラメータ A と形状パラメータ B をもつ
% P の値で評価されたWeibull分布に対する逆累積分布関数を出力します。X の
% 大きさは、入力引数と同じ大きさです。スカラの入力は、もう一方の入力と
% 同じ大きさの定数行列として機能します。
%   
% A と B に対するデフォルト値は、それぞれ1と1です。
%
% [X,XLO,XUP] = WBLINV(P,A,B,PCOV,ALPHA) は、入力パラメータ A と B が推定
% されたとき、X に対する信頼区間を生成します。PCOV は、推定されたパラメータ
% の共分散行列を含んだ2行2列の行列です。ALPHA は、0.05のデフォルト値で、
% 100*(1-ALPHA)% の信頼区間を指定します。XLO と XUP は、信頼区間の下限と
% 上限を含む X と同じ大きさの配列です。
%
% 参考 : WBLCDF, WBLFIT, WBLLIKE, WBLPDF, WBLRND, WBLSTAT, ICDF.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2003/01/09 21:47:38 $
