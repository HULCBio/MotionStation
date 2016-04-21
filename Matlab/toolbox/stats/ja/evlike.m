% EVLIKE   極値分布に対する負の対数尤度
%
% NLOGL = EVLIKE(PARAMS,DATA) は、DATA を与えて、パラメータ PARAMS(1) = MU 
% と PARAMS(2) = SIGMA で評価されたタイプ1の極値分布に対する対数尤度の
% 負の値を出力します。NLOGL は、スカラです。
%
% [NLOGL, AVAR] = EVLIKE(PARAMS,DATA) は、Fisher 情報行列 AVAR の逆も
% 出力します。PARAMS の入力パラメータが最尤推定である場合、AVAR の対角
% 要素は、それらの漸近的な分散値です。AVAR は、期待された情報ではなく、
% 観測された Fisher 情報に基づきます。
%
% [...] = EVLIKE(PARAMS,DATA,CENSORING) は、正確に観測された観測値に
% [...] = EVLIKE(PARAMS,DATA,CENSORING,FREQ) は、DATA と同じ大きさの% [...] = EVLIKE(PARAMS,DATA,CENSORING,FREQ) は、DATA と同じサイズの
% 頻度ベクトルを受け入れます。FREQ は、通常は、DATA の要素に対応する
% ための整数の頻度を含みますが、任意の整数でない非負値を含むことも
% できます。これらのデフォルト値を使用するには、CENSORING に対して [] を
% 渡してください。
%
% タイプ1の極値分布は、別名Gumbel分布としても知られています。Y が 
% Weibull分布の場合、X=log(Y) は、タイプ1の極値分布になります。
%
% 参考 : EVCDF, EVFIT, EVINV, EVPDF, EVRND, EVSTAT.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2003/01/08 15:29:31 $
