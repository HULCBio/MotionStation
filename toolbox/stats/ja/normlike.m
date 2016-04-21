% NORMLIKE   正規分布に対する負の対数尤度
%
% NLOGL = NORMLIKE(PARAMS,DATA) は、DATA を与えて、パラメータ PARAMS(1) = MU 
% と PARAMS(2) = SIGMA で評価された正規分布に対する対数尤度の負の値を出力
% します。NLOGL は、スカラです。
% 
% [NLOGL, AVAR] = NORMLIKE(PARAMS,DATA) は、Fisher 情報行列 AVAR の逆も
% 出力します。PARAMS の入力パラメータが最尤推定である場合、AVAR の対角
% 要素は、それらの漸近的な分散値です。AVAR は、期待された情報ではなく、
% 観測された Fisher 情報に基づきます。
% 
% [...] = NORMLIKE(PARAMS,DATA,CENSORING) は、正確に観測された観測値に
% 対して0を、右側打ち切りの観測値に対して1となる、DATA と同じ大きさの
% 論理ベクトルを受け入れます。
%
% [...] = NORMLIKE(PARAMS,DATA,CENSORING,FREQ) は、DATA と同じ大きさの% [...] = NORMLIKE(PARAMS,DATA,CENSORING,FREQ) は、DATA と同じサイズの
% 頻度ベクトルを受け入れます。FREQ は、通常は、DATA の要素に対応する
% ための整数の頻度を含みますが、任意の整数でない非負値を含むことも
% 可能です。CENSORING に対してデフォルト値を使用する場合は、 [] を渡して
% ください。
%
% 参考 : NORMCDF, NORMFIT, NORMINV, NORMPDF, NORMRND, NORMSTAT.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2003/02/12 17:14:22 $
