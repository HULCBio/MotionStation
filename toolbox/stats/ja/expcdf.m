% EXPCDF   指数累積分布関数
%
% P = EXPCDF(X,MU) は、位置パラメータ MU をもつ、X の値で評価された指数
% 累積分布関数を出力します。
% 
% MU に対するデフォルト値は、1です。
%
% [P,PLO,PUP] = EXPCDF(X,MU,PCOV,ALPHA) は、入力パラメータ MU が推定された
% とき、P に対する信頼区間を生成します。PCOV 推定された MU の分散です。
% ALPHA は、0.05のデフォルト値で、100*(1-ALPHA)% の信頼区間を指定します。
% PLO と PUP は、信頼区間の下限と上限を含む P と同じサイズの配列です。
% 境界は、MU の推定の対数分布に対する通常の近似に基づきます。MU に対する
% 信頼区間を得るために、EXPFIT を使用し、その区間の下限と上限の終点で 
% EXPCDF を評価することによって、簡単に境界のより正確な設定を得ることが
% できます。
%
% 参考 : CDF, EXPFIT, EXPINV, EXPLIKE, EXPPDF, EXPRND, EXPSTAT.


%     Copyright 1993-2003 The MathWorks, Inc. 
%     $Revision: 1.6 $  $Date: 2003/02/12 17:07:10 $
