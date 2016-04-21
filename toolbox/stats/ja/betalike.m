% BETALIKE   ベータ対数尤度関数の負の値
%
% LOGL = BETALIKE(PARAMS,DATA) は、DATA を与えて、パラメータ PARAMS(1) = A  
% と PARAMS(2) = B に対するベータ対数尤度関数の負の値を出力します。
% 
% [LOGL, AVAR] = BETALIKE(PARAMS,DATA) は、Fisher 情報行列 AVAR も出力
% します。PARAMS の入力パラメータ値が最尤推定値の場合、AVAR の対角要素は、
% それらの漸近的な分散値です。AVAR は、期待された情報ではなく、観測された 
% Fisher 情報に基づきます。
% 
% BETALIKE は、最尤推定のユーティリティ関数です。
% 
% 参考 : BETAFIT, GAMLIKE, MLE, NORMLIKE, WBLLIKE.


%   B.A. Jones 11-4-94, Z. You 5-24-99
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:09:09 $
