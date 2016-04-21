% NBINLIKE   負の二項対数尤度関数の負値
%
% L = NBINLIKE(PARAMS,DATA) は、与えられた DATA により、パラメータ 
% PARAMS(1) = R と PARAMS(2) = P に対する負の二項対数尤度関数の負の値を
% 出力します。
%
% [LOGL, AVAR] = NBINLIKE(PARAMS,DATA) は、Fisher 情報行列 の逆行列
% AVAR も出力します。PARAMS の入力パラメータの値が最尤推定値の場合、
% AVAR の対角要素は、漸近的な分散になります。AVAR は、予測された情報
% ではなく、観測されたFisherの情報に基づきます。
%
% NBINLIKE は、最尤推定のユーティリティ関数です。
%
% 参考 : BETALIKE, GAMLIKE, NBINFIT, NBINLIKE, NORMLIKE, MLE, WBLLIKE.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2003/01/07 20:12:40 $

