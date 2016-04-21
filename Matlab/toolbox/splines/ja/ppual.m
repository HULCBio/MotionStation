% PPUAL   関数をpp-型で計算
%
% V = PPUAL(PP,X) は、そのpp-型が PP にある関数 f の X の要素における値を
% 返します。
% V = PPUAL(PP,X,'l<anything>') は、左側から連続であるように f を得ます。
% f がm変数で、3番目の入力引数が実際にm要素のセルの場合、LEFT{i}(1) = 'l' 
% であれば、i番目の変数について左からの連続性が要求されます。
%
% 参考 : FNVAL, SPVAL, RSVAL, PPVAL.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
