% EXPFIT   指数的なデータに対するパラメータ推定と信頼区間
%
% PARMHAT = EXPFIT(X) は、与えられた X のデータで、指数分布の位置パラ
% メータ  mu の最尤推定を出力します。X が行列の場合、EXPFIT は、X の各列に
% 対する個々のパラメータ推定を出力します。
%
% [PARMHAT,PARMCI] = EXPFIT(X) は、パラメータ推定に対する95%の信頼区間を
% 出力します。
% 
% [PARMHAT,PARMCI] = EXPFIT(X,ALPHA) は、パラメータ推定に対する 
% 100(1-ALPHA)% の信頼区間を出力します。
%
% 以下の構文は、X がベクトルのときに必要です。
%
% [...] = EXPFIT(X,ALPHA,CENSORING) は、正確に観測された観測値に対して0を、
% 右側打ち切りの観測値に対して1となる、X と同じ大きさの論理ベクトルを受け
% 入れます。
%
% [...] = EXPFIT(X,ALPHA,CENSORING,FREQ) は、X と同じ大きさの頻度ベクトル
% を受け入れます。FREQ は、通常は、X の要素に対応するための整数の頻度を
% 含みますが、任意の整数でない非負値を含むこともできます。
%
% これらのデフォルト値を使用するには、ALPHA, CENSORING, FREQ に対して、
% [] を渡してください。
%
% 参考 : EXPCDF, EXPINV, EXPLIKE, EXPPDF, EXPRND, EXPSTAT, MLE.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2003/02/12 17:07:12 $
