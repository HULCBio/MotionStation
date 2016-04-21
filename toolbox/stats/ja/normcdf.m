% NORMCDF   正規累積分布関数 (cdf)
%
% P = NORMCDF(X,MU,SIGMA) は、平均 MU と標準偏差 SIGMA をもつ X の値で
% 評価された正規累積分布関数を出力します。P の大きさは、X、MU、SIGMA と
% 共通の大きさです。スカラ入力は、他の入力と同じ大きさの定数行列として
% 機能します
%
% MU と SIGMA のデフォルト値は、それぞれ、0と1です。
%
% [P,PLO,PUP] = NORMCDF(X,MU,SIGMA,PCOV,ALPHA) 、入力パラメータ MU と 
% SIGMA が推定されるとき、P に対する信頼区間を生成します。PCOV は、推定
% されたパラメータの共分散行列を含んだ2行2列の行列です。ALPHA は、0.05の
% デフォルト値で、100*(1-ALPHA)% の信頼区間を指定します。PLO と PUP は、
% 信頼区間の下限と上限を含む P と同じ大きさの配列です。
%
% 参考 : ERF, ERFC, NORMFIT, NORMINV, NORMLIKE, NORMPDF, NORMRND, NORMSTAT.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:14:14 $
