% WEIBLIKE   Weibull対数尤度関数
%
% L = WEIBLIKE(params,data) は、DATA を与えて、パラメータ PARAMS(1) = A 
% と PARAMS(2) = B に対する Weibull対数尤度関数値を出力します。
% 
% [LOGL, AVAR] = WEIBLIKE(PARAMS,DATA) は、Fisher 情報行列 AVAR も出力
% します。PARAMS 内の入力パラメータ値が最尤推定である場合、AVAR の対角
% 要素は、それらの漸近的な分散値です。AVAR は、期待された情報ではなく、
% 観測された Fisher 情報に基づきます。
% 
% WEIBLIKE は、最尤推定のユーティリティ関数です。
% 
% 参考 : BETALIKE, GAMLIKE, MLE, NORMLIKE, WEIBFIT, WEIBPLOT. 


%   B.A. Jones 11-4-94
%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:16:16 $
