% WBLLIKE   Weibull分布に対する負の対数尤度
%
% NLOGL = WBLLIKE(PARAMS,DATA) は、DATA を与えて、パラメータ PARAMS(1) = A 
% と PARAMS(2) = B で評価されたWeibull分布に対する対数尤度の負の値を出力
% します。NLOGL は、スカラです。
%
% [NLOGL, AVAR] = WBLLIKE(PARAMS,DATA) は、Fisher 情報行列 AVAR の逆も
% 出力します。PARAMS の入力パラメータが最尤推定である場合、AVAR の対角
% 要素は、それらの漸近的な分散値です。AVAR は、期待された情報ではなく、
% 観測された Fisher 情報に基づきます。
%
% [...] = WBLLIKE(PARAMS,DATA,CENSORING) は、正確に観測された観測値に
% 対して0を、右側打ち切りの観測値に対して1となる、DATA と同じ大きさの
% 論理ベクトルを受け入れます。
%
% [...] = WBLLIKE(PARAMS,DATA,CENSORING,FREQ) は、DATA と同じ大きさの
% 頻度ベクトルを受け入れます。FREQ は、通常は、DATA の要素に対応する
% ための整数の頻度を含みますが、任意の整数でない非負値を含むことも
% できます。これらのデフォルト値を使用するには、CENSORING に対して [] を
% 渡してください。
%
% 参考 : WBLCDF, WBLFIT, WBLINV, WBLPDF, WBLRND, WBLSTAT.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2003/01/09 21:47:42 $
