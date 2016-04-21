% LOGNINV   対数正規分布の逆累積分布関数(cdf)
%
% X = LOGNINV(P,MU,SIGMA) は、対数平均 MU と対数標準偏差 SIGMA をもつ
% P の値で評価された対数正規分布に対する逆累積分布関数を出力します。X の
% 大きさは、入力引数と同じ大きさです。スカラの入力は、もう一方の入力と
% 同じ大きさの定数行列として機能します。
%
% MU と SIGMA に対するデフォルト値は、それぞれ、0と1です。
%
% [X,XLO,XUP] = LOGNINV(P,MU,SIGMA,PCOV,ALPHA) は、入力パラメータ MUと 
% SIGMA が推定されたとき、X に対する信頼区間を生成します。PCOV は、推定
% されたパラメータの共分散行列を含んだ2行2列の行列です。ALPHA は、0.05の
% デフォルト値で、100*(1-ALPHA)% の信頼区間を指定します。XLO と XUP は、
% 信頼区間の下限と上限を含む X と同じ大きさの配列です。
%
% 参考 : ERFINV, ERFCINV, LOGNCDF, LOGNFIT, LOGNLIKE, LOGNPDF,
%        LOGNRND, LOGNSTAT.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:07:46 $
