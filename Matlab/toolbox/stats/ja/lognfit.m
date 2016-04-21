% LOGNFIT   対数正規のデータに対するパラメータ推定と信頼区間
%
% PARMHAT = LOGNFIT(X) は、与えられた X のデータで、対数正規分布の
% パラメータの最尤推定値を出力します。
% PARMHAT(1) と PARMHAT(2) は、それぞれ、ある正規分布に基づく平均と
% 標準偏差パラメータである MU と SIGMA です。
%
% [PARMHAT,PARMCI] = LOGNFIT(X) は、パラメータ推定に対する95%の信頼区間を
% 出力します。
%
% [PARMHAT,PARMCI] = LOGNFIT(X,ALPHA) は、パラメータ推定に対する 
% 100(1-ALPHA)% の信頼区間を出力します。
%
% [...] = LOGNFIT(X,ALPHA,CENSORING) は、正確に観測された観測値に対して0、
% 右側打ち切りの観測値に対して1となる、X と同じ大きさの論理ベクトルを受け
% 入れます。
%
% [...] = LOGNFIT(X,ALPHA,CENSORING,FREQ) は、X と同じ大きさの頻度ベクトル
% を受け入れます。FREQ は、通常は、X の要素に対応するための整数の頻度を
% 含みますが、任意の整数でない非負値を含むこともできます。
%
% [...] = LOGNFIT(X,ALPHA,CENSORING,FREQ,OPTIONS) は、最尤(ML)推定の計算に
% 使用される反復アルゴリズムに対するコントロールパラメータを指定します。
% この引数は、STATSET をコールすることで作成されます。パラメータ名と
% デフォルト値については、STATSET('lognfit') を参照してください。
%
% これらのデフォルト値を使用するには、ALPHA, CENSORING, FREQ に対して、
% [] を渡してください。
%
% 参考 : LOGNCDF, LOGNINV, LOGNLIKE, LOGNPDF, LOGNRND, LOGNSTAT, MLE,
%        STATSET.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2003/02/11 19:41:34 $
