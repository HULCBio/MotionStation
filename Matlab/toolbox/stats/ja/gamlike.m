% GAMLIKE   ガンマ対数尤度関数の負の値
%
% L = GAMLIKE(PARAMS,DATA) は、DATA を与えて、パラメータ PARAMS(1) = A 
% と PARAMS(2) = B に対するガンマ対数尤度関数の負の値を出力します。
% 
% [LOGL, AVAR] = GAMLIKE(PARAMS,DATA) は、Fisher 情報行列 AVAR の逆行列
% を追加します。PARAMS の入力パラメータ値が最尤推定の場合、AVAR の対角
% 要素は、各々のパラメータの漸近的な分散になります。AVAR は、期待された
% 情報ではなく、観測された Fisher 情報に基づきます。
% 
% GAMLIKE は、最尤推定のユーティリティ関数です。
% 
% 参考 : BETALIKE, GAMFIT, NORMLIKE, MLE, WBLLIKE.


%   B.A. Jones 11-4-94, Z. You 5-25-99
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:09:37 $
