% EVFIT   極値データに対するパラメータ推定と信頼区間
%
% PARMHAT = EVFIT(X) は、与えられた X のデータで、タイプ1の極値分布の
% パラメータの最尤推定値を出力します。PARMHAT(1) は、位置パラメータ mu で、
% PARMHAT(2) は、スケールパラメータ sigma です。
%
% [PARMHAT,PARMCI] = EVFIT(X) は、パラメータ推定に対する95%の信頼区間を
% 出力します。
%
% [PARMHAT,PARMCI] = EVFIT(X,ALPHA) は、パラメータ推定に対する 
% 100(1-ALPHA)% の信頼区間を出力します。
%
% [...] = EVFIT(X,ALPHA,CENSORING) は、正確に観測された観測値に対して0、
% 右側打ち切りの観測値に対して1となる、X と同じ大きさの論理ベクトルを受け
% 入れます。
%
% [...] = EVFIT(X,ALPHA,CENSORING,FREQ) は、X と同じ大きさの頻度ベクトル% [...] = EVFIT(X,ALPHA,CENSORING,FREQ) は、X と同じサイズの頻度ベクトル
% を受け入れます。FREQ は、通常は、X の要素に対応するための整数の頻度を
% 含みますが、任意の整数でない非負値を含むこともできます。
%
% [...] = EVFIT(X,ALPHA,CENSORING,FREQ,OPTIONS) は、最尤(ML)推定の計算に
% 使用される反復アルゴリズムに対するコントロールパラメータを指定します。
% この引数は、STATSET をコールすることで作成されます。パラメータ名と
% デフォルト値については、STATSET('evfit') を参照してください。
%
% これらのデフォルト値を使用するには、ALPHA, CENSORING, FREQ に対して、
% [] を渡してください。
%
% タイプ1の極値分布は、別名Gumbel分布としても知られています。Y が 
% Weibull分布の場合、X=log(Y) は、タイプ1の極値分布になります。
%
% 参考 : EVCDF, EVINV, EVLIKE, EVPDF, EVRND, EVSTAT, MLE, STATSET.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2003/02/11 19:41:34 $
