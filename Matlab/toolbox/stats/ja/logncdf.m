% LOGNCDF   対数正規累積分布関数
%
% P = LOGNCDF(X,MU,SIGMA) は、対数平均値 MU、対数標準偏差 SIGMA をもつ
% X の値で評価された対数正規累積分布関数を出力します。P の大きさは、
% 入力引数と同じ大きさです。スカラ入力は、他の入力と同じ大きさの定数
% 行列として機能します。
% 
% MU と SIGMA のデフォルト値は、それぞれ0と1です。
%
% [P,PLO,PUP] = LOGNCDF(X,MU,SIGMA,PCOV,ALPHA) は、入力パラメータ MU 
% と SIGMA が推定されるとき、P に対する信頼区間を生成します。PCOV は、
% 推定されたパラメータの共分散行列を含んだ2行2列の行列です。ALPHA は、
% 0.05のデフォルト値で、100*(1-ALPHA)% の信頼区間を指定します。PLO と 
% PUP は、信頼区間の下限と上限を含む P と同じ大きさの配列です。
%
% 参考 : ERF, ERFC, LOGNFIT, LOGNINV, LOGNLIKE, LOGNPDF, LOGNRND, LOGNSTAT


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:07:43 $
