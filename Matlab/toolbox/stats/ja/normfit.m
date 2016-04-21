% NORMFIT   正規分布データのパラメータと信頼区間の推定
%
% [MUHAT,SIGMAHAT] = NORMFIT(X) は、与えられた X のデータで、正規分布の
% パラメータの最尤推定を出力します。MUHAT は、平均の推定で、SIGMAHAT は、
% 標準偏差の推定です。
%
% [MUHAT,SIGMAHAT,MUCI,SIGMACI] = NORMFIT(X) は、パラメータ推定に対する
% 95%の信頼区間を出力します。
% 
% [MUHAT,SIGMAHAT,MUCI,SIGMACI] = NORMFIT(X,ALPHA) は、パラメータ推定に 
% 対する 100(1-ALPHA)% の信頼区間を出力します。
% 
% [...] = NORMFIT(X,ALPHA,CENSORING) は、正確に観測された観測値に対して
% 0、右側打ち切りの観測値に対して1となる、X と同じ大きさの論理ベクトルを
% 受け入れます。
%
% [...] = NORMFIT(X,ALPHA,CENSORING,FREQ) は、X と同じ大きさの頻度
% ベクトルを受け入れます。FREQ は、通常は、X の要素に対応するための
% 整数の頻度を含みますが、任意の整数でない非負値を含むこともできます。
%
% [...] = NORMFIT(X,ALPHA,CENSORING,FREQ,OPTIONS) は、最尤(ML)推定の計算に
% 使用される反復アルゴリズムに対するコントロールパラメータを指定します。
% この引数は、STATSET をコールすることで作成されます。パラメータ名と
% デフォルト値については、STATSET('normfit') を参照してください。
%
% これらのデフォルト値を使用するには、ALPHA, CENSORING, FREQ に対して、
% [] を渡してください。
%
% 参考 : NORMCDF, NORMINV, NORMLIKE, NORMPDF, NORMRND, NORMSTAT, MLE, 
%        STATSET.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2003/04/21 19:42:41 $
