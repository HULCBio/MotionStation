% NORMINV   正規分布の逆累積分布関数(cdf)
%
% X = NORMINV(P,MU,SIGMA) は、平均 MU と標準偏差 SIGMA をもつ P の値で
% 評価された正規分布に対する逆累積分布関数を出力します。X の大きさは、
% 入力引数と同じ大きさです。スカラの入力は、もう一方の入力と同じ大きさ
% の定数行列として機能します。
% 
% MU と SIGMA のデフォルト値は、それぞれ、0 と 1 です。
% 
% [X,XLO,XUP] = NORMINV(P,MU,SIGMA,PCOV,ALPHA) 、は、入力パラメータ MUと 
% SIGMA が推定されたとき、X に対する信頼区間を生成します。PCOV は、推定
% されたパラメータの共分散行列を含んだ2行2列の行列です。ALPHA は、0.05の
% デフォルト値で、100*(1-ALPHA)% の信頼区間を指定します。XLO と XUP は、
% 信頼区間の下限と上限を含む X と同じ大きさの配列です。
%
% 参考 : ERFINV, ERFCINV, NORMCDF, NORMFIT, NORMLIKE, NORMPDF,
%        NORMRND, NORMSTAT.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:14:19 $
